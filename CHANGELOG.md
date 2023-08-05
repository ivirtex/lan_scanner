# Changelog

## 4.0.0

- Updated `dart_ping` to 9.0.0, which fixes bug on Windows ([Thanks, RikitoNoto](https://github.com/ivirtex/lan_scanner/pull/11)).
- `HostModel` now uses `InternetAddress` type instead of `String` for address.
- Added `quickIcmpScanSync()` and `quickIcmpScanAsync` methods.
- Added initial support for iOS.
- Added support for Dart 3.
- Changed debug logging method.
- Updated README to include configuration instructions for MacOS.
- Refactored code.
- Updated example.

## 3.5.0

- Fixed new linter warnings.
- Bumped `dart_ping` to 7.0.0
- Updated documentation to mention required permission ([Thanks, DamnDaniel-98](https://github.com/ivirtex/lan_scanner/issues/4)).

## 3.4.1

- Fixed a bug that caused the stream not to close.

## 3.4.0

- Renamed `ipToSubnet()` to `ipToCSubnet()`.
- Added new example.
- Updated documentation.

## 3.3.0

- Renamed `scanSpeed` property to `scanThreads`.
- Implemented barrel pattern for source files.
- `subnet` parameter in `icmpScan()` is now required.
- Updated documentation.

## 3.2.0

- `ProgressCallback` now uses double instead of string.

## 3.1.1

- Updated export file to include `ProgressCallback` class.

## 3.1.0

- Switched to a more reliable ping plugin.
- Added timeout argument to `icmpScan()`.
- Increased concurrent scanning threads count to 10.
- Fixed a bug that caused the stream not to close.
- Updated example.

## 3.0.2

- Updated README.md.

## 3.0.1

- Fixed package description.

## 3.0.0

- The library now makes use of multi-threading to speed up the scanning process multiple times.
- The `quickScan()` and `preciseScan()` no longer are available.
- Changed name of `DeviceModel` to `HostModel`.
- Updated docs.
- Updated lint version.
- Updated example.

## 2.0.1

- Updated pubspec.yaml in the example
- Updated README.md
- Updated lint package to 1.6.0

## 2.0.0

- Changed name of `DeviceAddress` to `DeviceModel`.
- `ProgressCallback` now return a `ProgressModel` instead of a String.
- preciseScan() now uses StreamController instead of generator function.
- Fix typos.
- Bug fixes.
- Updated docs.
- Updated example.

## 1.0.3

- Added lint rules.
- Updated docs.

## 1.0.2

- Changed main dependency to support iOS.
- Updated docs.

## 1.0.1

- Updated docs.

## 1.0.0

- Initial release.
