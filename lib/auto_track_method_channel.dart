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
    methodChannel.invokeMethod('getLastCrashReport');
    return version;
  }

  Future<String?> getLastCrashReport() async {
    return await methodChannel.invokeMethod('getLastCrashReport');
  }

  Future<void> cleanCrashReport() async {
    final deviceId = await methodChannel.invokeMethod('cleanCrashReports');
    return deviceId;
  }

  Future<void> testCrash() async {
    final deviceId = await methodChannel.invokeMethod('testCrash');
    return deviceId;
  }
}
