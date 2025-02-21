class RequestModel {
  RequestModel({
    required this.uri,
    required this.method,
    required this.message,
    required this.status,
    required this.spent,
    required this.pageId,
    this.requestHeaders,
    this.responseHeaders,
    this.responseBody,
  });

  Uri uri;
  String method;
  String message;
  String pageId;
  int status;
  int spent;
  dynamic requestHeaders;
  dynamic responseHeaders;
  String? responseBody;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri.toString(),
      'method': method,
      'message': message,
      'pageId': pageId,
      'status': status,
      'spent': spent,
      'requestHeaders': requestHeaders.toString(),
      'responseHeaders': responseHeaders.toString(),
      'responseBody': responseBody,
    };
  }
}