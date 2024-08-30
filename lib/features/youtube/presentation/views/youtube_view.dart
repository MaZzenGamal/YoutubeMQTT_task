import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube/features/youtube/presentation/views/widgets/video_details.dart';
import 'package:youtube/features/mqtt/presentation/views/mqtt_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeView extends StatefulWidget {
  const YoutubeView({super.key});

  @override
  State<YoutubeView> createState() => _YoutubeViewState();
}

class _YoutubeViewState extends State<YoutubeView> {
  late YoutubePlayerController controller;
  late TextEditingController idController;

  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  double volume = 100;
  bool isMuted = false;
  bool isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: 't9ObLFw7N-E',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    idController = TextEditingController();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  void listener() {
    if (isPlayerReady && mounted && !controller.value.isFullScreen) {
      setState(() {
        playerState = controller.value.playerState;
        videoMetaData = controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: buildYoutubePlayer(),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Youtube Player',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    player,
                    const SizedBox(height: 20),
                    VideoDetails(
                      videoMetaData: videoMetaData,
                    ),
                    const SizedBox(height: 20),
                    videoActions(),
                    const SizedBox(height: 20),
                    volumeControl(),
                    const SizedBox(height: 64),
                    const Divider(thickness: 2),
                    const SizedBox(
                      height: 20,
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
                      child: const Text('MQTT client',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  YoutubePlayer buildYoutubePlayer() {
    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.redAccent,
      topActions: <Widget>[
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            controller.metadata.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () {
            log('Settings Tapped!');
          },
        ),
      ],
      onReady: () {
        isPlayerReady = true;
      },
    );
  }

  Widget videoActions() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: isPlayerReady,
            controller: idController,
            decoration: InputDecoration(
              hintText: 'Youtube Link or ID',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => idController.clear(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        loadButton('LOAD'),
        const SizedBox(width: 10),
        IconButton(
          icon:
              Icon(controller.value.isPlaying ? Icons.stop : Icons.play_arrow),
          color: Colors.redAccent,
          onPressed: isPlayerReady
              ? () {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                  setState(() {});
                }
              : null,
        ),
      ],
    );
  }

  Widget volumeControl() {
    return Row(
      children: <Widget>[
        const Text(
          "Volume",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        Expanded(
          child: Slider(
            inactiveColor: Colors.grey[300],
            value: volume,
            min: 0.0,
            max: 100.0,
            divisions: 10,
            label: '${(volume).round()}',
            onChanged: isPlayerReady
                ? (value) {
                    setState(() {
                      volume = value;
                    });
                    controller.setVolume(volume.round());
                  }
                : null,
          ),
        ),
        IconButton(
          icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
          onPressed: isPlayerReady
              ? () {
                  isMuted ? controller.unMute() : controller.mute();
                  setState(() {
                    isMuted = !isMuted;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget loadButton(String action) {
    return ElevatedButton(
      onPressed: isPlayerReady
          ? () {
              if (idController.text.isNotEmpty) {
                var id = YoutubePlayer.convertUrlToId(idController.text) ?? '';
                if (action == 'LOAD') controller.load(id);
                FocusScope.of(context).requestFocus(FocusNode());
              } else {
                showSnackBar('Source can\'t be empty!');
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
      child: Text(
        action,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
