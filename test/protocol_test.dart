import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:wppdriver/WPPCommunicationClient.dart';
import 'package:wppdriver/WPPDriver.dart';
import 'package:wppdriver/protocol/model/GameEndType.dart';
import 'package:wppdriver/protocol/model/GameType.dart';

class MockWPPCommunicationClient extends Mock implements WPPCommunicationClient {}

@GenerateMocks([WPPCommunicationClient])
void main() {
  group('Handshake', () {
    
    test('handshake request is sent and response is parsed right', () async {
      final handshakeRequest = [
        ..."H0010023".codeUnits, 0xA
      ];
      final handshakeResponse = [
        ..."H101     1.2MY_SERIAL".codeUnits, 0xA
      ];

      final client = MockWPPCommunicationClient();
      when(client.receiveStream).thenAnswer((_) => Stream.value(handshakeResponse));
      when(client.send(any)).thenAnswer((_) async {});

      final driver = WPPDriver();
      await driver.init(client, 35, initialDelay: Duration.zero);

      verify(client.send(handshakeRequest)).called(1);
      expect(driver.deviceHandshake.boardSerial, "MY_SERIAL");
      expect(driver.deviceHandshake.boardVersion, "1.2");
    });

  });

  group('AppGameMessages', () {
    MockWPPCommunicationClient client;
    WPPDriver driver;

    setUp(() async {
      final handshakeResponse = [
        ..."H101     1.2MY_SERIAL".codeUnits, 0xA
      ];

      client = MockWPPCommunicationClient();
      when(client.receiveStream).thenAnswer((_) => Stream.value(handshakeResponse));
      when(client.send(any)).thenAnswer((_) async {});

      driver = WPPDriver();
      await driver.init(client, 35, initialDelay: Duration.zero);
    });
    
    test('new game is sent valid', () async {
      await driver.newGame(GameType.whitePawnOnlineGame, true);

      final validReponse = [
        ..."NG2Y".codeUnits, 0xA
      ];

      verify(client.send(validReponse)).called(1);
    });

    test('game ended is sent valid', () async {
      await driver.gameEnded(GameEndType.checkmate);

      final validReponse = [
        ..."GE1".codeUnits, 0xA
      ];

      verify(client.send(validReponse)).called(1);
    });

    test('new move on app is sent valid', () async {
      await driver.newMove("e2e4");

      final validReponse = [
        ..."MA e2e4".codeUnits, 0xA
      ];

      verify(client.send(validReponse)).called(1);
    });

    test('new castleing move on app is sent valid', () async {
      await driver.newMove("0-0-0");

      final validReponse = [
        ..."MA0-0-0".codeUnits, 0xA
      ];

      verify(client.send(validReponse)).called(1);
    });

  });

  group('BoardGameMessages', () {
    StreamController<List<int>> boardInputController = StreamController<List<int>>();
    Stream boardInputStream = boardInputController.stream.asBroadcastStream();
    MockWPPCommunicationClient client;
    WPPDriver driver;
    Stream moveStream;

    setUp(() async {
      final handshakeResponse = [
        ..."H101     1.2MY_SERIAL".codeUnits, 0xA
      ];

      client = MockWPPCommunicationClient();
      when(client.receiveStream).thenAnswer((_) => boardInputStream);
      when(client.send(any)).thenAnswer((_) async {});

      boardInputController.add(handshakeResponse);

      driver = WPPDriver();
      await driver.init(client, 35, initialDelay: Duration.zero);
      moveStream = driver.getBoardMovesStream().asBroadcastStream();
    });
    
    test('move is sent from the board', () async {
      final boardMessage = [
        ..."MB a2a4".codeUnits, 0xA
      ];

      boardInputController.add(boardMessage);
      expect(await moveStream.first, "a2a4");
    });

    test('castling move is sent from the board', () async {
      final boardMessage = [
        ..."MB0-0-0".codeUnits, 0xA
      ];

      boardInputController.add(boardMessage);
      expect(await moveStream.first, "0-0-0");
    });

  });
}