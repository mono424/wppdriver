import 'package:wppdriver/protocol/Command.dart';
import 'package:wppdriver/protocol/model/GameEndType.dart';

class GameEnded extends Command<void> {
  final String code = "GE";

  final GameEndType gameEndType;

  GameEnded(this.gameEndType);
  
  Future<String> messageBuilder() async {
    return code 
      + gameEndType.index.toString();
  }
}