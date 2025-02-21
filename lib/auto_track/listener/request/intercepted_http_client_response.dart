import 'dart:async';
import 'dart:io';

class InterceptedHttpClientResponse implements HttpClientResponse {
  final HttpClientResponse _original;
  final Stream<List<int>> _stream;

  InterceptedHttpClientResponse(this._original, this._stream);

  @override
  HttpHeaders get headers => _original.headers;

  @override
  int get statusCode => _original.statusCode;

  @override
  String get reasonPhrase => _original.reasonPhrase;

  @override
  int get contentLength => _original.contentLength;

  @override
  HttpClientResponseCompressionState get compressionState =>
      _original.compressionState;

  @override
  bool get persistentConnection => _original.persistentConnection;

  @override
  bool get isRedirect => _original.isRedirect;

  @override
  List<RedirectInfo> get redirects => _original.redirects;

  @override
  Future<HttpClientResponse> redirect(
      [String? method, Uri? url, bool? followLoops]) {
    return _original.redirect(method, url, followLoops);
  }

  @override
  Future<Socket> detachSocket() {
    return _original.detachSocket();
  }

  @override
  List<Cookie> get cookies => _original.cookies;

  @override
  X509Certificate? get certificate => _original.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => _original.connectionInfo;

  @override
  Future<bool> any(bool Function(List<int> element) test) {
    return _stream.any(test);
  }

  @override
  Stream<List<int>> asBroadcastStream(
      {void Function(StreamSubscription<List<int>> subscription)? onListen,
        void Function(StreamSubscription<List<int>> subscription)? onCancel}) {
    return _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(List<int> event) convert) {
    return _stream.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(List<int> event) convert) {
    return _stream.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _stream.cast();
  }

  @override
  Future<bool> contains(Object? needle) {
    return _stream.contains(needle);
  }

  @override
  Stream<List<int>> distinct(
      [bool Function(List<int> previous, List<int> next)? equals]) {
    return _stream.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _stream.drain(futureValue);
  }

  @override
  Future<List<int>> elementAt(int index) {
    return _stream.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(List<int> element) test) {
    return _stream.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(List<int> element) convert) {
    return _stream.expand(convert);
  }

  @override
  Future<List<int>> get first => _stream.first;

  @override
  Future<List<int>> firstWhere(bool Function(List<int> element) test,
      {List<int> Function()? orElse}) {
    return _stream.firstWhere(test, orElse: orElse);
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, List<int> element) combine) {
    return _stream.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(List<int> element) action) {
    return _stream.forEach(action);
  }

  @override
  Stream<List<int>> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
    return _stream.handleError(onError, test: test);
  }

  @override
  bool get isBroadcast => _stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) {
    return _stream.join(separator);
  }

  @override
  Future<List<int>> get last => _stream.last;

  @override
  Future<List<int>> lastWhere(bool Function(List<int> element) test,
      {List<int> Function()? orElse}) {
    return _stream.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => _stream.length;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(List<int> event) convert) {
    return _stream.map(convert);
  }

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) {
    return _stream.pipe(streamConsumer);
  }

  @override
  Future<List<int>> reduce(
      List<int> Function(List<int> previous, List<int> element) combine) {
    return _stream.reduce(combine);
  }

  @override
  Future<List<int>> get single => _stream.single;

  @override
  Future<List<int>> singleWhere(bool Function(List<int> element) test,
      {List<int> Function()? orElse}) {
    return _stream.singleWhere(test, orElse: orElse);
  }

  @override
  Stream<List<int>> skip(int count) {
    return _stream.skip(count);
  }

  @override
  Stream<List<int>> skipWhile(bool Function(List<int> element) test) {
    return _stream.skipWhile(test);
  }

  @override
  Stream<List<int>> take(int count) {
    return _stream.take(count);
  }

  @override
  Stream<List<int>> takeWhile(bool Function(List<int> element) test) {
    return _stream.takeWhile(test);
  }

  @override
  Stream<List<int>> timeout(Duration timeLimit,
      {void Function(EventSink<List<int>> sink)? onTimeout}) {
    return _stream.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<List<int>>> toList() {
    return _stream.toList();
  }

  @override
  Future<Set<List<int>>> toSet() {
    return _stream.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return _stream.transform(streamTransformer);
  }

  @override
  Stream<List<int>> where(bool Function(List<int> event) test) {
    return _stream.where(test);
  }
}