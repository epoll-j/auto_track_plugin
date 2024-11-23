import 'dart:collection';
import 'dart:core';

import 'package:flutter/widgets.dart';

import '../track/track.dart';
import 'page_info.dart';

class PageStack with WidgetsBindingObserver {
  static final PageStack instance = PageStack._();
  PageStack._() {
    WidgetsBinding.instance?.addObserver(this);
  }

  final LinkedList<Page> _stack = LinkedList<Page>();
  final _PageTask _task = _PageTask();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      for (var page in _stack) {
        page.pageInfo.timer.resume();
      }
    } else if (state == AppLifecycleState.paused) {
      for (var page in _stack) {
        page.pageInfo.timer.pause();
      }
    }
  }

  push(Route route, Element element, Route? previousRoute) {
    Page page = Page(route, element);
    _stack.add(page);
    _task.addPush(page, page.previous);
  }

  pop(Route route, Route? previousRoute) {
    if (_stack.isEmpty) {
      return;
    }

    Page? page = _findPage(route);
    if (page != null) {
      _task.addPop(page, page.previous);
    }
    _removeAllAfter(page);
  }

  remove(Route route, Route? previousRoute) {
    if (_stack.isEmpty) {
      return;
    }

    Page? page = _findPage(route);
    if (page != null) {
      _stack.remove(page);
    }
  }

  replace(Route newRoute, Element newElement, Route? oldRoute) {
    Page newPage = Page(newRoute, newElement);
    Page? oldPage;
    if (oldRoute != null) {
      oldPage = _findPage(oldRoute);
      _removeAllAfter(oldPage);
    }
    _stack.add(newPage);
    _task.addReplace(newPage, oldPage);
  }

  Page? _findPage(Route route) {
    if (_stack.isEmpty) {
      return null;
    }

    Page? page = _stack.last;
    while (page != null) {
      if (page.route == route) {
        return page;
      }
      page = page.previous;
    }
    return null;
  }

  _removeAllAfter(Page? page) {
    while (page != null) {
      _stack.remove(page);
      page = page.next;
    }
  }

  Page? getCurrentPage() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack.last;
  }
}

final class Page extends LinkedListEntry<Page> {
  Page._({
    required this.pageInfo,
    required this.route,
    required this.element,
  });
  factory Page(Route route, Element element) {
    return Page._(
      pageInfo: PageInfo.fromElement(element, route),
      route: route,
      element: element,
    );
  }

  final PageInfo pageInfo;
  final Route route;
  final Element element;

  @override
  String toString() => 'pageInfo: $pageInfo, route: $route';
}

class _PageTask {
  final List<_PageTaskData> _list = [];
  bool _taskRunning = false;

  addPush(Page page, Page? prevPage) {
    _PageTaskData taskData = _PageTaskData(_PageTaskType.push, page);
    taskData.prevPage = prevPage;
    _list.add(taskData);
    _triggerTask();
  }

  addPop(Page page, Page? prevPage) {
    _PageTaskData taskData = _PageTaskData(_PageTaskType.pop, page);
    taskData.prevPage = prevPage;
    _list.add(taskData);
    _triggerTask();
  }

  addReplace(Page page, Page? prevPage) {
    _PageTaskData taskData = _PageTaskData(_PageTaskType.replace, page);
    taskData.prevPage = prevPage;
    _list.add(taskData);
    _triggerTask();
  }

  _triggerTask() {
    if (_taskRunning) {
      return;
    }

    _taskRunning = true;

    Future.delayed(const Duration(milliseconds: 30)).then((_) => _executeTask());
  }

  _executeTask() {
    if (_list.isEmpty) {
      _taskRunning = false;
      return;
    }

    List list = _list.sublist(0);
    Page? enterPage, leavePage;
    _list.clear();
    for (_PageTaskData taskData in list as List<_PageTaskData>) {
      if (taskData.type == _PageTaskType.push) {
        leavePage ??= taskData.prevPage;
        enterPage = taskData.page;
      } else if (taskData.type == _PageTaskType.pop) {
        leavePage ??= taskData.page;
        if (enterPage == null || enterPage == taskData.page) {
          enterPage = taskData.prevPage;
          enterPage?.pageInfo.isBack = true;
        }
      } else if (taskData.type == _PageTaskType.replace) {
        leavePage ??= taskData.prevPage;
        if (enterPage == null || enterPage == taskData.prevPage) {
          enterPage = taskData.page;
        }
      }
    }
    if (enterPage != leavePage) {
      if (leavePage != null && !leavePage.pageInfo.ignore) {
        leavePage.pageInfo.timer.end();
        Track.instance.pageLeave(leavePage.pageInfo);
      }
      if (enterPage != null && !enterPage.pageInfo.ignore) {
        enterPage.pageInfo.timer.start();
        Track.instance.pageView(enterPage.pageInfo);
      }
    }
    _taskRunning = false;
  }
}

class _PageTaskData {
  _PageTaskData(this.type, this.page);
  final _PageTaskType type;
  final Page page;
  Page? prevPage;
}

enum _PageTaskType {
  push,
  pop,
  replace,
}
