import 'dart:io';

/// Represents a device in the network
class HostModel {
  /// Constructor for a device address
  HostModel({
    required this.internetAddress,
    this.pingTime,
  });

  /// The IP address of the device
  final InternetAddress internetAddress;

  /// Time it took to reach the device
  final Duration? pingTime;
}
