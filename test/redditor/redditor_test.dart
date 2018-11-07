// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/redditor/invalid_redditor', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_invalid.json');
    await expectLater(
        () async => await reddit.redditor('drawapiofficial2').populate(),
        throwsA(TypeMatcher<DRAWInvalidRedditorException>()));
  });

  test('lib/redditor/properties', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_properties.json');
    final redditor = await reddit.redditor('DRAWApiOfficial').populate();
    expect(redditor.commentKarma, 0);
    expect(redditor.goldCreddits, 0);
    expect(redditor.goldExpiration, isNull);
    expect(redditor.hasGold, isFalse);
    expect(redditor.hasModMail, isFalse);
    expect(redditor.hasVerifiedEmail, isTrue);
    expect(redditor.inBeta, isTrue);
    expect(redditor.inboxCount, 7);
    expect(redditor.isEmployee, isFalse);
    expect(redditor.isModerator, isTrue);
    expect(redditor.isSuspended, isFalse);
    expect(redditor.linkKarma, 1);
    expect(redditor.newModMailExists, isTrue);
    expect(redditor.over18, isTrue);
    expect(redditor.preferNoProfanity, isTrue);
    expect(redditor.suspensionExpirationUtc, isNull);
  });

  test('lib/redditor/friend', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_friend.json');

    final friendToBe = reddit.redditor('XtremeCheese');
    await friendToBe.friend(note: 'My best friend!');

    final myFriends = await reddit.user.friends();
    expect(myFriends.length, equals(1));
    final friend = myFriends[0];
    expect(friend is Redditor, isTrue);

    expect(friend.displayName, equals('XtremeCheese'));
    expect(friend.note, equals('My best friend!'));

    await friendToBe.unfriend();
    final noFriends = await reddit.user.friends();
    expect(noFriends.length, equals(0));
  });

  test('lib/redditor/unblock', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_unblock.json');

    var blockedUsers = await reddit.user.blocked();
    expect(blockedUsers.length, equals(1));

    // User was blocked before running this test.
    final blocked = reddit.redditor('XtremeCheese');
    await blocked.unblock();

    blockedUsers = await reddit.user.blocked();
    expect(blockedUsers.length, equals(0));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/controversial', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_controversial.json');

    final other = reddit.redditor('spez');
    final posts = [];
    await for (final post in other.controversial(params: {'limit': '2'})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.domain, equals('self.announcements'));
    expect(await submission.id, equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.id, equals('dkz2h82'));
    expect(await comment.parentId, equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/hot', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_hot.json');

    final other = reddit.redditor('spez');
    final posts = [];
    await for (final post in other.hot(params: {'limit': '2'})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.domain, equals('self.announcements'));
    expect(await submission.id, equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.id, equals('dkz2h82'));
    expect(await comment.parentId, equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/newest', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_new.json');

    final other = reddit.redditor('spez');
    final posts = [];
    await for (final post in other.newest(params: {'limit': '2'})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.domain, equals('self.announcements'));
    expect(await submission.id, equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.id, equals('dkz2h82'));
    expect(await comment.parentId, equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/top', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_top.json');

    final other = reddit.redditor('spez');
    final posts = [];
    await for (final post in other.top(params: {'limit': '2'})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.domain, equals('self.announcements'));
    expect(await submission.id, equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.id, equals('dkz2h82'));
    expect(await comment.parentId, equals('t1_dkz1y5k'));
  });

  test('lib/redditor/gild', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_reddit_gild.json');
    final other = await reddit.redditor('XtremeCheese').populate();
    await other.gild();
  });

  test('lib/redditor/gild_insufficient_creddits', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_reddit_gild_insufficient.json');
    final current = await reddit.user.me();
    expect(current.goldCreddits, 0);

    final other = await reddit.redditor('XtremeCheese').populate();
    try {
      await other.gild();
    } on DRAWGildingException catch (e) {
      // Success
    } catch (e) {
      rethrow;
    }
  });

  test('lib/redditor/multireddits', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_multireddits.json');
    final current = await reddit.user.me();
    final multis = await current.multireddits();
    expect(multis.length, 7);
    expect(multis[0].displayName, 'all');
    expect(multis[0].subreddits.length, 0);
  });

  test('lib/redditor/downvoted', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_reddit_downvoted.json');

    final other = reddit.redditor('DRAWApiOfficial');
    final content = [];
    await for (final downvoted in other.downvoted(params: {'limit': '10'})) {
      content.add(downvoted);
    }

    expect(content.length, equals(1));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].domain, equals('self.announcements'));
    expect(
        await content[0].title,
        equals('With so much going on in'
            ' the world, I thought I’d share some Reddit updates to distract '
            'you all'));
    expect(await content[0].author, equals('spez'));
  });

  test('lib/redditor/hidden', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_reddit_hidden.json');

    final other = reddit.redditor('DRAWApiOfficial');
    final content = [];
    await for (final hidden in other.hidden(params: {'limit': '10'})) {
      content.add(hidden);
    }

    expect(content.length, equals(1));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].domain, equals('self.announcements'));
    expect(await content[0].title, equals('Reddit\'s new signup experience'));
    expect(await content[0].author, equals('simbawulf'));
  });

  test('lib/redditor/upvoted', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_reddit_upvoted.json');

    final other = reddit.redditor('DRAWApiOfficial');
    final content = [];
    await for (final upvoted in other.upvoted(params: {'limit': '10'})) {
      content.add(upvoted);
    }

    expect(content.length, equals(2));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].domain, equals('github.com'));
    expect(await content[0].title, equals('Official DRAW GitHub'));
    expect(await content[0].author, equals('DRAWApiOfficial'));
    expect(content[1] is Submission, isTrue);
    expect(await content[1].domain, equals('self.drawapitesting'));
    expect(
        await content[1].title,
        equals('test post please'
            ' ignore.'));
    expect(await content[1].author, equals('DRAWApiOfficial'));
  });

  test('lib/redditor/comments_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_comments.json');
    final redditor = reddit.redditor('DRAWApiOfficial');
    final content = <Comment>[];
    await for (final comment in redditor.comments.top(params: {'limit': '2'})) {
      expect(comment is Comment, isTrue);
      content.add(comment);
    }

    expect(content.length, 2);
    expect(content[0].body, 'And this is a test comment!\n');
    expect(content[1].body, 'Woohoo!');
  });

  test('lib/redditor/submissions_sanity', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_submissions.json');
    final redditor = reddit.redditor('DRAWApiOfficial');
    final content = <Submission>[];
    await for (final submission
        in redditor.submissions.newest(params: {'limit': '2'})) {
      expect(submission is Submission, isTrue);
      content.add(submission);
    }

    expect(content.length, 2);
    expect(content[0].title,
        'DRAW: Using Dart to Moderate Reddit Comments (DartConf 2018)');
    expect(content[1].title, 'Tons of comments');
  });

  test('lib/redditor/saved_listing', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_saved.json');
    final redditor = reddit.redditor('DRAWApiOfficial');
    final content = <UserContent>[];
    await for (final post in redditor.saved(params: {'limit': '2'})) {
      content.add(post);
    }

    expect(content.length, 2);
    expect(content[0] is Comment, isTrue);
    expect((content[0] as Comment).body, "He gon' steal yo girl");
    expect(content[1] is Submission, isTrue);
    expect((content[1] as Submission).title, '😉');
  });

  test('lib/redditor/gildings', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_gildings.json');
    final redditor = reddit.redditor('DRAWApiOfficial');
    final content = <UserContent>[];
    await for (final post in redditor.gildings(params: {'limit': '2'})) {
      content.add(post);
    }

    expect(content.length, 1);
    expect(content[0] is Submission, isTrue);
    expect((content[0] as Submission).title, "Gilded post!");
    expect((content[0] as Submission).gilded, 1);
  });
}
