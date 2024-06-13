import 'package:auto_track/auto_track/config/queue.dart';
import 'package:auto_track/auto_track/drag/drag_info.dart';
import 'package:auto_track/auto_track/utils/error_model.dart';
import 'package:auto_track/auto_track/utils/track_model.dart';

import '../click/click_info.dart';
import '../config/manager.dart';
import '../log/logger.dart';
import '../page_view/page_info.dart';

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
    AutoTrackLogger.getInstance().debug('track custom_event => $params');
  }

  void reportError(Object error, StackTrace stack) {
    _TrackPlugin.customEvent('error', ErrorModel(error: error, stack: stack).toMap());
  }
}

class _TrackPlugin {

  static void pageView(Map<String, dynamic> params) {
    AutoTrackQueue.instance.appendQueue(TrackModel('page_view', DateTime.now().millisecondsSinceEpoch, params, params['page_manual_key']));
  }

  static void pageLeave(Map<String, dynamic> params) {
    AutoTrackQueue.instance.appendQueue(TrackModel('page_leave', DateTime.now().millisecondsSinceEpoch, params, params['page_manual_key']));
  }

  static void click(Map<String, dynamic> params) {
    AutoTrackQueue.instance.appendQueue(TrackModel('click', DateTime.now().millisecondsSinceEpoch, params, params['element_manual_key']));
  }

  static void customEvent(String type, Map<String, dynamic> params) {
    AutoTrackQueue.instance.appendQueue(TrackModel(type, DateTime.now().millisecondsSinceEpoch, params, params['key'] ?? type));
  }

  static void drag(Map<String, dynamic> params) {
    AutoTrackQueue.instance.appendQueue(TrackModel('drag', DateTime.now().millisecondsSinceEpoch, params, params['manual_key']));
  }
}
