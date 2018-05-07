// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/gilded_listing_mixin/front_page_gilded', () async {
    final reddit = await createRedditTestInstance(
        'test/gilded_listing_mixin/lib_gilded_listing_mixin_frontpage.json');
    await for (final content in reddit.front.gilded(params: {'limit': 10})) {
      expect(content is UserContentInitialized, isTrue);
      expect(content.gilded > 0, isTrue);
    }
  });
}
