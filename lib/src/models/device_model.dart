/// Represents a device in the network
class DeviceModel {
  /// Constructor for a device address
  DeviceModel({
    required this.exists,
    this.ip,
    this.port,
    this.errorCode,
  });

  /// Determines if the device exists
  final bool exists;

  /// The IP address of the device
  final String? ip;

  /// The port of the device
  final int? port;

  /// The optional error code if the device didn't respond
  final int? errorCode;
}
