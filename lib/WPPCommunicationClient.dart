import 'dart:async';

class WPPCommunicationClient {
  final Future<void> Function(List<int>) send;
  final StreamController<List<int>> _inputStreamController = StreamController<List<int>>();

  Stream<List<int>> get receiveStream {
    return _inputStreamController.stream.asBroadcastStream();
  }

  WPPCommunicationClient(this.send);

  void handleReceive(List<int> message) {
    _inputStreamController.add(message);
  }
}