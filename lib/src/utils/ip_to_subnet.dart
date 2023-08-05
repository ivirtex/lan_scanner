/// Converts traditional IPv4 address to the subnet
/// of Class C network
String ipToCSubnet(String ip) {
  if (!ip.contains('.')) {
    throw Exception('Invalid or empty string has been provided: $ip');
  }

  return ip.substring(0, ip.lastIndexOf('.'));
}
