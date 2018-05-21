// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import 'credentials.dart';

Future<void> main() async {
  test('read-only', () async {
    final reddit = await Reddit.createReadOnlyInstance(
        kScriptClientID, kScriptClientSecret, 'readonly-client');
    expect(reddit.readOnly, isTrue);
    expect(await reddit.front.hot().first, isNotNull);
  });
}
