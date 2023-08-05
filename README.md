# lan_scanner

[![pub.dev badge](https://img.shields.io/pub/v/lan_scanner)](https://pub.dev/packages/lan_scanner)
![GitHub build status](https://img.shields.io/github/actions/workflow/status/ivirtex/lan_scanner/dart.yml)

[Dart](https://dart.dev) / [Flutter](https://flutter.dev) package that allows discovering network devices in local network ([LAN](https://en.wikipedia.org/wiki/Local_area_network)) via multi-threaded ICMP pings.

Note: This library is intended to be used on **[Class C](https://en.wikipedia.org/wiki/Classful_network#Classful_addressing_definition)** networks.

[pub.dev page](https://pub.dev/packages/lan_scanner) | [API reference](https://pub.dev/documentation/lan_scanner/latest/)

## Getting Started

Add the package to your pubspec.yaml:

```yaml
lan_scanner: ^4.0.0
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

If you don't know what subnet to provide, you can use [network_info_plus](https://pub.dev/packages/network_info_plus) to get your local IP and then `ipToCSubnet()` function, which will conviently strip the last octet of the IP address:

```dart
// 192.168.0.1
var wifiIP = await NetworkInfo().getWifiIP()

// 192.168.0
var subnet = ipToCSubnet(wifiIP);
```

## iOS compatibility

Due to the issue with Flutter platform channels ([#119207](https://github.com/flutter/flutter/issues/119207)), iOS platform is currently supported only when using the `quickIcmpScanSync()` method and requires additional steps:

Add `dart_ping_ios` to your `pubspec.yaml`:

```yaml
dart_ping_ios: ^4.0.0
```

Call `register()` method before running your app:

```dart
void main() {
  DartPingIOS.register();

  runApp(const App());
}
```

## Configuration

**Warning:**  
In order to use this package, you may need to do additional configuration on some platforms.

Android:  
Add the `android.permission.INTERNET` to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

MacOS:  
Add following key to `DebugProfile.entitlements` and `Release.entitlements` files:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## Features, bugs and contributions

Feel free to contribute to this project.

Please file feature requests and bugs at the [issue tracker](https://github.com/ivirtex/lan_scanner).  
If you fixed a bug or implemented a feature by yourself, feel free to send a [pull request](https://github.com/ivirtex/lan_scanner/pulls).

## Sponsoring

I am working on my packages in my free time.

If this package is helping you, please consider [buying me a coffee](https://ko-fi.com/ivirtex), so I can keep updating and maintaining this package.
