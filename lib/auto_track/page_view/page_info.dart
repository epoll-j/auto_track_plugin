import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/manager.dart';
import '../utils/element_util.dart';

class PageInfo {
  PageInfo._(this.timer);

  factory PageInfo.fromElement(Element element, Route route) {
    AutoTrackPageConfig pageConfig = AutoTrackConfigManager.instance.getPageConfig(element.widget);
    PageInfo pageInfo = PageInfo._(PageTimer());
    pageInfo._pageKey = element.widget.runtimeType.toString();
    pageInfo._pagePath = pageConfig.pagePath ?? route.settings.name ?? '';
    pageInfo._pageTitle = pageConfig.pageTitle ?? pageInfo._findTitle(element) ?? '';
    pageInfo._pageManualKey = pageConfig.pageID ?? md5.convert(utf8.encode('${pageInfo._pageKey}${pageInfo._pagePath}${pageInfo._pageTitle}')).toString();
    pageInfo.ignore = pageConfig.ignore;
    return pageInfo;
  }

  final PageTimer timer;
  bool isBack = false;
  bool ignore = false;

  String _pageKey = '';
  String get pageKey => _pageKey;

  String _pageTitle = '';
  String get pageTitle => _pageTitle;

  String _pageManualKey = '';
  String get pageManualKey => _pageManualKey;

  String _pagePath = '';
  String get pagePath => _pagePath;

  String? _findTitle(Element element) {
    String? title;
    ElementUtil.walkElement(element, (child, _) {
      if (child.widget is NavigationToolbar) {
        NavigationToolbar toolBar = child.widget as NavigationToolbar;
        if (toolBar.middle == null) {
          return false;
        }

        if (toolBar.middle is Text) {
          title = (toolBar.middle as Text).data;
          return false;
        }

        int layoutIndex = 0;
        if (toolBar.leading != null) {
          layoutIndex += 1;
        }
        title = _findTextsInMiddle(child, layoutIndex);
        return false;
      }
      return true;
    });
    return title;
  }
  String? _findTextsInMiddle(Element element, int layoutIndex) {
    String? text;
    int index = 0;
    ElementUtil.walkElement(element, ((child, _) {
      if (child.widget is LayoutId) {
        if (index == layoutIndex) {
          text = ElementUtil.findTexts(child).join('');
          return false;
        }
        index += 1;
      }
      return true;
    }));
    return text;
  }

  @override
  String toString() => '{ pageKey: $pageKey,  pageTitle: $pageTitle,  pageManualKey: $pageManualKey,  pagePath: $pagePath, isBack: $isBack }';
}

enum PageTimerState {
  Init,
  Start,
  Pause,
  Resume,
  End,
}

class PageTimer {
  PageTimer();

  PageTimerState _state = PageTimerState.Init;
  PageTimerState get state => _state;

  int _lastTimeStamp = 0;

  Duration _duration = const Duration();
  Duration get duration => _duration;

  int _computeMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch - _lastTimeStamp;
  }

  start() {
    if (_state != PageTimerState.Init && _state != PageTimerState.End) {
      return;
    }

    _state = PageTimerState.Start;
    _lastTimeStamp = DateTime.now().millisecondsSinceEpoch;
    _duration = const Duration();
  }

  pause() {
    if (_state != PageTimerState.Start && _state != PageTimerState.Resume) {
      return;
    }

    _state = PageTimerState.Pause;
    _duration = Duration(milliseconds: _duration.inMilliseconds + _computeMilliseconds());
  }

  resume() {
    if (_state != PageTimerState.Pause) {
      return;
    }

    _state = PageTimerState.Resume;
    _lastTimeStamp = DateTime.now().millisecondsSinceEpoch;
  }

  end() {
    if (_state == PageTimerState.Pause) {
      _state = PageTimerState.End;
      return;
    }

    if (_state == PageTimerState.Start || _state == PageTimerState.Resume) {
      _state = PageTimerState.End;
      _duration = Duration(milliseconds: _duration.inMilliseconds + _computeMilliseconds());
    }
  }
}
