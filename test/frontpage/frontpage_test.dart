// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future<void> main() async {
  // TODO(bkonyi): this is more of a sanity check, but all the functionality in
  // [FrontPage] should have been tested elsewhere. Might want to expand this
  // coverage anyway.
  test('lib/frontpage/sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/frontpage/lib_frontpage_sanity.json');
    await for (final hot in reddit.front.hot(params: {'limit': '10'})) {
      expect(hot is Submission, isTrue);
    }
  });

  test('lib/frontpage/best', () async {
    final reddit = await createRedditTestInstance(
        'test/frontpage/lib_frontpage_best.json');
    await for (final hot in reddit.front.best(params: {'limit': '10'})) {
      expect(hot is Submission, isTrue);
    }
  });
}
