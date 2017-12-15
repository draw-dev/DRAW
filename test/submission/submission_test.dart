// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future main() async {
  // We use this helper to ensure that our submissions request always uses the
  // exact same DateTime parameters instead of using the current time.
  Stream<Submission> submissionsHelper(Subreddit subreddit) {
    return subreddit.submissions(
        start: new DateTime.utc(2017), end: new DateTime.utc(2017, 10));
  }

  // TODO(bkonyi): crosspost is fairly new on Reddit and is only available to
  // certain users on select subreddits who opted in to the beta. This method
  // does work, but is difficult to test correctly while the feature is in beta.
  // Rewrite this test when crosspost is out of beta.
/*
  test('lib/submission/crosspost', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_crosspost.json',
        live: true);
    final subreddit = new Subreddit.name(reddit, 'woahdude');
    print(await subreddit.property('name'));
    final originalSubmission = new Submission.withPath(reddit,
        'https://www.reddit.com/r/tf2/comments/7919oe/greetings_from_banana_bay/');
    await originalSubmission.crosspost(subreddit,
        title: 'r/tf2 crosspost'
            ' test');
  });
*/

  test('lib/submission/idFromUrl', () {
    final urls = [
      'http://my.it/2gmzqe/',
      'https://redd.it/2gmzqe/',
      'http://reddit.com/comments/2gmzqe/',
      'https://www.reddit.com/r/redditdev/comments/2gmzqe/'
          'praw_https_enabled_praw_testing_needed/'
    ];
    for (final url in urls) {
      expect(Submission.idFromUrl(url), equals('2gmzqe'));
    }
  });

  test('lib/submission/hide-unhide', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    final submission = await submissionsHelper(subreddit).first;
    expect(await submission.property('hidden'), isFalse);
    await submission.hide();
    await submission.refresh();
    expect(await submission.property('hidden'), isTrue);
    await submission.unhide();
    await submission.refresh();
    expect(await submission.property('hidden'), isFalse);
  });

  test('lib/submission/hide-unhide-multiple', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide_multiple.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    final submissions = <Submission>[];
    await for (final submission in submissionsHelper(subreddit)) {
      submissions.add(submission);
      expect(await submission.property('hidden'), isFalse);
    }
    expect(submissions.length, equals(2));
    await submissions[0].hide(otherSubmissions: [submissions[1]]);

    for (final submission in submissions) {
      await submission.refresh();
      expect(await submission.property('hidden'), isTrue);
    }
    await submissions[1].unhide(otherSubmissions: [submissions[0]]);

    for (final submission in submissions) {
      await submission.refresh();
      expect(await submission.property('hidden'), isFalse);
    }
  });

  // TODO(bkonyi): We need to also check the post was
  // successful.
  test('lib/submission/reply', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_reply.json');
    final submission = new Submission.withPath(reddit,
        r'https://www.reddit.com/r/drawapitesting/comments/6rge6g/test_post_please_ignore/');
    await submission.reply('hello world!');
  });
}
