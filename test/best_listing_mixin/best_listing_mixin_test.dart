// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/best_listing_mixin/best_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/best_listing_mixin/lib_best_listing_mixin_best.json');
    await for (final best in reddit.front.best(params: {'limit': '10'})) {
      expect(best is Submission, isTrue);
    }
  });
}
