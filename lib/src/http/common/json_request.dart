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

library w_transport.src.http.common.json_request;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:w_transport/src/http/client.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/http_body.dart';
import 'package:w_transport/src/http/requests.dart';

abstract class CommonJsonRequest extends CommonRequest implements JsonRequest {
  CommonJsonRequest() : super();
  CommonJsonRequest.fromClient(Client wTransportClient, client)
      : super.fromClient(wTransportClient, client);

  String _encodedJson;
  dynamic _source;

  dynamic get body => _source;

  set body(dynamic json) {
    verifyUnsent();
    // Store the source so it can be returned from the getter without having to
    // decode it again.
    _source = json;

    // Encode immediately so that we can attempt decoding it such that invalid
    // JSON will result in an exception now rather than later.
    _encodedJson = JSON.encode(json);
    JSON.decode(_encodedJson);
  }

  @override
  int get contentLength => _bytes.length;

  @override
  MediaType get defaultContentType =>
      new MediaType('application', 'json', {'charset': encoding.name});

  // Calculate each time because body can be modified outside of the setter.
  Uint8List get _bytes => _encodedJson != null
      ? encoding.encode(_encodedJson)
      : new Uint8List.fromList([]);

  @override
  JsonRequest clone() {
    return (super.clone() as JsonRequest)..body = _source;
  }

  @override
  Future<HttpBody> finalizeBody([body]) async {
    if (body != null) {
      this.body = body;
    }
    return new HttpBody.fromBytes(contentType, _bytes);
  }
}
