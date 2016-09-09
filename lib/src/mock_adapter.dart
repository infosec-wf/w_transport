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

import 'package:w_transport/src/http/http_client.dart';
import 'package:w_transport/src/http/mock/http_client.dart';
import 'package:w_transport/src/http/mock/requests.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/platform_adapter.dart';
import 'package:w_transport/src/web_socket/mock/w_socket.dart';
import 'package:w_transport/src/web_socket/web_socket.dart';

/// Adapter for the testing environment. Exposes factories for all of the
/// transport classes that return mock implementations that can be controlled
/// by the mock transport API.
class MockAdapter implements PlatformAdapter {
  /// Construct a new [MockHttpClient] instance that implements [HttpClient].
  @override
  HttpClient newHttpClient() => new MockHttpClient();

  /// Construct a new [MockFormRequest] instance that implements
  /// [FormRequest].
  @override
  FormRequest newFormRequest() => new MockFormRequest();

  /// Construct a new [MockJsonRequest] instance that implements
  /// [JsonRequest].
  @override
  JsonRequest newJsonRequest() => new MockJsonRequest();

  /// Construct a new [MockMultipartRequest] instance that implements
  /// [MultipartRequest].
  @override
  MultipartRequest newMultipartRequest() => new MockMultipartRequest();

  /// Construct a new [MockPlainTextRequest] instance that implements
  /// [Request].
  @override
  Request newRequest() => new MockPlainTextRequest();

  /// Construct a new [MockStreamedRequest] instance that implements
  /// [StreamedRequest].
  @override
  StreamedRequest newStreamedRequest() => new MockStreamedRequest();

  /// Construct a new [MockWebSocket] instance that implements [WebSocket].
  @override
  Future<WebSocket> newWebSocket(Uri uri,
          {Map<String, dynamic> headers,
          Iterable<String> protocols,
          bool sockJSDebug,
          bool sockJSNoCredentials,
          List<String> sockJSProtocolsWhitelist,
          Duration sockJSTimeout,
          bool useSockJS}) =>
      MockWSocket.connect(uri, protocols: protocols, headers: headers);
}
