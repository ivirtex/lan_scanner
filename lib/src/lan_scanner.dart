import 'package:lan_scanner/src/models/device_address.dart';
import 'dart:async';
import 'dart:io';

/// [LanScanner]
class LanScanner {
  bool _isScanInProgress = false;

  /// Checks if scan is already in progress.
  /// For performance reasons, you can't begin scan while the first one is running
  bool get isScanInProgress => _isScanInProgress;

  /// Discovers network devices in the given subnet and port.
  ///
  /// If [verbose] is set to true,
  /// [discover] returns instances of [DeviceAddress] for every IP on the network,
  /// even in the case, they are not online.
  Stream<DeviceAddress> discover({
    required String? subnet,
    int? port = 80,
    Duration timeout = const Duration(seconds: 5),
    bool verbose = false,
  }) async* {
    // Check for possible errors in the configuration
    if (subnet == null || port == null) {
      throw 'Subnet or port is not set yet';
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    for (int addr = 1; addr <= 255; ++addr) {
      final hostToPing = '$subnet.$addr';

      try {
        final Socket socket = await Socket.connect(hostToPing, port);
        socket.destroy();

        yield DeviceAddress(exists: true, ip: hostToPing, port: port);
      } catch (err) {
        if (!(err is SocketException)) {
          rethrow;
        }

        if (err.osError == null ||
            _errorCodes.contains(err.osError?.errorCode)) {
          yield DeviceAddress(exists: false, ip: hostToPing, port: port);
        } else {
          // Error 23,24: Too many open files in system
          rethrow;
        }
      }
    }

    _isScanInProgress = false;
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
