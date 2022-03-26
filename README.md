# lan_scanner

[Dart](https://dart.dev) / [Flutter](https://flutter.dev) package that allows discovering network devices in local network ([LAN](https://en.wikipedia.org/wiki/Local_area_network)) via multi-threaded ICMP pings.

Note: This library is intended to be used on **[Class C](https://en.wikipedia.org/wiki/Classful_network#Classful_addressing_definition)** networks.

**Warning:**  
iOS platform is currently not supported.
This is due to a compatibility issue with the underlying ping library.  
Blocking factors:  
[Issue #1](https://github.com/point-source/dart_ping/issues/6)  
[Issue #2](https://github.com/dart-lang/sdk/issues/37022)

Due to my exams, I won't have much time to work on this for the next 2 to 3 months, but if you have any suggestions on how to make a workaround for iOS, please let me know.

[pub.dev page](https://pub.dev/packages/lan_scanner) | [API reference](https://pub.dev/documentation/lan_scanner/latest/)

## Getting Started

Add the package to your pubspec.yaml:

```yaml
lan_scanner: ^3.4.0
```

Import the library:

```dart
import 'package:lan_scanner/lan_scanner.dart';
```

Create an instance of the class and call
[`icmpScan()`](https://pub.dev/documentation/lan_scanner/latest/lan_scanner/LanScanner/icmpScan.html) on it:

```dart
final scanner = LanScanner();

final stream = scanner.icmpScan('192.168.0', progressCallback: (progress) {
    print('Progress: $progress');
});

stream.listen((HostModel device) {
    print("Found host: ${device.ip}");
});
```

If you don't know what is your subnet, you can use [network_info_plus](https://pub.dev/packages/network_info_plus) and then `ipToCSubnet()` function.

```dart
var wifiIP = await NetworkInfo().getWifiIP()

var subnet = ipToCSubnet(wifiIP);
```

## Features, bugs and contributions

Feel free to contribute to this project.

Please file feature requests and bugs at the [issue tracker](https://github.com/ivirtex/lan_scanner).
If you fixed a bug or implemented a feature by yourself, feel free to send a [pull request](https://github.com/ivirtex/lan_scanner/pulls).

## Sponsoring

I am working on my packages in my free time.

If this package is helping you, please consider [buying me a coffee](ko-fi.com/ivirtex), so I can keep updating and maintaining this package.
