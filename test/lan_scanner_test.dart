// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:lan_scanner/lan_scanner.dart';

// TODO(ivirtex): add more unit tests
void main() {
  test('ipToSubnet() converts IP to class C subnet', () {
    expect(ipToCSubnet('192.168.0.1'), '192.168.0');
  });
}
