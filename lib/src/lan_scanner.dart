// ignore_for_file: avoid_print, omit_local_variable_types

// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Package imports:
import 'package:dart_ping/dart_ping.dart';

// Project imports:
import 'package:lan_scanner/lan_scanner.dart';

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
  /// Used by [icmpScan] method.
  Future<void> _icmpRangeScan(List<Object> args) async {
    final subnet = args[0] as String;
    final firstIP = args[1] as int;
    final lastIP = args[2] as int;
    final timeout = args[3] as int;
    final sendPort = args[4] as SendPort;

    for (var currAddr = firstIP; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';
      final Ping pingRequest;

      try {
        pingRequest =
            Ping(hostToPing, count: 1, timeout: timeout, forceCodepage: true);
      } catch (exc) {
        if (exc is UnimplementedError &&
            (exc.message?.contains('iOS') ?? false)) {
          print(
            'iOS is currently not supported, please see the readme at https://pub.dev/packages/lan_scanner',
          );
        } else {
          rethrow;
        }

        return;
      }

      final List<dynamic> msg = [
        hostToPing,
      ];

      try {
        await for (final PingData pingData in pingRequest.stream) {
          final int? responseTime = pingData.response?.time?.inMilliseconds;

          if (hostToPing == '192.168.68.1') {
            print('responseTime: $responseTime');
          }

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
  ///
  /// [scanThreads] determines the number of threads to spawn for the scan.
  /// Avoid using high numbers of threads, as it may cause high memory usage.
  Stream<HostModel> icmpScan(
    String subnet, {
    int firstIP = 1,
    int lastIP = 255,
    int scanThreads = 10,
    Duration timeout = const Duration(seconds: 1),
    ProgressCallback? progressCallback,
  }) {
    late StreamController<HostModel> controller;
    final int isolateInstances = scanThreads;
    final int numOfHostsToPing = lastIP - firstIP + 1;
    final int rangeForEachIsolate =
        (numOfHostsToPing / isolateInstances).round();
    final List<Isolate> isolatesList = [];

    int numOfHostsPinged = 0;

    // Check for possible errors in the configuration
    assert(
      firstIP >= 1 && firstIP <= lastIP,
      'firstIP must be between 1 and lastIP',
    );

    assert(
      scanThreads >= 1,
      'Scan threads must be at least 1',
    );

    if (_isScanInProgress) {
      throw Exception(
        'Cannot begin scanning while the first one is still running',
      );
    }

    Future<void> startScan() async {
      _isScanInProgress = true;

      for (int currIP = firstIP; currIP < 255; currIP += rangeForEachIsolate) {
        final receivePort = ReceivePort();
        final fromIP = currIP;
        final toIP = (currIP + rangeForEachIsolate - 1).clamp(firstIP, lastIP);
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

          final hostToPing = msg[0] as String;
          final isReachable = msg[1] as bool;

          numOfHostsPinged++;
          final String progress =
              (numOfHostsPinged / numOfHostsToPing).toStringAsFixed(2);
          progressCallback?.call(double.parse(progress));

          if (progress == '1.00') {
            if (debugLogging) {
              print('Scan finished');
            }
            _isScanInProgress = false;
            controller.close();
          }

          if (isReachable) {
            controller.add(
              HostModel(
                ip: hostToPing,
                isReachable: isReachable,
              ),
            );
          }
        });
      }
    }

    void stopScan() {
      for (final isolate in isolatesList) {
        isolate.kill(priority: Isolate.immediate);
      }

      _isScanInProgress = false;
      controller.close();
    }

    controller = StreamController<HostModel>(
      onCancel: stopScan,
      onListen: startScan,
      onPause: stopScan,
      onResume: startScan,
    );

    return controller.stream;
  }
}
