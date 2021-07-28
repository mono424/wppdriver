import 'package:wppdriver/protocol/Command.dart';

class NewMoveOnApp extends Command<void> {
  final String code = "MA";

  final String movePgn;

  NewMoveOnApp(this.movePgn);
  
  Future<String> messageBuilder() async {
    return code 
      + movePgn.padLeft(5).substring(0, 5);
  }
}