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

@TestOn('vm || browser')
import 'dart:async';

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/mock.dart';

import '../../naming.dart';

// TODO: tests with headers
void main() {
  final naming = new Naming()
    ..testType = testTypeUnit
    ..topic = topicHttp;

  group(naming.toString(), () {
    group('Http static methods', () {
      Uri requestUri = Uri.parse('https://mock.com/resource?limit=10');

      setUp(() async {
        await MockTransports.reset();
        configureWTransportForTest();
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });

      test('DELETE', () async {
        MockTransports.http.expect('DELETE', requestUri);
        await Http.delete(requestUri);
      });

      test('DELETE withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'DELETE');
        await Future
            .wait([Http.delete(requestUri, withCredentials: true), c.future]);
      });

      test('GET', () async {
        MockTransports.http.expect('GET', requestUri);
        await Http.get(requestUri);
      });

      test('GET withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'GET');
        await Future
            .wait([Http.get(requestUri, withCredentials: true), c.future]);
      });

      test('HEAD', () async {
        MockTransports.http.expect('HEAD', requestUri);
        await Http.head(requestUri);
      });

      test('HEAD withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'HEAD');
        await Future
            .wait([Http.head(requestUri, withCredentials: true), c.future]);
      });

      test('OPTIONS', () async {
        MockTransports.http.expect('OPTIONS', requestUri);
        await Http.options(requestUri);
      });

      test('OPTIONS withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'OPTIONS');
        await Future
            .wait([Http.options(requestUri, withCredentials: true), c.future]);
      });

      test('PATCH', () async {
        MockTransports.http.expect('PATCH', requestUri);
        await Http.patch(requestUri);
      });

      test('PATCH with body', () async {
        final c = new Completer<String>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        }, method: 'PATCH');
        // ignore: unawaited_futures
        Http.patch(requestUri, body: 'body');
        expect(await c.future, equals('body'));
      });

      test('PATCH withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'PATCH');
        await Future
            .wait([Http.patch(requestUri, withCredentials: true), c.future]);
      });

      test('POST', () async {
        MockTransports.http.expect('POST', requestUri);
        await Http.post(requestUri);
      });

      test('POST with body', () async {
        final c = new Completer<String>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        }, method: 'POST');
        // ignore: unawaited_futures
        Http.post(requestUri, body: 'body');
        expect(await c.future, equals('body'));
      });

      test('POST withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'POST');
        await Future
            .wait([Http.post(requestUri, withCredentials: true), c.future]);
      });

      test('PUT', () async {
        MockTransports.http.expect('PUT', requestUri);
        await Http.put(requestUri);
      });

      test('PUT with body', () async {
        final c = new Completer<String>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        }, method: 'PATCH');
        // ignore: unawaited_futures
        Http.patch(requestUri, body: 'body');
        expect(await c.future, equals('body'));
      });

      test('PUT withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'PUT');
        await Future
            .wait([Http.put(requestUri, withCredentials: true), c.future]);
      });

      test('custom method', () async {
        MockTransports.http.expect('COPY', requestUri);
        await Http.send('COPY', requestUri);
      });

      test('custom method with body', () async {
        final c = new Completer<String>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          HttpBody body = request.body;
          c.complete(body.asString());
          return new MockResponse.ok();
        }, method: 'COPY');
        // ignore: unawaited_futures
        Http.send('COPY', requestUri, body: 'body');
        expect(await c.future, equals('body'));
      });

      test('custom method withCredentials', () async {
        final c = new Completer<Null>();
        MockTransports.http.when(requestUri, (FinalizedRequest request) async {
          if (request.withCredentials) {
            c.complete();
          } else {
            c.completeError('withCredentials should be true');
          }
          return new MockResponse.ok();
        }, method: 'COPY');
        await Future.wait(
            [Http.send('COPY', requestUri, withCredentials: true), c.future]);
      });
    });
  });
}
