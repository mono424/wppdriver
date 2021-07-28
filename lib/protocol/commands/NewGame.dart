import 'package:wppdriver/protocol/Command.dart';
import 'package:wppdriver/protocol/model/GameType.dart';

class NewGame extends Command<void> {
  final String code = "NG";

  final GameType gameType;
  final bool waitingForMove;

  NewGame(this.gameType, this.waitingForMove);
  
  Future<String> messageBuilder() async {
    return code 
      + gameType.index.toString()
      + (waitingForMove ? "Y" : "N");
  }
}