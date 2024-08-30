import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  String broker;
  final int port = 1883;
  final String clientIdentifier = 'flutter_client';

  MqttServerClient? client;
  String? _topic;

  MQTTService({required this.broker});

  Future<void> connect() async {
    client = MqttServerClient(broker, clientIdentifier);
    client!.port = port;
    client!.logging(on: true);
    client!.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      print('Connected to $broker');
    } on Exception catch (e) {
      print('Failed to connect: $e');
      client!.disconnect();
      rethrow;
    }
  }

  void disconnect() {
    client?.disconnect();
  }

  void setTopic(String topic) {
    _topic = topic;
  }

  Future<String> sendOrder(String order) async {
    if (_topic == null || _topic!.isEmpty) {
      return 'Topic is not set!';
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(order);
    try {
      client?.publishMessage(_topic!, MqttQos.exactlyOnce, builder.payload!);
      return 'Order "$order" sent to $_topic successfully';
    } catch (e) {
      return 'Failed to send order: $e';
    }
  }
}
