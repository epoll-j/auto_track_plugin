import 'dart:convert';

import 'package:auto_track/auto_track/utils/track_model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

typedef EventHandlerFunc = void Function(TrackModel);

class AutoTrackConfig {
  AutoTrackConfig({
    this.host, // 数据上报地址
    this.uploadInterval, // 数据上报间隔
    this.appKey = '', // 数据上报时根据key和secret生成签名
    this.appSecret = '',
    this.signature, // 签名生成方法，默认使用sha256对key、时间戳和secret进行签名
    this.enableUpload = false, // 开启数据上报
    this.trackId, // 埋点ID，默认使用UUID，每次启动时会变化
    this.userId, // 用户ID
    this.uniqueId,
    this.eventHandler, // 事件处理
    this.pageConfigs = const [],
    this.useCustomRoute = false, // 使用自定义路由
    this.ignoreElementKeys = const [], // 忽略key列表
    this.ignoreElementStringKeys = const [],
    this.enablePageView = true, // 监听页面进入事件
    this.enablePageLeave = false, // 监听页面离开事件
    this.enableClick = true, // 监听点击事件
    this.enableDrag = false, // 监听拖拽事件
    this.enableIgnoreNullKey = false, // 忽略空key事件
  }) {
    trackId ??= const Uuid().v4().replaceAll('-', '');
    signature ??= (t) => sha256.convert(utf8.encode('$appKey$t$appSecret')).toString();
  }

  String? host;
  String? appKey;
  String? appSecret;
  String? trackId;
  String? userId;
  String? uniqueId;

  int? uploadInterval;

  Function? signature;
  EventHandlerFunc? eventHandler;

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

  bool enableDrag;

  bool enableIgnoreNullKey;
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
}
