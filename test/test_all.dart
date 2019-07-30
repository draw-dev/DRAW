// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'auth/run_live_auth_tests.dart' as live_auth_test;
import 'comment/comment_test.dart' as comment_test;
import 'frontpage/frontpage_test.dart' as frontpage_test;
import 'gilded_listing_mixin/gilded_listing_mixin_test.dart'
    as gilded_listing_mixin_test;
import 'inbox/inbox_test.dart' as inbox_test;
import 'messageable_mixin/messageable_mixin_test.dart'
    as messageable_mixin_test;
import 'multireddit/multireddit_test.dart' as multireddit_test;
import 'redditor/redditor_test.dart' as redditor_test;
import 'rising_listing_mixin/rising_listing_mixin_test.dart'
    as rising_listing_mixin_test;
import 'submission/submission_test.dart' as submission_test;
import 'subreddit/subreddit_listing_mixin_test.dart'
    as subreddit_listing_mixin_test;
import 'subreddit/subreddit_moderation_test.dart' as subreddit_mod_test;
import 'subreddit/subreddits_test.dart' as subreddits_test;
import 'subreddit/subreddit_test.dart' as subreddit_test;
import 'unit_tests/enum_stringify_test.dart' as enum_stringify_test;
import 'unit_tests/test_draw_config_context.dart' as draw_config_test;
import 'unit_tests/utils_test.dart' as utils_test;
import 'user_content_moderation/user_content_moderation_test.dart'
    as user_content_moderation_test;
import 'user_content/user_content_test.dart' as user_content_test;
import 'user/user_test.dart' as user_test;

void main() {
  live_auth_test.main();
  comment_test.main();
  draw_config_test.main();
  enum_stringify_test.main();
  frontpage_test.main();
  gilded_listing_mixin_test.main();
  inbox_test.main();
  messageable_mixin_test.main();
  multireddit_test.main();
  redditor_test.main();
  rising_listing_mixin_test.main();
  submission_test.main();
  subreddits_test.main();
  subreddit_listing_mixin_test.main();
  subreddit_mod_test.main();
  subreddit_test.main();
  user_content_moderation_test.main();
  user_content_test.main();
  user_test.main();
  utils_test.main();
}
