import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:wppdriver/WPPCommunicationClient.dart';
import 'package:wppdriver/WPPDriver.dart';

class MockWPPCommunicationClient extends Mock implements WPPCommunicationClient {}

@GenerateMocks([WPPCommunicationClient])
void main() {
  group('Handshake', () {
    
    test('valid handshake request is sent by driver', () {
      final client = MockWPPCommunicationClient();
      when(client.receiveStream).thenAnswer((_) => new Stream.empty());

      final message = [
        ..."H0010023".codeUnits, 0xA
      ];

      final driver = WPPDriver();
      driver.init(client, 35);

      verify(client.send(message));
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