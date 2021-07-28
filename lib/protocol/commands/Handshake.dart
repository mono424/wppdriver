import 'package:wppdriver/protocol/Answer.dart';
import 'package:wppdriver/protocol/Command.dart';
import 'package:wppdriver/protocol/model/HandshakeResponseData.dart';

class Handshake extends Command<HandshakeResponseData> {
  final String code = "H0";
  final Answer<HandshakeResponseData> answer = HandshakeAnswer();

  final int protocolVersion;
  final int appBuild;

  Handshake(this.protocolVersion, this.appBuild);
  
  Future<String> messageBuilder() async {
    return code 
      + protocolVersion.toRadixString(16).padLeft(2, '0').substring(0, 2)
      + appBuild.toRadixString(16).padLeft(4, '0').substring(0, 4);
  }
}

class HandshakeAnswer extends Answer<HandshakeResponseData> {
  final String code = "H1";

  @override
  HandshakeResponseData process(String payload) {
    int protocolVersion = int.parse(payload[0] + payload[1], radix: 16);
    String boardVersion = payload.substring(2, 10);
    String serialNumber = payload.substring(10);
    return HandshakeResponseData(protocolVersion, boardVersion, serialNumber);
  }
}