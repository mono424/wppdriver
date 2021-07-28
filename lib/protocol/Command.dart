import 'package:wppdriver/WPPCommunicationClient.dart';
import 'package:wppdriver/WPPMessage.dart';
import 'package:wppdriver/protocol/Answer.dart';
import 'package:wppdriver/protocol/model/RequestConfig.dart';

abstract class Command<T> {
  String code;
  Answer<T> answer;

  Future<String> messageBuilder() async {
    return code;
  }

  Future<void> send(WPPCommunicationClient client) async {
    String messageString = await messageBuilder();
    List<int> message = [...messageString.codeUnits, 0xA];
    await client.send(message);
  }

  Future<T> request(
    WPPCommunicationClient client,
    Stream<WPPMessage> inputStream,
    [RequestConfig config = const RequestConfig()]
  ) async {
    Future<T> result = getReponse(inputStream);
    try {
      await send(client);
      T resultValue = await result.timeout(config.timeout);
      return resultValue;
    } catch (e) {
      if (config.retries <= 0) {
        throw e;
      }
      await Future.delayed(config.retryDelay);
      return request(client, inputStream, config.withDecreasedRetry());
    }
  }

  Future<T> getReponse(Stream<WPPMessage> inputStream) async {
    if (answer == null) return null;
    WPPMessage message = await inputStream
        .firstWhere((WPPMessage msg) => msg.checkCode(answer.code));
    return answer.process(message.getPayload());
  }
}