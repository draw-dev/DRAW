// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'test_authenticator.dart';

Future<Reddit> createRedditTestInstance(String path, {bool live: false}) async {
  var testAuth;
  if (live) {
    final tempReddit = await Reddit.createInstance(siteName: 'DRAWApiOfficial');
    testAuth = new TestAuthenticator(path, recordAuth: tempReddit.auth);
  } else {
    testAuth = new TestAuthenticator(path);
  }
  return new Reddit.fromAuthenticator(testAuth);
}
