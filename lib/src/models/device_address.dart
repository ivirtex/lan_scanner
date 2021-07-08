class DeviceAddress {
  DeviceAddress({
    required this.exists,
    this.ip,
    this.port,
  });

  final bool exists;
  final String? ip;
  final int? port;
}
