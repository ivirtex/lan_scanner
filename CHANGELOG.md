# Changelog

## 3.1.1

* Updated export file to include ProgressCallback class.

## 3.1.0

* Switched to a more reliable ping plugin.
* Added timeout argument to icmpScan().
* Increased concurrent scanning threads count to 10.
* Fixed a bug that caused the stream not to close.
* Updated example.

## 3.0.2

* Updated README.md.

## 3.0.1

* Fixed package description.

## 3.0.0

* The library now makes use of multi-threading to speed up the scanning process multiple times.
* The quickScan() and preciseScan() no longer are available.
* Changed name of DeviceModel to HostModel.
* Updated docs.
* Updated lint version.
* Updated example.

## 2.0.1

* Updated pubspec.yaml in the example
* Updated README.md
* Updated lint package to 1.6.0

## 2.0.0

* Changed name of DeviceAddress to DeviceModel
* ProgressCallback now return a ProgressModel instead of a String
* preciseScan() now uses StreamController instead of generator function
* Fix typos
* Bug fixes
* Updated docs
* Updated example

## 1.0.3

* Added lint rules
* Updated docs

## 1.0.2

* Changed main dependency to support iOS
* Updated docs

## 1.0.1

* Updated docs

## 1.0.0

* Initial release
