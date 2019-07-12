// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/subreddits/default', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_default.json');
    final stream = reddit.subreddits.defaults(limit: 5);
    final result = await stream.toList();
    expect(result.length, 5);
  });

  test('lib/subreddits/gold', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_gold.json');
    final stream = reddit.subreddits.gold(limit: 5);
    final result = await stream.toList();
    // Requires Reddit gold to get results.
    expect(result.length, 0);
  });

  test('lib/subreddits/newest', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_newest.json');
    final stream = reddit.subreddits.newest(limit: 5);
    final result = await stream.toList();
    expect(result.length, 5);
  });

  test('lib/subreddits/popular', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_popular.json');
    final stream = reddit.subreddits.popular(limit: 5);
    final result = await stream.toList();
    expect(result.length, 5);
  });

  test('lib/subreddits/recommended', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_recommended.json');

    final results = await reddit.subreddits.recommended(
        ['politics', SubredditRef.name(reddit, 'MorbidReality')],
        omitSubreddits: ['hillaryclinton']);
    expect(results.length, 10);

    // ignore: unawaited_futures
    expectLater(reddit.subreddits.recommended(null),
        throwsA(TypeMatcher<DRAWArgumentError>()));

    // ignore: unawaited_futures
    expectLater(reddit.subreddits.recommended([2]),
        throwsA(TypeMatcher<DRAWArgumentError>()));
  });

  test('lib/subreddits/search', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_search.json');
    final results = await reddit.subreddits.search('drawapitesting').toList();
    expect(results.length, 1);

    bool threw = false;
    try {
      reddit.subreddits.search(null);
      // ignore: unused_catch_clause
    } on DRAWArgumentError catch (e) {
      threw = true;
    } finally {
      expect(threw, isTrue);
    }
  });

  test('lib/subreddits/search_by_name', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_search_by_name.json');
    final names = (await reddit.subreddits.searchByName('Morbid'))
        .map((s) => s.displayName);
    final pattern = RegExp(r'[Mm]orbid');
    for (final name in names) {
      expect(name.startsWith(pattern), isTrue);
    }

    final sfw =
        (await reddit.subreddits.searchByName('Morbid', includeNsfw: false));

    for (final s in sfw) {
      final populated = await s.populate();
      expect(populated.over18, isFalse);
    }

    // ignore: unawaited_futures
    expectLater(reddit.subreddits.searchByName(null),
        throwsA(TypeMatcher<DRAWArgumentError>()));
  });

  test('lib/subreddits/stream', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddits_stream.json');
    final result = await reddit.subreddits.stream(limit: 1).toList();
    expect(result.length, 1);
  });
}
