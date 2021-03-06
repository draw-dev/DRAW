// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/exceptions.dart';

const int kHttpBadRequest = 400;
const int kHttpNotFound = 404;

void parseAndThrowError(int status, Map<String, dynamic> response) {
  switch (status) {
    case kHttpBadRequest:
    case kHttpNotFound:
      throw DRAWNotFoundException(response['reason'], response['message']);
    default:
      throw DRAWUnknownResponseException(status, response.toString());
  }
}
