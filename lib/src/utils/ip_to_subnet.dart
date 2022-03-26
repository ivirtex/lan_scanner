/// Converts traditional IPv4 address to the subnet
/// of Class C network
String ipToCSubnet(String ip) {
  return ip.substring(0, ip.lastIndexOf('.'));
}
