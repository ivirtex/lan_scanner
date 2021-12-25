/// Represents a device in the network
class HostModel {
  /// Constructor for a device address
  HostModel({
    this.ip,
    this.errorCode,
  });

  /// The IP address of the device
  final String? ip;

  /// The optional error code if the device didn't respond
  final int? errorCode;
}
