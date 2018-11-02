// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:draw/src/logging.dart';
import 'auth/credentials.dart';
import 'test_authenticator.dart';

Future<Reddit> createRedditTestInstance(String path, {bool live: false}) async {
  var testAuth;
//  DRAWLoggingUtils.initialize();
//  DRAWLoggingUtils.setLogLevel(Level.INFO);
  if (live) {
    final tempReddit = await Reddit.createScriptInstance(
        userAgent: 'foobar',
        username: kUsername,
        password: kPassword,
        clientId: kScriptClientID,
        clientSecret: kScriptClientSecret);
    testAuth = TestAuthenticator(path, recordAuth: tempReddit.auth);
  } else {
    testAuth = TestAuthenticator(path);
  }
  return Reddit.fromAuthenticator(testAuth);
}

Future<void> writeRecording(Reddit reddit) async {
  assert(reddit.auth is TestAuthenticator);
  final TestAuthenticator auth = reddit.auth;
  await auth.writeRecording();
}
