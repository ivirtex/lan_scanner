import 'dart:io';

import 'package:lan_scanner/src/models/device_address.dart';
import 'dart:async';

/// [LanScanner
class LanScanner {
  String? _subnet;
  int? _port;
  Duration _timeout = const Duration(seconds: 5);

  bool _isScanInProgress = false;

  /// Checks if scan is already in progress.
  /// For performance reasons, you can't begin scan while the first one is running
  bool get isScanInProgress => _isScanInProgress;

  /// Discovers network devices in the given subnet and port.
  ///
  /// If [verbose] is set to true,
  /// [discover] returns instances of [DeviceAddress] for every IP on the network,
  /// even in the case, they are not online.
  Stream<DeviceAddress> discover({bool verbose = false}) {
    // Check for possible errors in the configuration
    if (_subnet == null || _port == null) {
      throw 'Subnet or port is not set yet';
    }

    if (_port! < 1 || _port! > 65535) {
      throw 'Incorrect port';
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    final controller = StreamController<DeviceAddress>();
    final futureSockets = <Future<Socket>>[];

    for (int addr = 1; addr <= 255; ++addr) {
      final hostToPing = '$_subnet.$addr';
      final Future<Socket> connection =
          Socket.connect(hostToPing, _port!, timeout: _timeout);

      futureSockets.add(connection);

      connection.then((socket) {
        socket.destroy();

        // If the connection succeeds, we can add it to the sink
        controller.sink.add(DeviceAddress(
          exists: true,
          ip: hostToPing,
          port: _port,
        ));
      }).catchError((dynamic err) {
        if (!(err is SocketException)) {
          throw err;
        }

        if ((err.osError == null ||
                _errorCodes.contains(err.osError?.errorCode)) &&
            verbose) {
          controller.sink
              .add(DeviceAddress(exists: false, ip: hostToPing, port: _port));
        } else {
          throw err;
        }
      });
    }

    Future.wait<Socket>(futureSockets)
        .then((value) => controller.sink.close())
        .catchError((dynamic err) => controller.sink.close());

    return controller.stream;
  }

  /// 13: Connection failed (OS Error: Permission denied)
  /// 49: Bind failed (OS Error: Can't assign requested address)
  /// 61: OS Error: Connection refused
  /// 64: Connection failed (OS Error: Host is down)
  /// 65: No route to host
  /// 101: Network is unreachable
  /// 111: Connection refused
  /// 113: No route to host
  /// <empty>: SocketException: Connection timed out
  static final _errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];
}
