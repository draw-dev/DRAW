// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/rising_listing_mixin/random_rising_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/rising_listing_mixin/lib_rising_listing_mixin_random_rising.json');
    await for (final rand
        in reddit.front.randomRising(params: {'limit': '10'})) {
      expect(rand is Submission, isTrue);
    }
  });

  test('lib/rising_listing_mixin/rising_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/rising_listing_mixin/lib_rising_listing_mixin_rising.json');
    await for (final rise in reddit.front.rising(params: {'limit': '10'})) {
      expect(rise is Submission, isTrue);
    }
  });
}
