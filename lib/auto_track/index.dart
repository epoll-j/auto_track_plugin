import 'dart:io';

import 'package:flutter/foundation.dart';

import 'config/config.dart';
import 'config/manager.dart';
import 'listener/click/pointer_event_listener.dart';
import 'listener/drag/drag_pointer_event_listener.dart';
import 'listener/request/request_listener.dart';
import 'log/logger.dart';

class AutoTrack {
  static final AutoTrack _instance = AutoTrack._();
  AutoTrack._();

  factory AutoTrack({ AutoTrackConfig? config }) {
    _instance.config(config);
    return _instance;
  }

  void updateUserId(String id) {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(userId: id));
  }

  void updateSampleRate(double rate) {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(samplingRate: rate));
  }

  AutoTrack config(AutoTrackConfig? config) {
    if (config != null) {
      AutoTrackConfigManager.instance.setConfig(config);
    }
    return _instance;
  }

  AutoTrack pageConfigs(List<AutoTrackPageConfig>? pageConfigs) {
    if (pageConfigs != null) {
      AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(pageConfigs: pageConfigs));
    }
    return _instance;
  }

  AutoTrack ignoreElementKeys(List<Key>? ignoreElementKeys) {
    if (ignoreElementKeys != null) {
      AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(ignoreElementKeys: ignoreElementKeys));
    }
    return _instance;
  }

  AutoTrack ignoreElementStringKeys(List<String>? ignoreElementStringKeys) {
    if (ignoreElementStringKeys != null) {
      AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(ignoreElementStringKeys: ignoreElementStringKeys));
    }
    return _instance;
  }

  AutoTrack enablePageView() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enablePageView: true));
    return _instance;
  }

  AutoTrack disablePageView() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enablePageView: false));
    return _instance;
  }

  AutoTrack enablePageLeave() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enablePageLeave: true));
    return _instance;
  }

  AutoTrack disablePageLeave() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enablePageLeave: false));
    return _instance;
  }

  AutoTrack enableIgnoreNullKey() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableIgnoreNullKey: true));
    return _instance;
  }

  AutoTrack disableIgnoreNullKey() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableIgnoreNullKey: false));
    return _instance;
  }

  AutoTrack enableUpload() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableUpload: true));
    return _instance;
  }

  AutoTrack disableUpload() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableUpload: false));
    return _instance;
  }

  AutoTrack enableClick() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableClick: true));
    return _instance;
  }

  AutoTrack disableClick() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableClick: false));
    return _instance;
  }

  AutoTrack enableDrag() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableDrag: true));
    return _instance;
  }

  AutoTrack disableDrag() {
    AutoTrackConfigManager.instance.updateConfig(AutoTrackConfig(enableDrag: false));
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

  AutoTrack enableHttpRequest() {
    HttpOverrides.global = AutoTrackHttpOverrides(HttpOverrides.current);
    return _instance;
  }

  AutoTrack disableHttpRequest() {
    HttpOverrides.global = null;
    return _instance;
  }
}