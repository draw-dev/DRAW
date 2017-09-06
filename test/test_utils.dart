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
    final tempReddit = new Reddit(
        'Db_4C6XcNCNqow', 'jwf1U9Nto49rDD7jSFNXBqvG-7s', 'clientAgent',
        username: 'DRAWApiOfficial', password: 'flutterlaurier2017');
    await tempReddit.initialized;
    testAuth = new TestAuthenticator(path, recordAuth: tempReddit.auth);
  } else {
    testAuth = new TestAuthenticator(path);
  }
  final reddit = new Reddit.fromAuthenticator(testAuth);
  await reddit.initialized;
  return reddit;
}
