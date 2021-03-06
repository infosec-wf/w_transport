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

library w_transport.test.unit.http.response_format_exception_test;

import 'dart:convert';

import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:test/test.dart';

import 'package:w_transport/src/http/response_format_exception.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('ResponseFormatException', () {
      test('should detail why bytes could not be decoded', () {
        var bytes = UTF8.encode('bodyçå®');
        var contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        var exception =
            new ResponseFormatException(contentType, ASCII, bytes: bytes);
        expect(exception.toString(), contains('Bytes could not be decoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: ${ASCII.name}'));
        expect(
            exception.toString(), contains(UTF8.encode('bodyçå®').toString()));
      });

      test('should detail why string could not be encoded', () {
        var body = 'bodyçå®';
        var contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        var exception =
            new ResponseFormatException(contentType, ASCII, body: body);
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: ${ASCII.name}'));
        expect(exception.toString(), contains('bodyçå®'));
      });

      test('should warn if encoding is null', () {
        var body = 'bodyçå®';
        var contentType =
            new MediaType('application', 'json', {'charset': ASCII.name});
        var exception =
            new ResponseFormatException(contentType, null, body: body);
        expect(exception.toString(), contains('Body could not be encoded'));
        expect(exception.toString(), contains('Content-Type: $contentType'));
        expect(exception.toString(), contains('Encoding: null'));
        expect(exception.toString(), contains('bodyçå®'));
      });
    });
  });
}
