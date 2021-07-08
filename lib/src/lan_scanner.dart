// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:dart_ping/dart_ping.dart';

// Project imports:
import 'package:lan_scanner/src/models/device_address.dart';
import 'package:lan_scanner/src/models/error_codes.dart';
import 'package:lan_scanner/src/models/progress_callback.dart';

/// A class to handle discovering devices in the local network
///
/// Call [quickScan] or [preciseScan] on [LanScanner] instance to get access to the stream
class LanScanner {
  /// State of the scanning action
  bool _isScanInProgress = false;

  /// Checks if scan is already in progress.
  /// For performance reasons, you can't begin scan while the first one is running
  bool get isScanInProgress => _isScanInProgress;

  /// Discovers network devices in the given [subnet] and [port].
  ///
  /// If [verbose] is set to true,
  /// [quickScan] returns instances of [DeviceAddress] for every pontential IP
  /// on the network, even in the case, they returned an error code.
  ///
  /// This method uses UDP to ping the network.
  /// It is fast, but some devices may not respond to the ping.
  Stream<DeviceAddress> quickScan({
    required String? subnet,
    int? port = 80,
    Duration timeout = const Duration(seconds: 5),
    bool verbose = false,
  }) {
    // Check for possible errors in the configuration
    if (subnet == null || port == null) {
      throw 'Subnet or port is not set yet';
    }

    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    final controller = StreamController<DeviceAddress>();
    final futureSockets = <Future<Socket>>[];
    final _errorCodes = ErrorCodes.errorCodes;

    _isScanInProgress = true;

    for (int addr = 1; addr <= 255; ++addr) {
      final hostToPing = '$subnet.$addr';
      final Future<Socket> connection =
          Socket.connect(hostToPing, port, timeout: timeout);

      futureSockets.add(connection);

      connection.then((socket) {
        socket.destroy();

        // If the connection succeeds, we can add it to the sink
        controller.sink.add(DeviceAddress(
          exists: true,
          ip: hostToPing,
          port: port,
        ));
      }).catchError((dynamic err) {
        if (!(err is SocketException)) {
          throw err;
        }

        // Check if we got predefined error or just connection timed out
        // If given error was predefined, we can still consider this IP as valid host
        if (err.osError == null ||
            _errorCodes.contains(err.osError?.errorCode)) {
          if (verbose) {
            controller.sink.add(DeviceAddress(
              exists: false,
              ip: hostToPing,
              port: port,
              errorCode: err.osError?.errorCode,
            ));
          }
        } else {
          throw err;
        }
      });
    }

    // Wait for all futures to finish, then close the sink
    Future.wait<Socket>(futureSockets).then((_) {
      controller.sink.close();
    }).catchError((_) {
      controller.sink.close();
    });

    _isScanInProgress = false;

    return controller.stream;
  }

  /// Discovers network devices in the given [subnet].
  ///
  /// This method uses ICMP to ping the network.
  /// It may be slow to complete the whole scan,
  /// so it is possible to provide a range to scan.
  ///
  /// [progressCallback] is scaled from 0.01 to 1
  Stream<DeviceAddress> preciseScan({
    required String? subnet,
    int firstIP = 1,
    int lastIP = 255,
    Duration timeout = const Duration(seconds: 5),
    ProgressCallback? progressCallback,
  }) async* {
    // Check for possible errors in the configuration
    if (subnet == null) {
      throw 'Subnet is not set yet';
    }

    if (firstIP > lastIP) {
      throw "firstIP can't be larger than lastIP";
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    _isScanInProgress = true;

    for (int addr = firstIP; addr <= lastIP; ++addr) {
      final hostToPing = '$subnet.$addr';

      final ping = Ping(hostToPing, count: 1, timeout: timeout.inSeconds);

      await for (PingData pingData in ping.stream) {
        if (pingData.summary != null) {
          PingSummary summary = pingData.summary!;

          int received = summary.received;

          if (received > 0) {
            yield DeviceAddress(
              exists: true,
              ip: '$subnet.$addr',
            );
          }
        }
      }
      progressCallback?.call(((addr) / (lastIP)).toStringAsPrecision(2));
    }

    _isScanInProgress = false;
  }
}
