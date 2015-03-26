library w_transport.src.http.w_http_server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:w_transport/w_url.dart' show UrlMutation;
import './w_http.dart';


/// Server-side implementation of an HTTP transport.
/// Uses dart:io.HttpClient and dart:io.HttpClientRequest.
class WRequest extends UrlMutation implements WTransportRequest {
  HttpClientRequest _request;

  /// Create a WRequest that will use its own, new HttpClient instance.
  WRequest() : super(), _client = new HttpClient(), encoding = UTF8;

  /// Create a WRequest with a pre-existing HttpClient instance.
  /// The given HttpClient instance will be used instead of a new one.
  /// WHttpClient uses this constructor.
  WRequest._withClient(HttpClient client) : super(), _client = client;

  /// HttpClient used to send the request.
  HttpClient _client;

  /// Data to write to the request.
  /// Can be a String or Stream.
  dynamic _data;
  dynamic get data => _data;
  void set data(dynamic data) {
    if (data is! String && data is! Stream) {
      throw new ArgumentError('WRequest body must be a String or a Stream.');
    }
    _data = data;
  }

  /// Encoding to use on the request data.
  Encoding encoding;

  /// Headers to send with the HTTP request.
  Map<String, String> headers = {};

  /// Register a callback that will be called after opening, but prior to sending,
  /// the request. The supplied [configureRequest] callback will be called with the
  /// dart:io.HttpClientRequest instance. If the [configureRequest] callback returns
  /// a Future, the request will not be sent until the returned Future completes.
  Function _configure;
  void configure(configure(HttpRequest request)) { _configure = configure; }

  /// Cancel the request. If the request has already finished, this will do nothing.
  void abort() {
    if (_request == null) {
      throw new StateError('Can\'t cancel a request that has not yet been opened.');
    }
    _request.close();
  }

  /// Send a DELETE request.
  Future<WStreamedResponse> delete([Uri url]) {
    return _send('DELETE', url);
  }

  /// Send a GET request.
  Future<WStreamedResponse> get([Uri url]) {
    return _send('GET', url);
  }

  /// Send a HEAD request.
  Future<WStreamedResponse> head([Uri url]) {
    return _send('HEAD', url);
  }

  /// Send an OPTIONS request.
  Future<WStreamedResponse> options([Uri url]) {
    return _send('OPTIONS', url);
  }

  /// Send a PATCH request.
  Future<WStreamedResponse> patch([Uri url, Object data]) {
    return _send('PATCH', url, data);
  }

  /// Send a POST request.
  Future<WStreamedResponse> post([Uri url, Object data]) {
    return _send('POST', url, data);
  }

  /// Send a PUT request.
  Future<WStreamedResponse> put([Uri url, Object data]) {
    return _send('PUT', url, data);
  }

  /// Send a TRACE request.
  Future<WStreamedResponse> trace([Uri url]) {
    return _send('TRACE', url);
  }

  /// Send an HTTP request using dart:io.HttpClient and dart:io.HttpClientRequest
  Future<WStreamedResponse> _send(String method, [Uri url, Object data]) async {
    if (url != null) {
      this.url = url;
    }
    if (data != null) {
      this.data = data;
    }

    if (this.url == null || this.url.toString() == null || this.url.toString() == '') {
      throw new StateError('WRequest: Cannot send a request without a URL.');
    }

    // Attempt to open an HTTP connection
    _request = await _client.openUrl(method, this.url);

    // Add request headers
    if (headers != null) {
      headers.forEach(_request.headers.set);
    }

    // Allow the caller to configure the request
    dynamic configurationResult;
    if (_configure != null) {
      configurationResult = _configure(_request);
    }

    // Wait for the configuration if applicable
    if (configurationResult != null && configurationResult is Future) {
      await configurationResult;
    }

    // If supplied, convert request data to a stream and send.
    if (_data != null) {
      if (_data is String) {
        _data = new Stream.fromIterable([encoding.encode(_data)]);
      }
      _request.contentLength = -1;
      await _request.addStream(_data);
    } else {
      _request.contentLength = 0;
    }

    // Close the request now that data (if any) has been sent and wait for the response
    HttpClientResponse response = await _request.close();
    WStreamedResponse streamedResponse = new _WStreamedResponse.fromHttpClientResponse(response);
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode == 0 || response.statusCode == 304) {
      return streamedResponse;
    } else {
      String errorMessage = 'Failed: $method ${url} ${response.statusCode} (${response.reasonPhrase})';
      throw new WHttpException(errorMessage, url, streamedResponse);
    }
  }

}


/// HTTP client capable of sending many HTTP requests and maintaining
/// persistent connections.
/// TODO: persistent connections
class WHttp implements WTransportHttp {
  HttpClient _client;
  WHttp() : _client = new HttpClient();
  WRequest newRequest() => new WRequest._withClient(_client);
  void close() { _client.close(); }
}


/// Response to a server-side HTTP request.
/// Note that this is a streamed response because server-side HTTP requests
/// receive responses that may be broken up into chunks of bytes.
abstract class WStreamedResponse implements Stream<List<int>>, WTransportResponse {}


/// Internal implementation of a response to a server-side HTTP request.
/// By making the above abstract class public and this implementation private,
/// the class structure can be public without exposing the constructor, since
/// it will only be used internally.
class _WStreamedResponse extends Stream<List<int>> implements WStreamedResponse {
  Map<String, String> _headers;
  HttpClientResponse _response;

  /// Create a streamed response from a completed HttpClientResponse.
  _WStreamedResponse.fromHttpClientResponse(HttpClientResponse response) {
    _response = response;
    _headers = {};
    _response.headers.forEach((String name, List<String> values) {
      _headers[name] = values.join(',');
    });
  }

  /// Forward the stream from the HttpClientResponse.
  StreamSubscription<List<int>> listen(void onData(List<int> event),
                                      { Function onError,
                                        void onDone(),
                                        bool cancelOnError}) {
    return _response.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Map<String, String> get headers => _headers;
  int get status => _response.statusCode;
  String get statusText => _response.reasonPhrase;
}


/// An exception that is raised when a response to a request returns
/// with an unsuccessful status code.
class WHttpException implements WTransportHttpException, Exception {
  /// Descriptive error message that includes the request method & URL and the response status.
  final String message;

  /// Response to the request (some of the properties may be unavailable).
  final WStreamedResponse response;

  /// URL of the attempted/unsuccessful request.
  final Uri url;

  WHttpException(this.message, [this.url, this.response]);

  String toString() => message;
}