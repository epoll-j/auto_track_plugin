import 'package:auto_track/auto_track/config/queue.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';

class AutoTrackConfigManager {
  static final AutoTrackConfigManager instance = AutoTrackConfigManager._();
  AutoTrackConfigManager._();

  AutoTrackConfig _config = AutoTrackConfig();
  AutoTrackConfig get config => _config;

  bool _autoTrackEnable = false;
  bool get autoTrackEnable => _autoTrackEnable;

  void updateConfig(AutoTrackConfig config) {
    _config = config;
    if (config.enableUpload) {
      AutoTrackQueue.instance.start();
    } else {
      AutoTrackQueue.instance.stop();
    }
  }

  void updateUserId(String userId) {
    _config.userId = userId;
  }

  void updatePageConfigs(List<AutoTrackPageConfig> pageConfigs) {
    _config.pageConfigs = pageConfigs;
  }

  void updateIgnoreElementKeys(List<Key> ignoreElementKeys) {
    _config.ignoreElementKeys = ignoreElementKeys;
  }

  void updateIgnoreElementStringKeys(List<String> ignoreElementStringKeys) {
    _config.ignoreElementStringKeys = ignoreElementStringKeys;
  }

  void enablePageView(bool enable) {
    _config.enablePageView = enable;
  }

  void enablePageLeave(bool enable) {
    _config.enablePageLeave = enable;
  }

  void enableClick(bool enable) {
    _config.enableClick = enable;
  }

  void enableAutoTrack(bool enable) {
    _autoTrackEnable = enable;
  }

  void enableUpload(bool enable) {
    _config.enableUpload = enable;
    if (enable) {
      AutoTrackQueue.instance.start();
    } else {
      AutoTrackQueue.instance.stop();
    }
  }

  List<AutoTrackPageConfig> get pageConfigs => _config.pageConfigs;

  bool get useCustomRoute => _config.useCustomRoute;

  AutoTrackPageConfig getPageConfig(Widget pageWidget) {
    return _config.pageConfigs.firstWhere(
            (pageConfig) => pageConfig.isPageWidget!(pageWidget),
        orElse: () => AutoTrackPageConfig()
    );
  }

  Set<Key> getIgnoreElementKeySet() => _config.getIgnoreElementKeySet();

  Set<String> getIgnoreElementStringKeySet() => _config.getIgnoreElementStringKeySet();

  bool isIgnoreElement(Key? key) {
    if (key == null) {
      return false;
    }
    if (getIgnoreElementKeySet().contains(key)) {
      return true;
    }
    if (getIgnoreElementStringKeySet().contains(key.toString())) {
      return true;
    }
    return false;
  }

  bool get pageViewEnabled => _config.enablePageView;

  bool get pageLeaveEnable => _config.enablePageLeave;

  bool get clickEnable => _config.enableClick;
}
