class TrackModel {
  final String type;
  final int time;
  final Map<String, dynamic> params;
  TrackModel(this.type, this.time, this.params);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'time': time,
      'params': params,
    };
  }
}
