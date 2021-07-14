// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:lan_scanner/lan_scanner.dart';

void main() {
  test('ipToSubnet() converts IP to class C subnet', () {
    expect(ipToSubnet('192.168.0.1'), '192.168.0');
  });
}
