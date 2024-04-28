import 'package:auto_track/auto_track/drag/drag_pointer_event_listener.dart';
import 'package:flutter/foundation.dart';

import 'click/pointer_event_listener.dart';
import 'config/config.dart';
import 'config/manager.dart';
import 'log/logger.dart';

class AutoTrack {
  static final AutoTrack _instance = AutoTrack._();
  AutoTrack._();

  factory AutoTrack({ AutoTrackConfig? config }) {
    _instance.config(config);
    return _instance;
  }

  void updateUserId(String id) {
    AutoTrackConfigManager.instance.updateUserId(id);
  }

  AutoTrack config(AutoTrackConfig? config) {
    if (config != null) {
      AutoTrackConfigManager.instance.updateConfig(config);
    }
    return _instance;
  }

  AutoTrack pageConfigs(List<AutoTrackPageConfig>? pageConfigs) {
    if (pageConfigs != null) {
      AutoTrackConfigManager.instance.updatePageConfigs(pageConfigs);
    }
    return _instance;
  }

  AutoTrack ignoreElementKeys(List<Key>? ignoreElementKeys) {
    if (ignoreElementKeys != null) {
      AutoTrackConfigManager.instance.updateIgnoreElementKeys(ignoreElementKeys);
    }
    return _instance;
  }

  AutoTrack ignoreElementStringKeys(List<String>? ignoreElementStringKeys) {
    if (ignoreElementStringKeys != null) {
      AutoTrackConfigManager.instance.updateIgnoreElementStringKeys(ignoreElementStringKeys);
    }
    return _instance;
  }

  AutoTrack enablePageView() {
    AutoTrackConfigManager.instance.enablePageView(true);
    return _instance;
  }

  AutoTrack disablePageView() {
    AutoTrackConfigManager.instance.enablePageView(false);
    return _instance;
  }

  AutoTrack enablePageLeave() {
    AutoTrackConfigManager.instance.enablePageLeave(true);
    return _instance;
  }

  AutoTrack disablePageLeave() {
    AutoTrackConfigManager.instance.enablePageLeave(false);
    return _instance;
  }

  AutoTrack enableIgnoreNullKey() {
    AutoTrackConfigManager.instance.enableIgnoreNullKey(true);
    return _instance;
  }

  AutoTrack disableIgnoreNullKey() {
    AutoTrackConfigManager.instance.enableIgnoreNullKey(false);
    return _instance;
  }

  AutoTrack enableUpload() {
    AutoTrackConfigManager.instance.enableUpload(true);
    return _instance;
  }

  AutoTrack disableUpload() {
    AutoTrackConfigManager.instance.enableUpload(false);
    return _instance;
  }

  AutoTrack enableClick() {
    AutoTrackConfigManager.instance.enableClick(true);
    return _instance;
  }

  AutoTrack enableDrag() {
    AutoTrackConfigManager.instance.enableDrag(true);
    return _instance;
  }

  AutoTrack disableDrag() {
    AutoTrackConfigManager.instance.enableDrag(true);
    return _instance;
  }

  AutoTrack disableClick() {
    AutoTrackConfigManager.instance.enableClick(false);
    return _instance;
  }

  AutoTrack enable() {
    AutoTrackConfigManager.instance.enableAutoTrack(true);
    PointerEventListener.instance.start();
    DragPointerEventListener.instance.start();
    return _instance;
  }

  AutoTrack disable() {
    AutoTrackConfigManager.instance.enableAutoTrack(false);
    PointerEventListener.instance.stop();
    DragPointerEventListener.instance.stop();
    return _instance;
  }

  AutoTrack enableLog() {
    final logger = AutoTrackLogger.getInstance();
    if (!logger.hasHandler) {
      logger.setHandler((level, message) {
        if (kDebugMode) {
          print('AutoTrack [$level] - $message');
        }
      });
    }
    return _instance;
  }
}