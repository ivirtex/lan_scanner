# lan_scanner

[Dart](https://dart.dev) / [Flutter](https://flutter.dev) package that allows discovering network devices in local network ([LAN](https://en.wikipedia.org/wiki/Local_area_network)) via multi-threaded ICMP pings.

Note: This library is intended to be used on **[Class C](https://en.wikipedia.org/wiki/Classful_network#Classful_addressing_definition)** networks.

[pub.dev page](https://pub.dev/packages/lan_scanner) | [API reference](https://pub.dev/documentation/lan_scanner/latest/)

## Getting Started

Add the package to your pubspec.yaml:

```yaml
lan_scanner: ^3.3.0
```

Import the library:

```dart
import 'package:lan_scanner/lan_scanner.dart';
```

Create an instance of the class and call
[`icmpScan()`](https://pub.dev/documentation/lan_scanner/latest/lan_scanner/LanScanner/icmpScan.html) on it:

```dart
final stream = scanner.icmpScan('192.168.0', progressCallback: (progress) {
    print('Progress: $progress');
});

stream.listen((HostModel device) {
    print("Found host: ${device.ip}");
});
```

If you don't know what is your subnet, you can use [network_info_plus](https://pub.dev/packages/network_info_plus) and then `ipToSubnet()` function.

```dart
var wifiIP = await NetworkInfo().getWifiIP()

var subnet = ipToSubnet(wifiIP);
```

## Features, bugs and contributions

Feel free to contribute to this project.

Please file feature requests and bugs at the [issue tracker](https://github.com/ivirtex/lan_scanner).
If you fixed a bug or implemented feature by yourself, feel free to send a [pull request](https://github.com/ivirtex/lan_scanner/pulls).

## Sponsoring

I am working on my packages on my free time.  
If this package is helping you, please consider [buying me a coffee](https://www.buymeacoffee.com/ivirtex), so I can keep updating and maintaing this package.
