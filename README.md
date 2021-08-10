# lan_scanner

[![Pub badge](https://img.shields.io/pub/v/lan_scanner)](https://pub.dartlang.org/packages/lan_scanner)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

[Dart](https://dart.dev) / [Flutter](https://flutter.dev) package that allows discovering network devices in local network ([LAN](https://en.wikipedia.org/wiki/Local_area_network)).

Note: This library is intended to be used on **[Class C](https://en.wikipedia.org/wiki/Classful_network#Classful_addressing_definition)** networks.

This project is a rework of already existing [ping_discover_network](https://pub.dev/packages/ping_discover_network), however it is no longer maintained.

[pub.dev page](https://pub.dev/packages/lan_scanner) | [API reference](https://pub.dev/documentation/lan_scanner/latest/)

## Getting Started

Add the package to your pubspec.yaml:

```yaml
lan_scanner: ^2.0.0
```

Import the library:

```dart
import 'package:lan_scanner/lan_scanner.dart';
```

Create an instance of the class and call
[`quickScan()`](https://pub.dev/documentation/lan_scanner/latest/lan_scanner/LanScanner/quickScan.html) or [`preciseScan()`](https://pub.dev/documentation/lan_scanner/latest/lan_scanner/LanScanner/preciseScan.html) on it:

```dart
final port = 80;
final subnet = "192.168.0";
final timeout = Duration(seconds: 5);

final scanner = LanScanner();

final stream = scanner.preciseScan(
    subnet,
    timeout: timeout,
    progressCallback: (ProgressModel progress) {
        print('${progress.percent * 100}% 192.168.0.${progress.currIP}');
    },
);

stream.listen((DeviceModel device) {
    if (device.exists) {
        print("Found device on ${device.ip}:${device.port}");
    }
});
```

If you don't know what is your subnet, you can use [network_info_plus](https://pub.dev/packages/network_info_plus) and then `ipToSubnet()` function.

```dart
var wifiIP = await (NetworkInfo().getWifiIP())

var subnet = ipToSubnet(wifiIP);
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/ivirtex/lan_scanner).

[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/ivirtex/lan_scanner)
