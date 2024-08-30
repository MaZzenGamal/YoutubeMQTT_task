import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/details_text_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetails extends StatelessWidget {
  final YoutubeMetaData videoMetaData; // Pass videoMetaData through the constructor

  const VideoDetails({super.key, required this.videoMetaData});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsTextWidget(title: 'Title',value:  videoMetaData.title),
        const SizedBox(height: 10),
        DetailsTextWidget(title: 'Channel',value:  videoMetaData.author),
        const SizedBox(height: 10),
        DetailsTextWidget(title:  'Video Id',value:  videoMetaData.videoId),
        const SizedBox(height: 10),
      ],
    );
  }
}