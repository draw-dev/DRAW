// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> main() async {
  Stream<Submission> submissionsHelper(SubredditRef subreddit) {
    return subreddit.newest().cast<Submission>();
  }

  test('lib/user_content/replyable', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_replyable.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission =
        await subreddit.submit('Replyable submission', selftext: 'Testing!');
    final comment = await submission.reply('Test comment!');
    expect(comment.body, equals('Test comment!'));
    await submission.delete();
    await comment.delete();
  });

  test('lib/user_content/reportable', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_reportable.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission = await subreddit.submit('Reportable submission',
        selftext: 'Rule'
            ' breaking!');
    await submission.report('Breaks rule 42');
    await submission.refresh();
    expect(submission.modReports[0],
        equals(<String>['Breaks rule 42', 'DRAWApiOfficial']));
    await submission.delete();
  });

  // There doesn't seem to be a way to check if inbox replies are enabled or
  // disabled through the API, so we're just going to check that the API calls
  // don't crash anything.
  // TODO(bkonyi): find out if we can see if inbox replies are enabled through
  // the API.
  test('lib/user_content/inbox_toggleable', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_toggleable.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission =
        await subreddit.submit('Editable submission', selftext: 'Testing!');
    await submission.disableInboxReplies();
    await submission.enableInboxReplies();
  });

  test('lib/user_content/saveable', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_saveable.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission =
        await subreddit.submit('Saveable submission', selftext: 'Testing!');
    await submission.refresh();
    expect(submission.saved, isFalse);
    await submission.save();
    await submission.refresh();
    expect(submission.saved, isTrue);
    await submission.unsave();
    await submission.refresh();
    expect(submission.saved, isFalse);
    await submission.delete();
  });

  test('lib/user_content/submit-editable-delete', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_editable.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission =
        await subreddit.submit('Editable submission', selftext: 'Testing!');
    await submission.refresh();
    expect(submission.selftext, equals('Testing!'));
    await submission.edit('Edited!');
    expect(submission.selftext, equals('Edited!'));
    await submission.delete();
  });

  test('lib/user_content/votes', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content/lib_user_content_votes.json');
    final redditor = reddit.redditor('DRAWApiOfficial');
    Future<List<String>> getUpvoted() async {
      final upvoted = <String>[];
      await for (final submission in redditor.upvoted()) {
        expect(submission is Submission, isTrue);
        upvoted.add((submission as Submission).fullname!);
      }
      return upvoted;
    }

    Future<List<String>> getDownvoted() async {
      final upvoted = <String>[];
      await for (final submission in redditor.downvoted()) {
        expect(submission is Submission, isTrue);
        upvoted.add((submission as Submission).fullname!);
      }
      return upvoted;
    }

    final subreddit = reddit.subreddit('drawapitesting');
    var upvoted = await getUpvoted();
    var downvoted = await getDownvoted();
    await for (final submission in submissionsHelper(subreddit)) {
      expect(upvoted.contains(submission.fullname), isFalse);
      expect(downvoted.contains(submission.fullname), isFalse);
      await submission.upvote();
    }

    upvoted = await getUpvoted();
    downvoted = await getDownvoted();
    await for (final submission in submissionsHelper(subreddit)) {
      expect(upvoted.contains(submission.fullname), isTrue);
      expect(downvoted.contains(submission.fullname), isFalse);
      await submission.downvote();
    }

    upvoted = await getUpvoted();
    downvoted = await getDownvoted();
    await for (final submission in submissionsHelper(subreddit)) {
      expect(upvoted.contains(submission.fullname), isFalse);
      expect(downvoted.contains(submission.fullname), isTrue);
      await submission.clearVote();
    }

    upvoted = await getUpvoted();
    downvoted = await getDownvoted();
    await for (final submission in submissionsHelper(subreddit)) {
      expect(upvoted.contains(submission.fullname), isFalse);
      expect(downvoted.contains(submission.fullname), isFalse);
    }
  });
}
