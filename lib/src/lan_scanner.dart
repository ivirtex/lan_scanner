import 'package:dart_ping/dart_ping.dart';
import 'package:lan_scanner/src/models/device_address.dart';
import 'dart:async';
import 'dart:io';

/// [LanScanner]
class LanScanner {
  bool _isScanInProgress = false;
  List<Future<PingData>> futures = <Future<PingData>>[];

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
    Duration timeout = const Duration(seconds: 5),
    bool verbose = false,
  }) {
    // Check for possible errors in the configuration
    if (subnet == null) {
      throw 'Subnet is not set yet';
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    final controller = StreamController<DeviceAddress>();

    for (int addr = 1; addr <= 255; ++addr) {
      final hostToPing = '$subnet.$addr';

      final ping = Ping(hostToPing, count: 1, timeout: timeout.inSeconds);
      final futurePing = ping.stream.last;

      futures.add(futurePing);

      futurePing.then((data) {
        PingSummary? summary = data.summary;

        if (summary != null) {
          int received = summary.received;

          if (received > 0) {
            controller.add(DeviceAddress(
              exists: true,
              ip: '$subnet.$addr',
            ));
          } else {
            if (verbose) {
              controller.add(DeviceAddress(
                exists: false,
                ip: '$subnet.$addr',
              ));
            }
          }
        }
      });
    }

    Future.wait(futures)
        .then<void>((_) => controller.close())
        .catchError((_) => controller.close());

    _isScanInProgress = false;

    return controller.stream;
  }
}
