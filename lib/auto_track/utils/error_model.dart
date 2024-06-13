class ErrorModel {
  final Object error;
  final StackTrace stack;

  ErrorModel({required this.error, required this.stack});

  Map<String, dynamic> toMap() {
    return {
      'error': error.toString(),
      'stack': stack.toString(),
      'key': error.runtimeType.toString()
    };
  }
}
