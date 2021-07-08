/// Represents a device in the network
class DeviceAddress {
  DeviceAddress({
    required this.exists,
    this.ip,
    this.port,
    this.errorCode,
  });

  final bool exists;
  final String? ip;
  final int? port;
  final int? errorCode;
}
