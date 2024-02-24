import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class AutoTrackConfig {
  AutoTrackConfig({
    this.host,
    this.appKey = '',
    this.appSecret = '',
    this.trackId,
    this.userId,
    this.signature,
    this.pageConfigs = const [],
    this.useCustomRoute = false,
    this.ignoreElementKeys = const [],
    this.ignoreElementStringKeys = const [],
    this.enablePageView = true,
    this.enablePageLeave = false,
    this.enableClick = true,
    this.enableUpload = false
  }) {
    trackId ??= const Uuid().v4().replaceAll('-', '');
    signature ??= (t) => sha256.convert(utf8.encode('$appKey$t$appSecret')).toString();
  }

  String? host;
  String? appKey;
  String? appSecret;
  String? trackId;
  String? userId;
  Function? signature;

  List<AutoTrackPageConfig> pageConfigs;

  /// 如果使用 MaterialPageRoute/PageRoute/ModalRoute 之外的 Route，
  /// 请打开该开关，并保证所有页面都配置在 pageConfigs 中
  bool useCustomRoute;

  /// 推荐使用 [ElementKey]
  List<Key> ignoreElementKeys;

  List<String> ignoreElementStringKeys;

  Set<Key> getIgnoreElementKeySet() => Set.from(ignoreElementKeys);

  Set<String> getIgnoreElementStringKeySet() =>
      Set.from(ignoreElementStringKeys);

  bool enablePageView;

  bool enablePageLeave;

  bool enableClick;

  bool enableUpload;
}

typedef PageWidgetFunc = bool Function(Widget);

class AutoTrackPageConfig<T extends Widget> {
  AutoTrackPageConfig({
    this.pageID,
    this.pagePath,
    this.ignore = false,
    this.pageTitle,
    this.isPageWidget
  }) {
    isPageWidget ??= (pageWidget) => pageWidget is T;
  }

  String? pageID;
  String? pagePath;
  bool ignore;
  String? pageTitle;
  PageWidgetFunc? isPageWidget;

// bool isPageWidget(Widget pageWidget) => pageWidget is T;
}
