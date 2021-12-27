// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:math';

// Package imports:
import 'package:dart_ping/dart_ping.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:lan_scanner/lan_scanner.dart';

// Project imports:
import 'package:lan_scanner/src/models/host_model.dart';
import 'package:lan_scanner/src/models/progress_callback.dart';

/// A class to handle discovering devices in the local network
///
/// Call [icmpScan] on [LanScanner] instance
/// to get access to the stream.
class LanScanner {
  /// Constructor of [LanScanner]
  ///
  /// Set [debugLogging] to true to enable printing
  /// debug messages to the console.
  LanScanner({this.debugLogging = false});

  /// If true, the [icmpScan] method will print debug logs
  /// (information about ping responses and errors)
  bool debugLogging;

  /// State of the scanning action
  bool _isScanInProgress = false;

  /// Checks if scan is already in progress.
  /// For performance reasons, you can't begin scan
  /// while the first one is running.
  bool get isScanInProgress => _isScanInProgress;

  /// This method is used to spawn isolate for range scan.
  /// It is not meant to be used directly.
  /// It is used by [icmpScan] method.
  Future<void> _icmpRangeScan(List<Object> args) async {
    final subnet = args[0] as String;
    final firstIP = args[1] as int;
    final lastIP = args[2] as int;
    final timeout = args[3] as int;
    final sendPort = args[4] as SendPort;

    for (int currAddr = firstIP; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';

      final Ping pingRequest = Ping(hostToPing, count: 1, timeout: timeout);

      final List msg = [
        hostToPing,
      ];

      try {
        await for (final PingData pingData in pingRequest.stream) {
          // final int? responseTime = pingData.response?.time?.inMilliseconds;

          if (pingData.summary != null) {
            final PingSummary summary = pingData.summary!;

            final int received = summary.received;

            if (received > 0) {
              msg.add(true);
              sendPort.send(msg);

              if (debugLogging) {
                print('Host responded: $hostToPing');
              }
            } else {
              msg.add(false);
              sendPort.send(msg);

              if (debugLogging) {
                print('Host not responding: $hostToPing');
              }
            }
          }
        }
      } catch (e) {
        if (debugLogging) {
          print('Error: $e');
        }
      }
    }
  }

  /// Discovers network devices in the given [subnet].
  ///
  /// This method uses ICMP to ping the network.
  /// It may be slow to complete the whole scan,
  /// so it is possible to provide a range to scan.
  Stream<HostModel> icmpScan(
    String? subnet, {
    int firstIP = 1,
    int lastIP = 255,
    int scanSpeeed = 5,
    Duration timeout = const Duration(seconds: 1),
    ProgressCallback? progressCallback,
  }) {
    late StreamController<HostModel> _controller;
    final int isolateInstances = scanSpeeed;
    final int numOfHostsToPing = lastIP - firstIP + 1;
    final int rangeForEachIsolate = numOfHostsToPing ~/ isolateInstances;
    final List<Isolate> isolatesList = [];

    int numOfHostsPinged = 0;

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

    if (scanSpeeed < 1) {
      throw 'Scan speed must be at least 1';
    }

    Future<void> startScan() async {
      DartPingIOS.register();
      _isScanInProgress = true;

      for (int currIP = firstIP; currIP < 255; currIP += rangeForEachIsolate) {
        final receivePort = ReceivePort();
        final fromIP = currIP;
        final toIP = max(min(currIP + rangeForEachIsolate - 1, lastIP), lastIP);
        final isolateArgs = [
          subnet,
          fromIP,
          toIP,
          timeout.inSeconds,
          receivePort.sendPort,
        ];

        final isolate = await Isolate.spawn(
          _icmpRangeScan,
          isolateArgs,
          debugName: 'ScanThread: $fromIP - $toIP',
        );
        isolatesList.add(isolate);

        receivePort.listen((msg) {
          msg = msg as List;

          // print('Message received: $msg');
          final hostToPing = msg[0] as String;
          final isReachable = msg[1] as bool;

          numOfHostsPinged++;
          final String progress =
              (numOfHostsPinged / numOfHostsToPing).toStringAsFixed(2);
          progressCallback?.call(progress);
          // print('Progress: $progress%');

          if (isReachable) {
            _controller.add(
              HostModel(
                ip: hostToPing,
                isReachable: isReachable,
              ),
            );
          }
        });
      }

      _isScanInProgress = false;
    }

    void stopScan() {
      for (final isolate in isolatesList) {
        // if (debugLogging) {
        //   print('Killing thread: ${isolate.debugName}');
        // }
        isolate.kill(priority: Isolate.immediate);
      }

      _isScanInProgress = false;
      _controller.close();
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
