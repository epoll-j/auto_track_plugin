import 'dart:convert';

import 'package:auto_track/auto_track/config/queue.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'config.dart';

class AutoTrackConfigManager {
  static final AutoTrackConfigManager instance = AutoTrackConfigManager._();

  AutoTrackConfigManager._() {
    PackageInfo.fromPlatform().then((value) => _appVersion = value.version);
    DeviceInfoPlugin().deviceInfo.then((value) {
      _deviceInfo = value.data;
      _baseDeviceInfo = value;
      _updateDeviceId();
    });
  }

  String _appVersion = '';
  String get appVersion => _appVersion;

  BaseDeviceInfo? _baseDeviceInfo;
  String? _deviceId;
  String? get deviceId => _deviceId;

  Map<String, dynamic> _deviceInfo = {};
  Map<String, dynamic> get deviceInfo => _deviceInfo;

  AutoTrackConfig _config = AutoTrackConfig();
  AutoTrackConfig get config => _config;

  bool _autoTrackEnable = false;
  bool get autoTrackEnable => _autoTrackEnable;

  void updateConfig(AutoTrackConfig config) {
    _config = config;
    _updateDeviceId();
    if (config.enableUpload) {
      AutoTrackQueue.instance.start();
    } else {
      AutoTrackQueue.instance.stop();
    }
  }

  void _updateDeviceId() {
    if (_baseDeviceInfo is IosDeviceInfo) {
      _deviceId = md5.convert(utf8.encode('${(_baseDeviceInfo as IosDeviceInfo).identifierForVendor}#${config.appKey}')).toString();
    } else if (_baseDeviceInfo is AndroidDeviceInfo) {
      _deviceId = md5.convert(utf8.encode('${(_baseDeviceInfo as AndroidDeviceInfo).serialNumber}#${config.appKey}')).toString();
    } else if (_baseDeviceInfo is MacOsDeviceInfo) {
      _deviceId = '${(_baseDeviceInfo as MacOsDeviceInfo).hostName}-${(_baseDeviceInfo as MacOsDeviceInfo).computerName}';
    } else {
      _deviceId = null;
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

  void enableDrag(bool enable) {
    _config.enableDrag = enable;
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

  void enableIgnoreNullKey(bool enable) {
    _config.enableIgnoreNullKey = enable;
  }

  List<AutoTrackPageConfig> get pageConfigs => _config.pageConfigs;

  bool get useCustomRoute => _config.useCustomRoute;

  AutoTrackPageConfig getPageConfig(Widget pageWidget) {
    return _config.pageConfigs.firstWhere(
            (pageConfig) => pageConfig.isPageWidget!(pageWidget),
        orElse: () => AutoTrackPageConfig());
  }

  Set<Key> getIgnoreElementKeySet() => _config.getIgnoreElementKeySet();

  Set<String> getIgnoreElementStringKeySet() =>
      _config.getIgnoreElementStringKeySet();

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

    if (key is ValueKey) {
      return getIgnoreElementStringKeySet().contains(key.value);
    }

    return false;
  }

  bool get pageViewEnabled => _config.enablePageView;

  bool get pageLeaveEnable => _config.enablePageLeave;

  bool get clickEnable => _config.enableClick;

  bool get dragEnable => _config.enableDrag;

  bool get ignoreNullKeyEnable => _config.enableIgnoreNullKey;
}