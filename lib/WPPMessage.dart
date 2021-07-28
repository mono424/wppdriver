class WPPMessage {
  String _code;
  String _payload;
  int _length;

  WPPMessage.parse(List<int> buffer) {
    do {
      int messageEnd = nextMessageEnd(buffer);
      if (messageEnd == -1) throw WPPUncompleteMessage();
      List<String> message = buffer.sublist(0, messageEnd + 1).map((c) => String.fromCharCode(c)).toList();
      _code = message[0] + message[1];
      _payload = message.sublist(2).join("");
      _length = message.length;
      return;
    } while(true);
    
  }

  int nextMessageEnd(List<int> buffer) {
    return buffer.indexOf(0xA);
  }

  bool checkCode(String code) {
    return code == _code;
  }

  String getCode() {
    return _code;
  }

  int getLength() {
    return _length;
  }

  String getPayload() {
    return _payload;
  }
}

class WPPUncompleteMessage implements Exception {}
