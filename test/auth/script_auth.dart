// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import 'credentials.dart';

Future<void> main() async {
  test('script authenticator', () async {
    if (SCRIPT_CLIENT_SECRET == null) return;
    final reddit = await Reddit.createScriptInstance(
        clientId: SCRIPT_CLIENT_ID,
        clientSecret: SCRIPT_CLIENT_SECRET,
        userAgent: 'script-client-DRAW-live-testing',
        username: USERNAME,
        password: PASSWORD);
    expect(reddit.readOnly, isFalse);
    print(await reddit.user.me());
  });
}
