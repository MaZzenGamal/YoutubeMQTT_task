import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube/features/mqtt/presentation/views/mqtt_view.dart';
import 'package:youtube/features/youtube/presentation/views/youtube_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  InAppWebViewPlatform.instance ;
  runApp(const YoutubeTask());
}

class YoutubeTask extends StatelessWidget {
  const YoutubeTask({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Player Flutter',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.blueAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
        ),
      ),
      home: YoutubeView(),
    );
  }
}


