import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auto_track_method_channel.dart';

abstract class AutoTrackPlatform extends PlatformInterface {
  /// Constructs a AutoTrackPlatform.
  AutoTrackPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoTrackPlatform _instance = MethodChannelAutoTrack();

  /// The default instance of [AutoTrackPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutoTrack].
  static AutoTrackPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AutoTrackPlatform] when
  /// they register themselves.
  static set instance(AutoTrackPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
