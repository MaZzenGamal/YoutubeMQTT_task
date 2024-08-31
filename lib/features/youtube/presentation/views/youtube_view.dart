import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../mqtt/presentation/views/mqtt_view.dart';

class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({super.key});

  @override
  State<YoutubePlayer> createState() => _PlayVideoFromYoutubeState();
}

class _PlayVideoFromYoutubeState extends State<YoutubePlayer> {
  late final PodPlayerController controller;
  final videoTextFieldCtr = TextEditingController();
  bool _isLoading = false;
  String _currentVideoUrl = '';
  double _volume = 1.0;
  String initialVideo = 'https://www.youtube.com/watch?v=t9ObLFw7N-E';

  @override
  void initState() {
    super.initState();
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(initialVideo), // Initially no video
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: false,
      ),
    )..initialise();
    _getSystemVolume();
  }

  Future<void> _getSystemVolume() async {
    final volume = await VolumeController().getVolume();
    setState(() {
      _volume = volume;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _setVolume(double volume) {
    VolumeController().setVolume(volume);
    setState(() {
      _volume = volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Player'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  PodVideoPlayer(controller: controller),
                const SizedBox(height: 20),
                _loadVideoFromUrl(),
                const SizedBox(height: 20),
                _volumeControl(),
                const SizedBox(
                  height: 64,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MqttView(),
                      ),
                    );
                  },
                  child: const Text(
                    'MQTT client',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadVideoFromUrl() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: videoTextFieldCtr,
            decoration: InputDecoration(
              labelText: 'Enter YouTube URL/ID',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'https://youtu.be/t9ObLFw7N-E',
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            if (videoTextFieldCtr.text.isEmpty) {
              snackBar('Please enter the URL');
              return;
            }
            setState(() {
              _isLoading = true;
            });
            try {
              snackBar('Loading....');
              FocusScope.of(context).unfocus();
              await controller.changeVideo(
                playVideoFrom: PlayVideoFrom.youtube(videoTextFieldCtr.text),
              );
              setState(() {
                _currentVideoUrl = videoTextFieldCtr.text;
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {
              snackBar('Unable to load,\n $e');
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          child: const Text(
            'Load',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _volumeControl() {
    return Row(
      children: [
        const Text(
          "Volume",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_volume * 100).round()}%',
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
              _setVolume(value); // Call the method to update system volume
            },
          ),
        ),
      ],
    );
  }

  void snackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: Colors.redAccent,
        ),
      );
  }
}
