import 'package:auto_track/auto_track.dart';
import 'package:auto_track_example/home.dart';
import 'package:auto_track_example/page_a.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AutoTrack()
        .config(AutoTrackConfig(
            eventHandler: (model) => {
              print('event handler ${model.type}')
            },
            pageConfigs: [
              AutoTrackPageConfig<PageA>(
                pageID: 'page_a',
              ),
            ]))
        .enable()
        .enablePageLeave()
        .enablePageView()
        .enableClick()
        .enableDrag()
        .enableIgnoreNullKey()
        .enableLog();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('auto track example app'),
        ),
        body: const Center(
          child: Home(),
        ),
      ),
      navigatorObservers: AutoTrackNavigationObserver.wrap([]),
    );
  }
}
