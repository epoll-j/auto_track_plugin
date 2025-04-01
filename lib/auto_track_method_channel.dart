import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auto_track_platform_interface.dart';

/// An implementation of [AutoTrackPlatform] that uses method channels.
class MethodChannelAutoTrack extends AutoTrackPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('auto_track');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<void> enableNativeCrash() async {
    return await methodChannel.invokeMethod('enableNativeCrashHandler');
  }

  Future<String?> getLastCrashReport() async {
    return await methodChannel.invokeMethod('getLastCrashReport');
  }

  Future<void> cleanCrashReport() async {
    return await methodChannel.invokeMethod('cleanCrashReports');
  }

  Future<void> testCrash() async {
    return await methodChannel.invokeMethod('testCrash');
  }
}
