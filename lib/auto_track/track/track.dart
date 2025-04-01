import 'package:auto_track/auto_track/config/queue.dart';
import 'package:auto_track/auto_track/utils/error_model.dart';
import 'package:auto_track/auto_track/utils/request_model.dart';
import 'package:auto_track/auto_track/utils/track_model.dart';

import '../config/manager.dart';
import '../listener/click/click_info.dart';
import '../listener/drag/drag_info.dart';
import '../listener/page_view/page_info.dart';
import '../log/logger.dart';

class Track {
  static final Track instance = Track._();
  Track._();

  Map<String, dynamic> _appendPageInfo(Map<String, dynamic> params, PageInfo pageInfo) {
    params['page_key'] = pageInfo.pageKey;
    params['page_title'] = pageInfo.pageTitle;
    params['page_manual_key'] = pageInfo.pageManualKey;
    params['page_path'] = pageInfo.pagePath;
    params['is_back'] = pageInfo.isBack ? 1 : 0;
    return params;
  }

  String? get deviceId => AutoTrackConfigManager.instance.deviceId;

  void pageView(PageInfo pageInfo) {
    if (!AutoTrackConfigManager.instance.autoTrackEnable) {
      return;
    }
    if (!AutoTrackConfigManager.instance.pageViewEnabled) {
      return;
    }

    Map<String, dynamic> params = _appendPageInfo({}, pageInfo);
    _TrackPlugin.pageView(params);
    AutoTrackLogger.getInstance().debug('track page_view => $params');
  }

  void pageLeave(PageInfo pageInfo) {
    if (!AutoTrackConfigManager.instance.autoTrackEnable) {
      return;
    }
    if (!AutoTrackConfigManager.instance.pageLeaveEnable) {
      return;
    }

    Map<String, dynamic> params = _appendPageInfo({}, pageInfo);
    params['page_duration'] = pageInfo.timer.duration.inMilliseconds;
    _TrackPlugin.pageLeave(params);
    AutoTrackLogger.getInstance().debug('track page_leave => $params');
  }

  void click(ClickInfo clickInfo) {
    if (!AutoTrackConfigManager.instance.autoTrackEnable) {
      return;
    }
    if (!AutoTrackConfigManager.instance.clickEnable) {
      return;
    }

    Map<String, dynamic> params = {};
    params['touch_x'] = clickInfo.touchX;
    params['touch_y'] = clickInfo.touchY;
    params['element_width'] = clickInfo.elementWidth;
    params['element_height'] = clickInfo.elementHeight;
    params['element_type'] = clickInfo.elementType;
    params['element_manual_key'] = clickInfo.elementManualKey;
    params['element_path'] = clickInfo.elementPath;
    params['texts'] = clickInfo.texts;
    _appendPageInfo(params, clickInfo.pageInfo);
    _TrackPlugin.click(params);
    AutoTrackLogger.getInstance().debug('track click => $params');
  }

  void drag(DragInfo dragInfo) {
    if (!AutoTrackConfigManager.instance.autoTrackEnable) {
      return;
    }
    if (!AutoTrackConfigManager.instance.dragEnable) {
      return;
    }
    Map<String, dynamic> params = {};
    params['manual_key'] = 'drag';
    params['begin'] = {
      'x': dragInfo.beginOffset.dx,
      'y': dragInfo.beginOffset.dy,
    };
    params['end'] = {
      'x': dragInfo.endOffset.dx,
      'y': dragInfo.endOffset.dy,
    };
    params['drag_duration'] = dragInfo.duration;
    params['drag_direction'] = dragInfo.direction;

    _appendPageInfo(params, dragInfo.pageInfo);
    _TrackPlugin.drag(params);
    AutoTrackLogger.getInstance().debug('track drag => $params');

  }

  void customEvent(String type, Map<String, dynamic> params) {
    _TrackPlugin.customEvent(type, params);
    AutoTrackLogger.getInstance().debug('track $type => $params');
  }

  void reportError(Object error, StackTrace stack) {
    final model = ErrorModel(error: error, stack: stack);
    _TrackPlugin.customEvent('error', model.toMap());
    // AutoTrackLogger.getInstance().debug('track error => ${model.toMap()}');
  }

  void reportHttpRequest(RequestModel requestModel) {
    _TrackPlugin.customEvent('http', requestModel.toMap(), key: requestModel.uri.path);
    // AutoTrackLogger.getInstance().debug('track request => ${requestModel.toMap()}');
  }
}

class _TrackPlugin {

  static void pageView(Map<String, dynamic> params) {
    var model = TrackModel('page_view', DateTime.now().millisecondsSinceEpoch, params, params['page_manual_key']);
    AutoTrackConfigManager.instance.config.eventHandler?.call(model);
    AutoTrackQueue.instance.appendQueue(model);
  }

  static void pageLeave(Map<String, dynamic> params) {
    var model = TrackModel('page_leave', DateTime.now().millisecondsSinceEpoch, params, params['page_manual_key']);
    AutoTrackConfigManager.instance.config.eventHandler?.call(model);
    AutoTrackQueue.instance.appendQueue(model);
  }

  static void click(Map<String, dynamic> params) {
    var model = TrackModel('click', DateTime.now().millisecondsSinceEpoch, params, params['element_manual_key']);
    AutoTrackConfigManager.instance.config.eventHandler?.call(model);
    AutoTrackQueue.instance.appendQueue(model);
  }

  static void customEvent(String type, Map<String, dynamic> params, { String? key }) {
    var model = TrackModel(type, DateTime.now().millisecondsSinceEpoch, params, params['key'] ?? key ?? type);
    AutoTrackConfigManager.instance.config.eventHandler?.call(model);
    AutoTrackQueue.instance.appendQueue(model);
  }

  static void drag(Map<String, dynamic> params) {
    var model = TrackModel('drag', DateTime.now().millisecondsSinceEpoch, params, params['manual_key']);
    AutoTrackConfigManager.instance.config.eventHandler?.call(model);
    AutoTrackQueue.instance.appendQueue(model);
  }
}
