import 'package:flutter/widgets.dart';

class AutoTrackNavigatorKey {
  static AutoTrackNavigatorKey? _instance;
  AutoTrackNavigatorKey._();

  static AutoTrackNavigatorKey _getInstance() {
    _instance ??= AutoTrackNavigatorKey._();
    return _instance!;
  }

  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> navigatorKeyWrap(GlobalKey<NavigatorState>? navigatorKey) {
    if (navigatorKey != null) {
      _getInstance()._navigatorKey = navigatorKey;
    }
    return _getInstance()._navigatorKey;
  }

  static GlobalKey<NavigatorState> get navigatorKey => _getInstance()._navigatorKey;
}
