import 'dart:async';
import 'package:wppdriver/WPPCommunicationClient.dart';
import 'package:wppdriver/WPPMessage.dart';
import 'package:wppdriver/protocol/commands/Handshake.dart';
import 'package:wppdriver/protocol/commands/NewMoveOnBoard.dart';
import 'package:wppdriver/protocol/model/HandshakeResponseData.dart';
import 'package:wppdriver/protocol/model/RequestConfig.dart';

class WPPDriver {
  
  static int protocolVersion = 1;

  WPPCommunicationClient _client;

  StreamController _inputStreamController;
  Stream<WPPMessage> _inputStream;
  List<int> _buffer;
  HandshakeResponseData _deviceHandshakeData;

  HandshakeResponseData get deviceHandshake => _deviceHandshakeData;

  WPPDriver();

  Future<void> init(WPPCommunicationClient client, int appBuild, { Duration initialDelay = const Duration(milliseconds: 300) }) async {
    _client = client;

    _client.receiveStream.listen(_handleInputStream);
    _inputStreamController = new StreamController<WPPMessage>();
    _inputStream = _inputStreamController.stream.asBroadcastStream();

    await Future.delayed(initialDelay);

    _deviceHandshakeData = await _performHandshake(appBuild);
  }

  void _handleInputStream(List<int> chunk) {
    if (_buffer == null)
      _buffer = chunk.toList();
    else
      _buffer.addAll(chunk);

    if (_buffer.length > 1000) {
      _buffer.removeRange(0, _buffer.length - 1000);
    }

    do {
      try {
        WPPMessage message = WPPMessage.parse(_buffer);
        _inputStreamController.add(message);
        _buffer.removeRange(0, message.getLength());
      } on WPPUncompleteMessage {
        break;
      } catch (err) {
        print("Unknown parse-error: " + err.toString());
        break;
      }
    } while (_buffer.length > 0);
  }

  Stream<WPPMessage> getInputStream() {
    return _inputStream;
  }

  void skipBadBytes(int start, List<int> buffer) {
    buffer.removeRange(0, start);
  }

  Stream<String> getBoardMovesStream() {
    return getInputStream()
        .where(
            (WPPMessage msg) => msg.getCode() == NewMoveOnBoard().code)
        .map((WPPMessage msg) => NewMoveOnBoard().process(msg.getPayload()));
  }

  Future<HandshakeResponseData> _performHandshake(int appBuild, { RequestConfig config = const RequestConfig() }) {
    return Handshake(protocolVersion, appBuild).request(_client, _inputStream, config);
  }

}
