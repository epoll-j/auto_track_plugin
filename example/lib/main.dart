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
            samplingRate: 0.9, // 采样率
            eventHandler: (model) => {print('event handler ${model.type}')},
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

    // AutoTrack().updateSampleRate(0.5); 更新采样率
    // AutoTrack().updateUserId('xxxxxx'); 用户登录后设置用户id
    //
    // 采样错误信息
    // FlutterError.onError = (details) {
    //   Track.instance.reportError(details, details.stack!);
    // };
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
