import 'dart:async';

class WPPCommunicationClient {
  final Future<void> Function(List<int>) _send;
  final StreamController<List<int>> _inputStreamController = StreamController<List<int>>();

  Stream<List<int>> get receiveStream {
    return _inputStreamController.stream.asBroadcastStream();
  }

  WPPCommunicationClient(this._send);

  Future<void> send(List<int> message) {
    return _send(message);
  }

  void handleReceive(List<int> message) {
    _inputStreamController.add(message);
  }
}