import 'dart:io';

import 'package:flutter/widgets.dart';

typedef AutoTrackLoggerHandler = void Function(AutoTrackLoggerLevel level, String message);

class AutoTrackLogger {
  static final AutoTrackLogger _instance = AutoTrackLogger();
  static AutoTrackLogger getInstance() => _instance;

  List<_LoggerData> _data = [];
  AutoTrackLoggerHandler? _handler;
  bool _isPrinting = false;
  bool get hasHandler => _handler != null;

  void info(String message) {
    _print(AutoTrackLoggerLevel.info, message);
  }

  void debug(String message) {
    _print(AutoTrackLoggerLevel.debug, message);
  }

  void error(Object e) {
    String message = Error.safeToString(e);
    if (e is FlutterError) {
      message = e.message;
    } else if (e is Error) {
      message = e.stackTrace.toString();
    } else if (e is HttpException) {
      message = e.message;
    }
    _print(AutoTrackLoggerLevel.error, '$e \n $message');
  }

  void setHandler(AutoTrackLoggerHandler handler) {
    _handler = handler;
  }

  void _print(AutoTrackLoggerLevel level, String message) {
    if (_handler == null) {
      return;
    }

    _data.add(_LoggerData(level, message));
    if (_isPrinting) {
      return;
    }

    _isPrinting = true;
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      List<_LoggerData> data = _data;
      _data = [];
      if (_handler != null) {
        for (var log in data) {
          _handler!(log.level, log.message);
        }
      }
      _isPrinting = false;
    });
  }
}

enum AutoTrackLoggerLevel {
  info,
  debug,
  error,
}

class _LoggerData {
  const _LoggerData(this.level, this.message);
  final AutoTrackLoggerLevel level;
  final String message;
}
