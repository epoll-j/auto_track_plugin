import 'package:flutter_test/flutter_test.dart';
import 'package:auto_track/auto_track.dart';
import 'package:auto_track/auto_track_platform_interface.dart';
import 'package:auto_track/auto_track_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAutoTrackPlatform
    with MockPlatformInterfaceMixin
    implements AutoTrackPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AutoTrackPlatform initialPlatform = AutoTrackPlatform.instance;

  test('$MethodChannelAutoTrack is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAutoTrack>());
  });

  test('getPlatformVersion', () async {
    AutoTrack autoTrackPlugin = AutoTrack();
    MockAutoTrackPlatform fakePlatform = MockAutoTrackPlatform();
    AutoTrackPlatform.instance = fakePlatform;

    // expect(await autoTrackPlugin.getPlatformVersion(), '42');
  });
}
