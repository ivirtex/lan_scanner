// Dart imports:
import 'dart:io';

/// Represents a device in the network
class Host {
  /// Constructor for a device address
  Host({
    required this.internetAddress,
    this.pingTime,
  });

  /// The IP address of the device
  final InternetAddress internetAddress;

  /// Time it took to reach the device
  final Duration? pingTime;
}
