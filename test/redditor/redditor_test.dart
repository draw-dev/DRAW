// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/redditor/friend', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_friend.json');

    final friendToBe = new Redditor.name(reddit, 'XtremeCheese');
    await friendToBe.friend(note: 'My best friend!');

    final myFriends = await reddit.user.friends();
    expect(myFriends.length, equals(1));
    final friend = myFriends[0];

    expect(await friend.property('name'), equals('XtremeCheese'));
    expect(await friend.property('note'), equals('My best friend!'));

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
    final blocked = new Redditor.name(reddit, 'XtremeCheese');
    await blocked.unblock();

    blockedUsers = await reddit.user.blocked();
    expect(blockedUsers.length, equals(0));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/controversial', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_redditor_controversial.json');

    final other = new Redditor.name(reddit, 'spez');
    final posts = [];
    await for (final post in other.controversial(params: {'limit': 2})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.property('domain'), equals('self.announcements'));
    expect(await submission.property('id'), equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.property('id'), equals('dkz2h82'));
    expect(await comment.property('parentId'), equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/hot', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_hot.json');

    final other = new Redditor.name(reddit, 'spez');
    final posts = [];
    await for (final post in other.hot(params: {'limit': 2})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.property('domain'), equals('self.announcements'));
    expect(await submission.property('id'), equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.property('id'), equals('dkz2h82'));
    expect(await comment.property('parentId'), equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/newest', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_new.json');

    final other = new Redditor.name(reddit, 'spez');
    final posts = [];
    await for (final post in other.newest(params: {'limit': 2})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.property('domain'), equals('self.announcements'));
    expect(await submission.property('id'), equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.property('id'), equals('dkz2h82'));
    expect(await comment.property('parentId'), equals('t1_dkz1y5k'));
  });

  // Note: tests for controversial, hot, newest, and top all use the same
  // data for the different responses to save some effort.
  test('lib/redditor/top', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_redditor_top.json');

    final other = new Redditor.name(reddit, 'spez');
    final posts = [];
    await for (final post in other.top(params: {'limit': 2})) {
      expect(post is UserContent, isTrue);
      posts.add(post);
    }

    final submission = posts[0];
    final comment = posts[1];
    expect(submission is Submission, isTrue);
    expect(await submission.property('domain'), equals('self.announcements'));
    expect(await submission.property('id'), equals('6qptzw'));
    expect(comment is Comment, isTrue);
    expect(await comment.property('id'), equals('dkz2h82'));
    expect(await comment.property('parentId'), equals('t1_dkz1y5k'));
  });

  // TODO(bkonyi): Actually get gilded.
  test('lib/redditor/gilded', () async {
    /*final reddit = await createRedditTestInstance(
        'test/redditor/lib_reddit_gilded.json',
        live: true);
    final other = new Redditor.name(reddit, 'DRAWApiOfficial');
    await for (final gilded in other.gilded()) {
      print(gilded);
      print('');
    }*/
  });

  // TODO(bkonyi): Actually gild someone.
  test('lib/redditor/gildings', () async {
    /*final reddit = await createRedditTestInstance(
        'test/redditor/lib_reddit_gildings.json',
        live: true);
    final other = new Redditor.name(reddit, 'DRAWApiOfficial');
    await for (final gild in other.gildings()) {
      print(gilded);
      print('');
    }*/
  });

  test('lib/redditor/downvoted', () async {
    final reddit = await createRedditTestInstance(
        'test/redditor/lib_reddit_downvoted.json');

    final other = new Redditor.name(reddit, 'DRAWApiOfficial');
    final content = [];
    await for (final downvoted in other.downvoted(params: {'limit': 10})) {
      content.add(downvoted);
    }

    expect(content.length, equals(1));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].property('domain'), equals('self.announcements'));
    expect(
        await content[0].property('title'),
        equals('With so much going on in'
            ' the world, I thought I’d share some Reddit updates to distract '
            'you all'));
    expect(await content[0].property('author'), equals('spez'));
  });

  test('lib/redditor/hidden', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_reddit_hidden.json');

    final other = new Redditor.name(reddit, 'DRAWApiOfficial');
    final content = [];
    await for (final hidden in other.hidden(params: {'limit': 10})) {
      content.add(hidden);
    }

    expect(content.length, equals(1));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].property('domain'), equals('self.announcements'));
    expect(await content[0].property('title'),
        equals('Reddit\'s new signup experience'));
    expect(await content[0].property('author'), equals('simbawulf'));
  });

  test('lib/redditor/upvoted', () async {
    final reddit =
        await createRedditTestInstance('test/redditor/lib_reddit_upvoted.json');

    final other = new Redditor.name(reddit, 'DRAWApiOfficial');
    final content = [];
    await for (final upvoted in other.upvoted(params: {'limit': 10})) {
      content.add(upvoted);
    }

    expect(content.length, equals(2));
    expect(content[0] is Submission, isTrue);
    expect(await content[0].property('domain'), equals('github.com'));
    expect(await content[0].property('title'), equals('Official DRAW GitHub'));
    expect(await content[0].property('author'), equals('DRAWApiOfficial'));
    expect(content[1] is Submission, isTrue);
    expect(await content[1].property('domain'), equals('self.drawapitesting'));
    expect(
        await content[1].property('title'),
        equals('test post please'
            ' ignore.'));
    expect(await content[1].property('author'), equals('DRAWApiOfficial'));
  });
}
