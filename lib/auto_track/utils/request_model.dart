class RequestModel {
  RequestModel({
    required this.uri,
    required this.method,
    required this.message,
    required this.status,
    required this.spent,
    required this.pageId,
    this.requestBody,
    this.requestHeaders,
    this.responseHeaders,
  });

  Uri uri;
  String method;
  String message;
  String pageId;
  int status;
  int spent;
  dynamic requestBody;
  dynamic requestHeaders;
  dynamic responseHeaders;

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'method': method,
      'message': message,
      'pageId': pageId,
      'status': status,
      'spent': spent,
      'requestBody': requestBody,
      'requestHeaders': requestHeaders,
      'responseHeaders': responseHeaders,
    };
  }
}