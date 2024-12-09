import 'package:flutter/widgets.dart';

class AutoTrackElementKey extends Key {
  const AutoTrackElementKey(this.name, {
    this.ignore = false
  }) : super.empty();

  final String name;
  final bool ignore;

  @override
  String toString() {
    return name;
  }
}
