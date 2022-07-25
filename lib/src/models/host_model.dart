/// Represents a device in the network
class HostModel {
  /// Constructor for a device address
  HostModel({
    required this.ip,
    required this.isReachable,
    this.pingTime,
    this.errorCode,
  });

  /// The IP address of the device
  final String ip;

  /// Reachability status of the device
  final bool isReachable;

  /// Time it took to reach the device
  final Duration? pingTime;

  /// The optional error code if the device didn't respond
  final int? errorCode;
}
