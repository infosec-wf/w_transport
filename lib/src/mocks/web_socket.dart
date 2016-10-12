// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:w_transport/src/web_socket/mock/w_socket.dart';
import 'package:w_transport/src/web_socket/w_socket.dart';
import 'package:w_transport/src/web_socket/web_socket_exception.dart';

typedef Future<WSocket> WSocketConnectHandler(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers});
typedef Future<WSocket> WSocketPatternConnectHandler(Uri uri,
    {Iterable<String> protocols, Map<String, dynamic> headers, Match match});

class MockWebSocket {
  const MockWebSocket();

  void expect(Uri uri, {MockWSocket connectTo, bool reject}) {
    MockWebSocketInternal._expect(uri, connectTo: connectTo, reject: reject);
  }

  void expectPattern(Pattern uriPattern, {MockWSocket connectTo, bool reject}) {
    MockWebSocketInternal._expect(uriPattern,
        connectTo: connectTo, reject: reject);
  }

  void reset() {
    MockWebSocketInternal._expectations = [];
    MockWebSocketInternal._handlers = {};
    MockWebSocketInternal._patternHandlers = {};
  }

  MockWebSocketHandler when(Uri uri,
      {WSocketConnectHandler handler, bool reject}) {
    MockWebSocketInternal._validateWhenParams(handler: handler, reject: reject);
    if (reject != null && reject) {
      handler = (uri, {protocols, headers}) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      };
    }
    MockWebSocketInternal._handlers[uri.toString()] = handler;

    return new MockWebSocketHandler._(() {
      final currentHandler = MockWebSocketInternal._handlers[uri.toString()];
      if (currentHandler != null && currentHandler == handler) {
        MockWebSocketInternal._handlers.remove(uri.toString());
      }
    });
  }

  MockWebSocketHandler whenPattern(Pattern uriPattern,
      {WSocketPatternConnectHandler handler, bool reject}) {
    MockWebSocketInternal._validateWhenParams(handler: handler, reject: reject);
    if (reject == true) {
      handler = (uri, {protocols, headers, match}) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      };
    }
    MockWebSocketInternal._patternHandlers[uriPattern] = handler;

    return new MockWebSocketHandler._(() {
      final currentHandler = MockWebSocketInternal._patternHandlers[uriPattern];
      if (currentHandler != null && currentHandler == handler) {
        MockWebSocketInternal._patternHandlers.remove(uriPattern);
      }
    });
  }
}

class MockWebSocketHandler {
  Function _cancel;
  MockWebSocketHandler._(this._cancel);

  void cancel() {
    _cancel();
  }
}

class MockWebSocketInternal {
  static List<_WebSocketConnectExpectation> _expectations = [];
  static Map<String, WSocketConnectHandler> _handlers = {};
  static Map<Pattern, WSocketPatternConnectHandler> _patternHandlers = {};

  static Future<WSocket> handleWebSocketConnection(Uri uri,
      {Iterable<String> protocols, Map<String, dynamic> headers}) async {
    final matchingExpectations = _getMatchingExpectations(uri);
    if (matchingExpectations.isNotEmpty) {
      // If this connection was expected, resolve it as planned.
      _WebSocketConnectExpectation expectation = matchingExpectations.first;
      _expectations.remove(expectation);
      if (expectation.reject != null && expectation.reject) {
        throw new WebSocketException('Mock connection to $uri rejected.');
      }
      return expectation.connectTo;
    }

    final handlerMatch = _getMatchingHandler(uri);
    if (handlerMatch != null) {
      // If a handler was set up for this type of connection, call the handler.
      if (handlerMatch.handler is WSocketPatternConnectHandler) {
        return handlerMatch.handler(uri,
            protocols: protocols, headers: headers, match: handlerMatch.match);
      } else {
        return handlerMatch.handler(uri,
            protocols: protocols, headers: headers);
      }
    }

    throw new StateError('Unexpected WSocket connection: $uri');
  }

  static bool hasHandlerForWebSocket(Uri uri) {
    if (_getMatchingExpectations(uri).isNotEmpty) return true;
    if (_getMatchingHandler(uri) != null) return true;
    return false;
  }

  static void _expect(Object uri, {MockWSocket connectTo, bool reject}) {
    if (connectTo != null && reject != null) {
      throw new ArgumentError('Use connectTo OR reject, but not both.');
    }
    if (connectTo == null && reject == null) {
      throw new ArgumentError('Either connectTo OR reject must be set.');
    }
    _expectations.add(new _WebSocketConnectExpectation(uri,
        connectTo: connectTo, reject: reject));
  }

  static Iterable<_WebSocketConnectExpectation> _getMatchingExpectations(
      Uri uri) {
    return _expectations.where((e) {
      if (e.uri is Uri) {
        return e.uri == uri;
      } else if (e.uri is Pattern) {
        final Pattern pattern = e.uri;
        return pattern.allMatches(uri.toString()).isNotEmpty;
      }
    });
  }

  static _WebSocketHandlerMatch _getMatchingHandler(Uri uri) {
    if (_handlers.containsKey(uri.toString())) {
      return new _WebSocketHandlerMatch(_handlers[uri.toString()]);
    }

    Match match;
    final matchingHandlerKey = _patternHandlers.keys.firstWhere((uriPattern) {
      final matches = uriPattern.allMatches(uri.toString());
      if (matches.isNotEmpty) {
        match = matches.first;
        return true;
      }
      return false;
    }, orElse: () => null);

    if (matchingHandlerKey != null) {
      return new _WebSocketHandlerMatch(_patternHandlers[matchingHandlerKey],
          match: match);
    }

    return null;
  }

  static void _validateWhenParams({dynamic handler, bool reject}) {
    if (handler != null && reject != null) {
      throw new ArgumentError('Use handler OR reject, but not both.');
    }
    if (handler == null && reject == null) {
      throw new ArgumentError('Either handler OR reject must be set.');
    }
  }
}

class _WebSocketConnectExpectation {
  WSocket connectTo;
  bool reject;
  final Object uri;

  _WebSocketConnectExpectation(this.uri, {this.connectTo, this.reject});
}

class _WebSocketHandlerMatch {
  final Object handler;
  final Match match;

  _WebSocketHandlerMatch(this.handler, {this.match});
}
