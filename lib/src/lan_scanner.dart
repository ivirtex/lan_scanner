// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_icmp_ping/flutter_icmp_ping.dart';

// Project imports:
import 'package:lan_scanner/src/models/host_model.dart';

/// A class to handle discovering devices in the local network
///
/// Call [quickScan] or [preciseScan] on [LanScanner] instance
/// to get access to the stream.
class LanScanner {
  /// State of the scanning action
  bool _isScanInProgress = false;

  /// Checks if scan is already in progress.
  /// For performance reasons, you can't begin scan
  /// while the first one is running.
  bool get isScanInProgress => _isScanInProgress;

  /// This method is used to spawn isolate for range scan.
  /// It is not meant to be used directly.
  /// It is used by [preciseScan] method.
  Future<List<HostModel>> _icmpRangeScan(List<Object> args) async {
    final subnet = args[0];
    final firstIP = args[1] as int;
    final lastIP = args[2] as int;
    final sendPort = args[3] as SendPort;

    final List<HostModel> hosts = [];

    for (int currAddr = firstIP; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';

      final ping = Ping(hostToPing, count: 1, timeout: 1);

      try {
        await for (final PingData pingData in ping.stream) {
          if (pingData.summary != null) {
            final PingSummary summary = pingData.summary!;

            final int received = summary.received!;

            if (received > 0) {
              final host = HostModel(ip: hostToPing);
              hosts.add(host);
              sendPort.send(host.ip);

              // print('Host detected: $hostToPing');
            } else {
              // print('Host not responding: $hostToPing');
            }
          }
        }
      } catch (err) {
        print(err);
      }
    }

    return hosts;
  }

  /// Discovers network devices in the given [subnet].
  ///
  /// This method uses ICMP to ping the network.
  /// It may be slow to complete the whole scan,
  /// so it is possible to provide a range to scan.
  ///
  /// [progressCallback] is scaled from 0.01 to 1
  Stream<HostModel> icmpScan(
    String? subnet, {
    int firstIP = 1,
    int lastIP = 255,
    int scanSpeeed = 5,
  }) {
    late StreamController<HostModel> _controller;
    // Check for possible errors in the configuration
    if (subnet == null) {
      throw 'Subnet has not been provided';
    }

    if (firstIP > lastIP) {
      throw "firstIP can't be larger than lastIP";
    }

    if (_isScanInProgress) {
      throw 'Cannot begin scanning while the first one is still running';
    }

    Future<void> startScan() async {
      _isScanInProgress = true;
      int currIP = firstIP;

      final int isolateInstances = scanSpeeed;
      final int rangeForEachIsolate = (lastIP - firstIP) ~/ isolateInstances;
      final List<Future<List<HostModel>>> isolatesList = [];

      for (; currIP < 255; currIP += rangeForEachIsolate) {
        final receivePort = ReceivePort();
        final isolateArgs = [
          subnet,
          currIP,
          currIP + rangeForEachIsolate,
          receivePort.sendPort,
        ];
        final isolate = compute(
          _icmpRangeScan,
          isolateArgs,
          debugLabel: 'Range: $currIP - ${currIP + rangeForEachIsolate}',
        );

        isolatesList.add(isolate);

        receivePort.listen((host) {
          print("PORT: Host detected: $host");
          _controller.add(HostModel(ip: host));
        });
      }

      // Await for all isolates to complete their work
      final List<List<HostModel>> completedIsolates =
          await Future.wait(isolatesList);

      _isScanInProgress = false;
    }

    void stopScan() {
      // TODO: implement stopScan
      // currAddr = lastIP;

      _isScanInProgress = false;
    }

    _controller = StreamController<HostModel>(
      onCancel: stopScan,
      onListen: startScan,
      onPause: stopScan,
      onResume: startScan,
    );

    return _controller.stream;
  }
}
