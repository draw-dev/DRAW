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
    return subreddit.newest().map<Submission>((u) => u as Submission);
  }

  test('lib/submission/invalid', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_invalid.json');
    await expectLater(
        () async => await reddit.submission(id: 'abcdef').populate(),
        throwsA(TypeMatcher<DRAWInvalidSubmissionException>()));
  });

  test('lib/submission/properties-sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_properties.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    expect(submission.approvedAt,
        DateTime.fromMillisecondsSinceEpoch(1524535384000));
    expect(submission.approved, isTrue);
    expect(submission.approvedBy.displayName, 'DRAWApiOfficial');
    expect(submission.archived, isFalse);
    expect(submission.authorFlairText, isNull);
    expect(submission.bannedAt, isNull);
    expect(submission.bannedBy, isNull);
    expect(submission.brandSafe, isNull);
    expect(submission.canGild, isFalse);
    expect(submission.canModeratePost, isTrue);
    expect(submission.clicked, isFalse);
    expect(submission.createdUtc,
        DateTime.fromMillisecondsSinceEpoch(1518491082000, isUtc: true));
    expect(submission.distinguished, isNull);
    expect(submission.domain, 'youtube.com');
    expect(submission.downvotes, 0);
    expect(submission.edited, isFalse);
    expect(submission.gilded, 0);
    expect(submission.hidden, isFalse);
    expect(submission.hideScore, isFalse);
    expect(submission.ignoreReports, isFalse);
    expect(submission.isCrosspostable, isTrue);
    expect(submission.isRedditMediaDomain, isFalse);
    expect(submission.isSelf, isFalse);
    expect(submission.isVideo, isFalse);
    expect(submission.likes, isTrue);
    expect(submission.vote, VoteState.upvoted);
    expect(submission.locked, isFalse);
    expect(submission.numComments, 2);
    expect(submission.numCrossposts, 0);
    expect(submission.over18, isFalse);
    expect(submission.pinned, isFalse);
    expect(submission.quarantine, isFalse);
    expect(submission.removalReason, isNull);
    expect(submission.score, 1);
    expect(submission.selftext, '');
    expect(submission.spam, isFalse);
    expect(submission.spoiler, isFalse);
    expect(submission.subredditType, 'restricted');
    expect(submission.stickied, isFalse);
    expect(
        submission.title,
        'DRAW: Using Dart to Moderate Reddit Comments'
        ' (DartConf 2018)');
    expect(
        submission.thumbnail,
        Uri.parse(
            'https://a.thumbs.redditmedia.com/HP1keD9FPMG7fSBFZQk94HlJ4n13VB13yZagixx0wz4.jpg'));
    expect(submission.upvoteRatio, 1.0);
    expect(submission.upvotes, 1);
    expect(submission.url,
        Uri.parse('https://www.youtube.com/watch?v=VqNU_CYVaXg'));
    expect(submission.viewCount, 16);
    expect(submission.visited, isFalse);
    expect(submission.commentSort, CommentSortType.best);
  });

  test('lib/submission/refresh-comments-sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_refresh_comments_sanity.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    final originalComments = submission.comments;
    final updatedComments = await submission.refreshComments();
    expect(submission.comments, updatedComments);
    expect(originalComments.length, updatedComments.length);
  });

  test('lib/submission/crosspost', () async {
    final reddit = await createRedditTestInstance(
      'test/submission/lib_submission_crosspost.json',
    );
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final originalSubmission = await reddit
        .submission(
            url:
                'https://www.reddit.com/r/tf2/comments/7919oe/greetings_from_banana_bay/')
        .populate();
    await originalSubmission.crosspost(subreddit,
        title: 'r/tf2 crosspost'
            ' test');
  });

  test('lib/submission/idFromUrl', () {
    final urls = [
      'http://my.it/2gmzqe/',
      'https://redd.it/2gmzqe/',
      'http://reddit.com/comments/2gmzqe/',
      'https://www.reddit.com/r/redditdev/comments/2gmzqe/'
          'praw_https_enabled_praw_testing_needed/'
    ];
    for (final url in urls) {
      expect(SubmissionRef.idFromUrl(url), equals('2gmzqe'));
    }
  });

  test('lib/submission/hide-unhide', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission = await submissionsHelper(subreddit).first;
    expect(submission.hidden, isFalse);
    await submission.hide();
    await submission.refresh();
    expect(submission.hidden, isTrue);
    await submission.unhide();
    await submission.refresh();
    expect(submission.hidden, isFalse);
  });

  test('lib/submission/hide-unhide-multiple', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide_multiple.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submissions = <Submission>[];
    await for (final submission in submissionsHelper(subreddit)) {
      submissions.add(submission);
      expect(submission.hidden, isFalse);
    }
    expect(submissions.length, equals(3));
    await submissions[0].hide(otherSubmissions: submissions.sublist(1));

    for (final submission in submissions) {
      await submission.refresh();
      expect(submission.hidden, isTrue);
    }
    await submissions[0].unhide(otherSubmissions: submissions.sublist(1));

    for (final submission in submissions) {
      await submission.refresh();
      expect(submission.hidden, isFalse);
    }
  });

  // TODO(bkonyi): We need to also check the post was
  // successful.
  test('lib/submission/reply', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_reply.json');
    final submission = await (SubmissionRef.withPath(reddit,
            r'https://www.reddit.com/r/drawapitesting/comments/7x6ew7/draw_using_dart_to_moderate_reddit_comments/'))
        .populate();
    await submission.reply('Woohoo!');
  });

  test('lib/submission/submission_flair', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_flair.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    final flair = submission.flair;
    final choices = await flair.choices();
    expect(choices.length, 1);
    expect(submission.linkFlairText, null);
    await flair.select(choices[0].flairTemplateId,
        text: 'Testing Submission Flair');
    await submission.refresh();
    expect(submission.linkFlairText, 'Testing Submission Flair');
    await flair.select(choices[0].flairTemplateId);
    await submission.refresh();
    expect(submission.linkFlairText, '');
  });
}
