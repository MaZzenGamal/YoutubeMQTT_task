import 'package:flutter/material.dart';

import '../../../../core/services/mqtt_service.dart';


class MqttView extends StatefulWidget {
  const MqttView({super.key});

  @override
    State<MqttView> createState() => _MqttViewState();
}

class _MqttViewState extends State<MqttView> {
  late MQTTService mqttService;
  final TextEditingController topicController = TextEditingController();
  String statusMessage = '';
  String connectionStatus = 'Disconnected';
  bool isConnected = false;
  String selectedBroker = 'broker.hivemq.com';

  final List<String> brokers = [
    'broker.hivemq.com',
    'test.mosquitto.org',
    'mqtt.eclipse.org',
  ];

  @override
  void initState() {
    super.initState();
    mqttService = MQTTService(broker: selectedBroker);
  }

  @override
  void dispose() {
    mqttService.disconnect();
    topicController.dispose();
    super.dispose();
  }

  void _connect() async {
    setState(() {
      statusMessage = 'Connecting...';
      connectionStatus = 'Connecting';
      isConnected = false;
    });
    try {
      await mqttService.connect();
      setState(() {
        statusMessage = 'Connected to $selectedBroker';
        connectionStatus = 'Connected';
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Connection failed: $e';
        connectionStatus = 'Disconnected';
        isConnected = false;
      });
    }
  }

  void _disconnect() {
    mqttService.disconnect();
    setState(() {
      statusMessage = 'Disconnected from $selectedBroker';
      connectionStatus = 'Disconnected';
      isConnected = false;
    });
  }

  void _sendUpOrder() async {
    mqttService.setTopic(topicController.text);
    String result = await mqttService.sendOrder('up');
    setState(() {
      statusMessage = result;
    });
  }

  void _switchBroker(String? broker) {
    if (broker != null && broker != selectedBroker) {
      selectedBroker = broker;
      mqttService = MQTTService(broker: selectedBroker);
      setState(() {
        statusMessage = 'Broker switched to $selectedBroker';
        connectionStatus = 'Disconnected'; // Reset connection status
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Client'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBroker,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.teal,
              items: brokers.map((String broker) {
                return DropdownMenuItem<String>(
                  value: broker,
                  child: Text(broker, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: _switchBroker,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.cancel,
                          color: isConnected ? Colors.green : Colors.red,
                          size: 24.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Status: $connectionStatus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: topicController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Topic',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.topic),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _connect,
                            icon: const Icon(Icons.wifi),
                            label: const Text('Connect'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _disconnect,
                            icon: const Icon(Icons.wifi_off),
                            label: const Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendUpOrder,
              icon: const Icon(Icons.send),
              label: const Text('Send "Up" Command'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: statusMessage.contains('Failed') || statusMessage.contains('Disconnected')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
