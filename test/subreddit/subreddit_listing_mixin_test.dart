// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/subreddit/subreddit_listing_mixin_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_listing_mixin_sanity.json');
    final subreddit = reddit.subreddit('funny');
    await for (final content in subreddit.comments(params: {'limit': '10'})) {
      expect(content is Comment, isTrue);
      expect(content.body, isNotNull);
    }
  });
}
