// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:io';
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
  /// Set [debugLogging] to true to enable logging
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

  /// Discovers network devices in the given [subnet].
  ///
  /// This method uses ICMP to ping the network.
  /// It may be slow to complete the whole scan,
  /// so it is possible to provide a range to scan.
  ///
  /// [scanThreads] determines the number of threads to spawn for the scan.
  /// Avoid using high numbers of threads, as it may cause high memory usage.
  ///
  /// Consider using [quickIcmpScanSync] or [quickIcmpScanAsync].
  Stream<Host> icmpScan(
    String subnet, {
    int firstIP = 1,
    int lastIP = 255,
    int scanThreads = 10,
    Duration timeout = const Duration(seconds: 1),
    ProgressCallback? progressCallback,
  }) {
    late StreamController<Host> controller;
    final isolateInstances = scanThreads;
    final numOfHostsToPing = lastIP - firstIP + 1;
    final rangeForEachIsolate = (numOfHostsToPing / isolateInstances).round();
    final isolatesList = <Isolate>[];

    var numOfHostsPinged = 0;

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

      for (var currIP = firstIP; currIP < 255; currIP += rangeForEachIsolate) {
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

          final hostToPing = msg.elementAt(0) as String;
          final isReachable = msg.elementAt(1) as bool;
          final pingTime = msg.elementAtOrNull(2) as int?;

          numOfHostsPinged++;
          final progress =
              (numOfHostsPinged / numOfHostsToPing).toStringAsFixed(2);
          progressCallback?.call(double.parse(progress));

          if (numOfHostsPinged == numOfHostsToPing) {
            if (debugLogging) {
              log('Scan finished');
            }
            _isScanInProgress = false;
            controller.close();
          }

          if (isReachable) {
            controller.add(
              Host(
                internetAddress: InternetAddress(hostToPing),
                pingTime:
                    pingTime != null ? Duration(milliseconds: pingTime) : null,
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

    controller = StreamController<Host>(
      onCancel: stopScan,
      onListen: startScan,
      onPause: stopScan,
      onResume: startScan,
    );

    return controller.stream;
  }

  /// Discovers network devices in the given [subnet].
  /// Works on iOS platform.
  ///
  /// Uses ICMP as [icmpScan] method, but internally
  /// has faster implementation and doesn't use streams.
  ///
  /// This method may block the main thread, so on
  /// platform other than iOS it is recommended to use
  /// [quickIcmpScanAsync] instead.
  Future<List<Host>> quickIcmpScanSync(
    String subnet, {
    int firstIP = 1,
    int lastIP = 255,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final hostFutures = <Future<Host?>>[];

    for (var currAddr = firstIP; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';

      hostFutures.add(
        _pingHost(
          hostToPing,
          timeout: timeout.inSeconds,
        ),
      );
    }

    // Executing this synchronously causes the main thread to freeze.
    final resolvedHosts = await Future.wait(hostFutures);

    return resolvedHosts
        .where((element) => element != null)
        .cast<Host>()
        .toList();
  }

  /// Discovers network devices in the given [subnet].
  ///
  /// Works the same as [quickIcmpScanSync], but uses
  /// isolate to avoid blocking the main thread.
  Future<List<Host>> quickIcmpScanAsync(
    String subnet, {
    int firstIP = 1,
    int lastIP = 255,
    Duration timeout = const Duration(seconds: 1),
  }) {
    final completer = Completer<List<Host>>();
    final receivePort = ReceivePort();
    final isolateArgs = [
      subnet,
      firstIP,
      lastIP,
      timeout.inSeconds,
      receivePort.sendPort,
    ];

    final hosts = <Host>[];

    receivePort.listen((msg) {
      if (msg is List) {
        final address = msg.elementAt(0) as String;
        final pingTime = msg.elementAtOrNull(1) as int?;

        final host = Host(
          internetAddress: InternetAddress(address),
          pingTime: pingTime != null ? Duration(microseconds: pingTime) : null,
        );

        hosts.add(host);
      } else if (msg == 'Complete') {
        completer.complete(hosts);
      }
    });

    Isolate.spawn(
      _quickIcmpScan,
      isolateArgs,
      debugName: 'QuickScanThread',
    );

    return completer.future;
  }

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
          log(
            'iOS is not supported by this method, see the readme at https://pub.dev/packages/lan_scanner',
          );
        } else {
          rethrow;
        }

        return;
      }

      final msg = <dynamic>[
        hostToPing,
      ];

      try {
        await for (final PingData pingData in pingRequest.stream) {
          if (pingData.summary != null) {
            final summary = pingData.summary!;

            final received = summary.received;

            if (received > 0) {
              msg
                ..add(true)
                ..add(pingData.response?.time?.inMilliseconds);
              sendPort.send(msg);

              if (debugLogging) {
                log('Host responded: $hostToPing');
              }
            } else {
              msg.add(false);
              sendPort.send(msg);

              if (debugLogging) {
                log('Host not responding: $hostToPing');
              }
            }
          }
        }
      } catch (e) {
        if (debugLogging) {
          log('Error: $e');
        }
      }
    }
  }

  Future<void> _quickIcmpScan(List<Object> args) async {
    final subnet = args[0] as String;
    final firstIP = args[1] as int;
    final lastIP = args[2] as int;
    final timeout = args[3] as int;
    final sendPort = args[4] as SendPort;

    final hostFutures = <Future<Host?>>[];

    for (var currAddr = firstIP; currAddr <= lastIP; ++currAddr) {
      final hostToPing = '$subnet.$currAddr';

      hostFutures.add(
        _pingHost(
          hostToPing,
          timeout: timeout,
        ),
      );
    }

    final resolvedHosts = await Future.wait(hostFutures);

    for (final host in resolvedHosts) {
      if (host != null) {
        sendPort.send([
          host.internetAddress.address,
          host.pingTime?.inMicroseconds,
        ]);
      }
    }

    sendPort.send('Complete');
  }

  Future<Host?> _pingHost(
    String target, {
    required int timeout,
  }) async {
    late Ping pingRequest;

    try {
      pingRequest =
          Ping(target, count: 1, timeout: timeout, forceCodepage: true);
    } catch (exc) {
      if (exc is UnimplementedError &&
          (exc.message?.contains('iOS') ?? false)) {
        log(
          "DartPingIOS.register() hasn't been called or you are using async version of the function, see the readme at https://pub.dev/packages/lan_scanner",
        );
      } else {
        rethrow;
      }
    }

    await for (final data in pingRequest.stream) {
      if (debugLogging) {
        log('$data from $target');
      }

      if (data.response != null && data.error == null) {
        final response = data.response!;

        return Host(
          internetAddress: InternetAddress(target),
          pingTime: response.time != null
              ? Duration(microseconds: response.time!.inMicroseconds)
              : null,
        );
      }
    }

    return null;
  }
}
