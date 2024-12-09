import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../config/config.dart';
import '../../config/manager.dart';
import '../../log/logger.dart';
import '../../utils/element_util.dart';
import 'page_stack.dart';

class AutoTrackNavigationObserver extends NavigatorObserver {
  static List<NavigatorObserver> wrap(List<NavigatorObserver>? navigatorObservers) {
    if (navigatorObservers == null) {
      return [AutoTrackNavigationObserver()];
    }

    bool found = false;
    List<NavigatorObserver> removeList = [];
    for (NavigatorObserver observer in navigatorObservers) {
      if (observer is AutoTrackNavigationObserver) {
        if (found) {
          removeList.add(observer);
        }
        found = true;
      }
    }
    for (NavigatorObserver observer in removeList) {
      navigatorObservers.remove(observer);
    }
    if (!found) {
      navigatorObservers.insert(0, AutoTrackNavigationObserver());
    }
    return navigatorObservers;
  }

  static List<NavigatorObserver> defaultNavigatorObservers() => [AutoTrackNavigationObserver()];

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // print('didPop -> $route, previousRoute -> $previousRoute');
    try {
      PageStack.instance.pop(route, previousRoute);
    } catch (e) {
      AutoTrackLogger.getInstance().error(e);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // print('didPush -> $route, previousRoute -> $previousRoute');
    try {
      _findElement(route, (element) {
        PageStack.instance.push(route, element, previousRoute);
      });
    } catch (e) {
      AutoTrackLogger.getInstance().error(e);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    // print('didRemove -> $route, previousRoute -> $previousRoute');
    try {
      PageStack.instance.remove(route, previousRoute);
    } catch (e) {
      AutoTrackLogger.getInstance().error(e);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // print('didReplace -> $newRoute, oldRoute -> $oldRoute');
    try {
      if (newRoute != null) {
        _findElement(newRoute, (element) {
          PageStack.instance.replace(newRoute, element, oldRoute);
        });
      }
    } catch (e) {
      AutoTrackLogger.getInstance().error(e);
    }
  }

  void _findElement(Route route, Function(Element) callback) {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (route is ModalRoute) {
        ModalRoute pageRoute = route;
        ElementUtil.walk(pageRoute.subtreeContext, (element, parent) {
          if (parent != null && parent.widget is Semantics) {
            callback(element);
            return false;
          }
          return true;
        });
      } else if (AutoTrackConfigManager.instance.useCustomRoute) {
        List<AutoTrackPageConfig> pageConfigs = AutoTrackConfigManager.instance.pageConfigs;
        if (pageConfigs.isEmpty) {
          return;
        }

        Element? lastPageElement;
        ElementUtil.walk(route.navigator?.context, (element, parent) {
          if (pageConfigs.last.isPageWidget!(element.widget)) {
            lastPageElement = element;
            return false;
          }
          return true;
        });
        if (lastPageElement != null) {
          callback(lastPageElement!);
        }
      }
    });
  }
}
