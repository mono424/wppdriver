import 'package:wppdriver/protocol/Answer.dart';

class NewMoveOnBoard extends Answer<String> {
  final String code = "MB";

  @override
  String process(String payload) {
    return payload.trim();
  }
}