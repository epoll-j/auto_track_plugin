import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_track/auto_track/config/manager.dart';
import 'package:auto_track/auto_track/utils/track_model.dart';

import '../log/logger.dart';


class AutoTrackQueue {
  static final AutoTrackQueue instance = AutoTrackQueue._();
  AutoTrackQueue._();

  Timer? _timer;
  final List<TrackModel> _queue = [];
  final httpClient = HttpClient();

  void appendQueue(TrackModel model) {
    if (_timer == null) return;
    _queue.add(model);
  }

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(Duration(seconds: AutoTrackConfigManager.instance.config.uploadInterval ?? 10), (timer) {
      flush();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void flush() {
    if (_queue.isEmpty) return;
    final uploadList = List.from(_queue);
    _queue.clear();
    final config = AutoTrackConfigManager.instance.config;
    final host = config.host;
    if (config.samplingRate != 1) {
      if (Random().nextDouble() > config.samplingRate) {
        // 不在采样范围不上传
        return;
      }
    }
    if (host != null) {
      final t = DateTime.now().millisecondsSinceEpoch;
      httpClient.postUrl(Uri.parse(host)).then((request) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.write(json.encode({
          'app_key': config.appKey ?? '',
          'signature': config.signature!(t),
          't': t,
          'user_id': config.userId ?? '',
          'track_id': config.trackId ?? '',
          'unique_id': config.uniqueId ?? AutoTrackConfigManager.instance.deviceId,
          'device_id': AutoTrackConfigManager.instance.deviceId,
          'data_list': uploadList.map((e) => e.toMap()).toList(),
          'app_version': AutoTrackConfigManager.instance.appVersion,
          'device_info': AutoTrackConfigManager.instance.deviceInfo
        }));
        return request.close();
      }).then((response) {
        AutoTrackLogger.getInstance().debug('upload status => ${response.statusCode}');
      }).catchError((error) {
        AutoTrackLogger.getInstance().error(error);
      });
    }
  }
}