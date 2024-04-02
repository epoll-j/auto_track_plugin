import 'package:flutter/widgets.dart';

import '../config/manager.dart';
import '../page_view/page_info.dart';

class DragInfo {
  DragInfo._(this.pageInfo);

  factory DragInfo.from(
      {required Offset begin,
      required Offset end,
      required Element pageElement,
      required PageInfo pageInfo,
      required int duration}) {
    DragInfo dragInfo = DragInfo._(pageInfo);
    dragInfo._beginOffset = begin;
    dragInfo._endOffset = end;
    dragInfo._duration = duration;
    dragInfo._ignore = AutoTrackConfigManager.instance.isIgnoreElement(
        pageElement.widget.key ?? ValueKey(pageInfo.pageManualKey));

    double dx = dragInfo.endOffset.dx - dragInfo.beginOffset.dx;
    double dy = dragInfo.endOffset.dy - dragInfo.beginOffset.dy;

    var direction = 'down';
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        direction = 'right';
      } else {
        direction = 'left';
      }
    } else if (dy.abs() > dx.abs()) {
      if (dy > 0) {
        direction = 'down';
      } else {
        direction = 'up';
      }
    } else {
      direction = 'none';
    }
    dragInfo._direction = direction;

    return dragInfo;
  }

  Offset _beginOffset = Offset.zero;
  Offset get beginOffset => _beginOffset;

  Offset _endOffset = Offset.zero;
  Offset get endOffset => _endOffset;

  bool _ignore = false;
  bool get ignore => _ignore;

  String _direction = 'none';
  String get direction => _direction;

  int _duration = 0;
  int get duration => _duration;

  final PageInfo pageInfo;

  @override
  String toString() {
    return [
      'beginOffset: $beginOffset',
      'endOffset: $endOffset',
      'pageInfo: $pageInfo',
    ].join(', ');
  }
}
