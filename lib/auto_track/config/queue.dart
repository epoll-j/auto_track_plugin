import 'dart:async';

import 'package:auto_track/auto_track/config/manager.dart';
import 'package:auto_track/auto_track/utils/track_model.dart';
import 'package:dio/dio.dart';

import '../log/logger.dart';



class AutoTrackQueue {
  static final AutoTrackQueue instance = AutoTrackQueue._();
  AutoTrackQueue._();

  Timer? _timer;
  final List<TrackModel> _queue = [];
  final dio = Dio();

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
    if (host != null) {
      final t = DateTime.now().millisecond;
      dio.post(host, data: {
        'app_key': config.appKey ?? '',
        'signature': config.signature!(t),
        't': t,
        'user_id': config.userId ?? '',
        'track_id': config.trackId ?? '',
        'unique_id': config.uniqueId ?? AutoTrackConfigManager.instance.deviceId,
        'data_list': uploadList.map((e) => e.toMap()).toList(),
        'app_version': AutoTrackConfigManager.instance.appVersion,
        'device_info': AutoTrackConfigManager.instance.deviceInfo
      }).onError((error, stackTrace) {
        AutoTrackLogger.getInstance().error(error!);
        return Future.value(Response(statusCode: 500, requestOptions: RequestOptions(path: host)));
      });
    }
  }
}
