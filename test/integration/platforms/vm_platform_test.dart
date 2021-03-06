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

@TestOn('vm')
library w_transport.test.integration.platforms.vm_platform_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/w_transport_vm.dart';

import 'package:w_transport/src/http/vm/client.dart';
import 'package:w_transport/src/http/vm/requests.dart';

import '../../naming.dart';

void main() {
  Naming naming = new Naming()
    ..platform = platformVM
    ..testType = testTypeIntegration
    ..topic = topicPlatformAdapter;

  group(naming.toString(), () {
    setUp(() {
      configureWTransportForVM();
    });

    test('newClient()', () {
      expect(new Client(), new isInstanceOf<VMClient>());
    });

    test('newFormRequest()', () {
      expect(new FormRequest(), new isInstanceOf<VMFormRequest>());
    });

    test('newJsonRequest()', () {
      expect(new JsonRequest(), new isInstanceOf<VMJsonRequest>());
    });

    test('newMultipartRequest()', () {
      expect(new MultipartRequest(), new isInstanceOf<VMMultipartRequest>());
    });

    test('newRequest()', () {
      expect(new Request(), new isInstanceOf<VMPlainTextRequest>());
    });

    test('newStreamedRequest()', () {
      expect(new StreamedRequest(), new isInstanceOf<VMStreamedRequest>());
    });
  });
}
