// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'comment/comment_test.dart' as comment_test;
import 'frontpage/frontpage_test.dart' as frontpage_test;
import 'inbox/inbox_test.dart' as inbox_test;
import 'redditor/redditor_test.dart' as redditor_test;
import 'rising_listing_mixin/rising_listing_mixin_test.dart'
    as rising_listing_mixin_test;
import 'submission/submission_test.dart' as submission_test;
import 'subreddit/subreddit_test.dart' as subreddit_test;
import 'subreddit/subreddit_moderation_test.dart' as subreddit_mod_test;
import 'unit_tests/src/test_draw_config_context.dart' as draw_config_test;
import 'user/user_test.dart' as user_test;
import 'user_content/user_content_test.dart' as user_content_test;

void main() {
  comment_test.main();
  frontpage_test.main();
  inbox_test.main();
  rising_listing_mixin_test.main();
  redditor_test.main();
  submission_test.main();
  subreddit_test.main();
  subreddit_mod_test.main();
  draw_config_test.main();
  user_test.main();
  user_content_test.main();
}
