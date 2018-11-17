// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';

import 'package:test/test.dart';
import '../test_utils.dart';

Future<void> main() async {
  // TODO(bkonyi): rewrite these to actually check that the messages were
  // received. Manually confirmed for now.
  test('lib/messageable_mixin/basic_message', () async {
    final reddit = await createRedditTestInstance(
        'test/messageable_mixin/basic_message.json');
    final receiver = reddit.redditor('XtremeCheese');
    await receiver.message('Test message', 'Hello XtremeCheese!');
  });

  test('lib/messageable_mixin/subreddit_message', () async {
    final reddit = await createRedditTestInstance(
        'test/messageable_mixin/subreddit_message.json');
    final receiver = reddit.redditor('Toxicity-Moderator');
    final subreddit = reddit.subreddit('drawapitesting');
    await receiver.message('Test message', 'Hello Toxicity-Moderator!',
        fromSubreddit: subreddit);
  });

  test('lib/messageable_mixin/invalid_subreddit', () async {
    final reddit = await createRedditTestInstance(
        'test/messageable_mixin/invalid_subreddit.json');
    final receiver = reddit.redditor('Toxicity-Moderator');
    final subreddit = reddit.subreddit('drawapitesting2');
    await expectLater(
        () async => await receiver.message(
            'Test message', 'Hello Toxicity-Moderator!',
            fromSubreddit: subreddit),
        throwsA(TypeMatcher<DRAWInvalidSubredditException>()));
  });
  
  test('lib/messageable_mixin/invalid_redditor', () async {
    final reddit = await createRedditTestInstance(
        'test/messageable_mixin/invalid_redditor.json');
    final receiver = reddit.redditor('Toxicity-Moderator2');
    final subreddit = reddit.subreddit('drawapitesting');
    await expectLater(
        () async => await receiver.message(
            'Test message', 'Hello Toxicity-Moderator!',
            fromSubreddit: subreddit),
        throwsA(TypeMatcher<DRAWInvalidRedditorException>()));
  });

}
