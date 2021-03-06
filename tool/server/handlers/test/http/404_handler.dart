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

library w_transport.tool.server.handlers.test.http.fourzerofour_handler;

import 'dart:async';
import 'dart:io';

import '../../../handler.dart';

/// Always responds with a 404 Not Found.
class FourzerofourHandler extends Handler {
  FourzerofourHandler() : super() {
    enableCors();
  }

  Future notFound(HttpRequest request) async {
    request.response.statusCode = HttpStatus.NOT_FOUND;
    setCorsHeaders(request);
  }

  Future delete(HttpRequest request) => notFound(request);
  Future get(HttpRequest request) => notFound(request);
  Future head(HttpRequest request) => notFound(request);
  Future options(HttpRequest request) => notFound(request);
  Future patch(HttpRequest request) => notFound(request);
  Future post(HttpRequest request) => notFound(request);
  Future put(HttpRequest request) => notFound(request);
  Future trace(HttpRequest request) => notFound(request);
}
