class TrackModel {
  final String type;
  final int time;
  final String key;
  final Map<String, dynamic> params;
  TrackModel(this.type, this.time, this.params, this.key);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'key': key,
      'time': time,
      'params': params,
    };
  }
}
