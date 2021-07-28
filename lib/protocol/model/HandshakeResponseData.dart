class HandshakeResponseData {
  final int protocolVersion;
  final String boardVersion;
  final String boardSerial;

  const HandshakeResponseData(this.protocolVersion, this.boardVersion, this.boardSerial);
}