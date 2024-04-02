import 'package:auto_track/auto_track/drag/drag_info.dart';
import 'package:auto_track/auto_track/track/track.dart';
import 'package:flutter/gestures.dart';

import '../page_view/page_stack.dart';

class DragPointerEventListener {
  static final DragPointerEventListener instance = DragPointerEventListener._();
  DragPointerEventListener._();
  bool _started = false;
  late _AutoTrackPanGestureRecognizer _panGestureRecognizer;

  void start() {
    if (!_started) {
      _panGestureRecognizer = _AutoTrackPanGestureRecognizer();
      GestureBinding.instance?.pointerRouter
          .addGlobalRoute(_panGestureRecognizer.addPointer);
      _started = true;
    }
  }

  void stop() {
    if (_started) {
      GestureBinding.instance?.pointerRouter
          .removeGlobalRoute(_panGestureRecognizer.addPointer);
      _panGestureRecognizer.dispose();
      _started = false;
    }
  }
}

class _AutoTrackPanGestureRecognizer extends PanGestureRecognizer {
  _AutoTrackPanGestureRecognizer({Object? debugOwner})
      : super(debugOwner: debugOwner);

  PointerAddedEvent? beginEvent;
  int startTime = 0;

  @override
  void addPointer(PointerEvent event) {
    resolve(GestureDisposition.accepted);

    final page = PageStack.instance.getCurrentPage();
    if (page == null) {
      return;
    }
    if (event is PointerAddedEvent) {
      beginEvent = event;
      startTime = DateTime.now().millisecondsSinceEpoch;
    } else if (event is PointerRemovedEvent) {
      if (beginEvent != null) {
        final distance = (beginEvent!.position.dx - event.position.dx).abs() +
            (beginEvent!.position.dy - event.position.dy).abs();
        if (distance > 30) {
          final info = DragInfo.from(
              begin: beginEvent!.position,
              end: event.position,
              pageElement: page!.element,
              pageInfo: page!.pageInfo,
              duration: DateTime.now().millisecondsSinceEpoch - startTime);
          if (!info.ignore) {
            Track.instance.drag(info);
          }
        }
      }
      beginEvent = null;
    }
  }
}
