/// Represents predefined errors
abstract class ErrorCodes {
  /// 13: Connection failed (OS Error: Permission denied)
  /// 49: Bind failed (OS Error: Can't assign requested address)
  /// 61: OS Error: Connection refused
  /// 64: Connection failed (OS Error: Host is down)
  /// 65: No route to host
  /// 101: Network is unreachable
  /// 111: Connection refused
  /// 113: No route to host
  /// <empty>: SocketException: Connection timed out
  static final errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];
}
