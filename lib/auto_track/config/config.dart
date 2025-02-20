import 'dart:convert';

import 'package:auto_track/auto_track/utils/track_model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

typedef EventHandlerFunc = void Function(TrackModel);
typedef UploadHandlerFunc = Future<void> Function(List<TrackModel>);

class AutoTrackConfig {
  AutoTrackConfig({
    this.host, // 数据上报地址
    this.uploadInterval, // 数据上报间隔
    this.samplingRate = 1, // 采样率
    this.appKey = '', // 数据上报时根据key和secret生成签名
    this.appSecret = '',
    this.signature, // 签名生成方法，默认使用sha256对key、时间戳和secret进行签名
    this.enableUpload = false, // 开启数据上报
    this.trackId, // 埋点ID，默认使用UUID，每次启动时会变化
    this.userId, // 用户ID
    this.uniqueId,
    this.eventHandler, // 事件处理
    this.uploadHandler, // 上报数据处理
    this.pageConfigs = const [],
    this.useCustomRoute = false, // 使用自定义路由
    this.ignoreElementKeys = const [], // 忽略key列表
    this.ignoreElementStringKeys = const [],
    this.enablePageView = true, // 监听页面进入事件
    this.enablePageLeave = false, // 监听页面离开事件
    this.enableClick = true, // 监听点击事件
    this.enableDrag = false, // 监听拖拽事件
    this.enableIgnoreNullKey = false, // 忽略空key事件
    this.httpRequestConfig,
  }) {
    trackId ??= const Uuid().v4().replaceAll('-', '');
    signature ??=
        (t) => sha256.convert(utf8.encode('$appKey$t$appSecret')).toString();
    httpRequestConfig ??= HttpRequestConfig();
  }

  String? host;
  String? appKey;
  String? appSecret;
  String? trackId;
  String? userId;
  String? uniqueId;

  /// 采样率，默认 1 (100%)
  double samplingRate;

  int? uploadInterval;

  Function? signature;
  /// 自定义事件处理
  EventHandlerFunc? eventHandler;
  /// 自定义上报处理
  UploadHandlerFunc? uploadHandler;

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

  HttpRequestConfig? httpRequestConfig;

  copyWith({
    String? host,
    String? appKey,
    String? appSecret,
    String? trackId,
    String? userId,
    String? uniqueId,
    double? samplingRate,
    int? uploadInterval,
    Function? signature,
    EventHandlerFunc? eventHandler,
    List<AutoTrackPageConfig>? pageConfigs,
    bool? useCustomRoute,
    List<Key>? ignoreElementKeys,
    List<String>? ignoreElementStringKeys,
    bool? enablePageView,
    bool? enablePageLeave,
    bool? enableClick,
    bool? enableUpload,
    bool? enableDrag,
    bool? enableIgnoreNullKey,
    HttpRequestConfig? httpRequestConfig
  }) {
    return AutoTrackConfig(
      host: host ?? this.host,
      appKey: appKey ?? this.appKey,
      appSecret: appSecret ?? this.appSecret,
      trackId: trackId ?? this.trackId,
      userId: userId ?? this.userId,
      uniqueId: uniqueId ?? this.uniqueId,
      samplingRate: samplingRate ?? this.samplingRate,
      uploadInterval: uploadInterval ?? this.uploadInterval,
      signature: signature ?? this.signature,
      eventHandler: eventHandler ?? this.eventHandler,
      pageConfigs: pageConfigs ?? this.pageConfigs,
      useCustomRoute: useCustomRoute ?? this.useCustomRoute,
      ignoreElementKeys: ignoreElementKeys ?? this.ignoreElementKeys,
      ignoreElementStringKeys:
          ignoreElementStringKeys ?? this.ignoreElementStringKeys,
      enablePageView: enablePageView ?? this.enablePageView,
      enablePageLeave: enablePageLeave ?? this.enablePageLeave,
      enableClick: enableClick ?? this.enableClick,
      enableUpload: enableUpload ?? this.enableUpload,
      enableDrag: enableDrag ?? this.enableDrag,
      enableIgnoreNullKey: enableIgnoreNullKey ?? this.enableIgnoreNullKey,
      httpRequestConfig: httpRequestConfig ?? this.httpRequestConfig
    );
  }
}

typedef PageWidgetFunc = bool Function(Widget);

class AutoTrackPageConfig<T extends Widget> {
  AutoTrackPageConfig(
      {this.pageID,
      this.pagePath,
      this.ignore = false,
      this.pageTitle,
      this.isPageWidget}) {
    isPageWidget ??= (pageWidget) => pageWidget is T;
  }

  String? pageID;
  String? pagePath;
  bool ignore;
  String? pageTitle;
  PageWidgetFunc? isPageWidget;
}

class HttpRequestConfig {
  bool ignoreRequestHeader;
  bool ignoreResponseHeader;

  HttpRequestConfig({
    this.ignoreRequestHeader = false,
    this.ignoreResponseHeader = false,
  });
}
