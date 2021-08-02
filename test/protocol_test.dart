import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:wppdriver/WPPCommunicationClient.dart';
import 'package:wppdriver/WPPDriver.dart';

class MockWPPCommunicationClient extends Mock implements WPPCommunicationClient {}

@GenerateMocks([WPPCommunicationClient])
void main() {
  group('Handshake', () {
    
    test('handshake response is parsed right', () async {
      final handshakeResponse = [
        ..."H101     1.2MY_SERIAL".codeUnits, 0xA
      ];

      final client = MockWPPCommunicationClient();
      when(client.receiveStream).thenAnswer((_) => Stream.value(handshakeResponse));
      when(client.send).thenAnswer((_) => (List<int> message) async {});

      final driver = WPPDriver();
      await driver.init(client, 35, initialDelay: Duration.zero);

      verify(client.send).called(1);
      expect(driver.deviceHandshake.boardSerial, "MY_SERIAL");
      expect(driver.deviceHandshake.boardVersion, "1.2");
    });

    test('.trim() removes surrounding whitespace', () {
      var string = '  foo ';
      expect(string.trim(), equals('foo'));
    });
  });

  group('int', () {
    test('.remainder() returns the remainder of division', () {
      expect(11.remainder(3), equals(2));
    });

    test('.toRadixString() returns a hex string', () {
      expect(11.toRadixString(16), equals('b'));
    });
  });
}