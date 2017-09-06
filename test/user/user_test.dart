// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/user/me', () async {
    final reddit = await createRedditTestInstance('test/user/lib_user_me.json');
    final Redditor me = await reddit.user.me();
    expect(await me.property('name'), equals('DRAWApiOfficial'));
    expect(await me.property('isEmployee'), isFalse);
    expect(await me.property('prefNoProfanity'), isTrue);
    expect(await me.property('isSuspended'), isFalse);
    expect(await me.property('commentKarma'), equals(0));
    expect(await me.property('linkKarma'), equals(1));
    expect(await me.property('goldCreddits'), equals(0));
    expect(await me.property('created'), equals(1501830779.0));
  });

  test('lib/user/blocked', () async {
    // TODO(bkonyi): Actually block some users and update this test.
    /*
    final reddit = await createRedditTestInstance(
        'test/user/lib_user_blocked.json');
    final List<Redditor> blocked = await reddit.user.blocked();
    expect(blocked.length, equals(0));
    */
  });

  test('lib/user/contributorSubreddits', () async {
    final reddit = await createRedditTestInstance(
        'test/user/lib_user_contributorSubreddits.json');
    final subreddits = <Subreddit>[];
    await for (final subreddit
        in reddit.user.contributorSubreddits(limit: 101)) {
      subreddits.add(subreddit);
    }
    expect(subreddits.length, equals(1));
    final subreddit = subreddits[0];
    expect(await subreddit.property('displayName'), equals("drawapitesting"));
    expect(await subreddit.property('userIsContributor'), isTrue);
    expect(await subreddit.property('userIsBanned'), isFalse);
  });

  test('lib/user/friends', () async {
    final reddit =
        await createRedditTestInstance('test/user/lib_user_friends.json');
    final List<Redditor> friends = await reddit.user.friends();
    expect(friends.length, equals(1));
    final friend = friends[0];
    expect(await await friend.property('name'), equals('XtremeCheese'));
    expect(await await friend.property('date'), equals(1501884713.0));
  });

  test('lib/user/karma', () async {
    // TODO(bkonyi): Actually get some karma and update this test.
    /*final reddit = await createRedditTestInstance(
        'test/user/lib_user_karma.json', live: true);
    final Map<Subreddit, Map<String, int>> karma = await reddit.user.karma();*/
  });

  test('lib/user/moderatorSubreddits', () async {
    final reddit = await createRedditTestInstance(
        'test/user/lib_user_moderatorSubreddits.json');
    final subreddits = <Subreddit>[];
    await for (final subreddit in reddit.user.moderatorSubreddits()) {
      subreddits.add(subreddit);
    }
    expect(subreddits.length, equals(1));
    final subreddit = subreddits[0];
    expect(await subreddit.property('displayName'), equals('drawapitesting'));
    expect(await subreddit.property('userIsContributor'), isTrue);
    expect(await subreddit.property('userIsBanned'), isFalse);
    expect(await subreddit.property('title'), equals('DRAW API Testing'));
    expect(await subreddit.property('public_description'),
        contains('A subreddit used for testing'));
  });

  test('lib/user/multireddits', () async {
    final reddit =
        await createRedditTestInstance('test/user/lib_user_multireddits.json');
    final multis = await reddit.user.multireddits();
    expect(multis.length, equals(1));
    final multi = multis[0];
    expect(await multi.property('name'), equals('drawtestingmulti'));
    expect(await multi.property('displayName'), equals('drawtestingmulti'));
    expect(await multi.property('canEdit'), isTrue);
    expect((await multi.property('subreddits')).length, equals(81));
    // TODO(bkonyi): once Multireddit is fully implemented, we probably want to
    // return a map of [Subreddit]s.
    expect((await multi.property('subreddits'))[0]['name'], equals('lisp'));
  });

  test('lib/user/subreddits', () async {
    final reddit =
        await createRedditTestInstance('test/user/lib_user_subreddits.json');
    final subs = <Subreddit>[];
    await for (final subreddit in reddit.user.subreddits(limit: 101)) {
      subs.add(subreddit);
    }
    expect(subs.length, equals(3));
    // Note that there's only three subreddits returned here. These subreddits
    // were subscribed to explicitly (r/announcements is a default, so it was
    // unsubscribed from and resubscribed to) in order to be returned. In other
    // words, default subreddits that the user is subscribed to will NOT be
    // returned from this method unless resubscribed to.
    expect(await subs[0].property('displayName'), equals('announcements'));
    expect(await subs[1].property('displayName'), equals('dartlang'));
    expect(await subs[2].property('displayName'), equals('drawapitesting'));
  });
}
