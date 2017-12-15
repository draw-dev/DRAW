// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/subreddit/banned', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_banned.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    await for (final user in subreddit.banned()) {
      expect(true, isFalse);
    }
    await subreddit.banned.add('spez');
    expect(await (await subreddit.banned().first).property('name'),
        equals('spez'));
    await subreddit.banned.remove('spez');
    await for (final user in subreddit.banned()) {
      expect(true, isFalse);
    }
  });

  test('lib/subreddit/contributor', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_contributor.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    await subreddit.contributor.add('spez');
    expect(await (await subreddit.contributor().first).property('name'),
        equals('spez'));
    await subreddit.contributor.remove('spez');
    await for (final user in subreddit.contributor()) {
      expect(await user.property('name') == 'spez', isFalse);
    }
  });

  test('lib/subreddit/random', () async {
    const randomTitle = 'A sentry slacking on the job';
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_random.json');

    final subreddit = new Subreddit.name(reddit, 'tf2');
    final submission = await subreddit.random();
    expect(await submission.property('title'), equals(randomTitle));
  });

  test('lib/subreddit/rules', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_rules.json');

    final subreddit = new Subreddit.name(reddit, 'whatcouldgowrong');
    final rules = await subreddit.rules();
    expect(rules.length, equals(5));

    final ruleOne = rules[0];
    expect(ruleOne.isLink, isTrue);
    expect(ruleOne.description, '');
    expect(
        ruleOne.shortName,
        equals('Contains stupid idea and thing going'
            ' wrong'));
    expect(
        ruleOne.violationReason,
        equals('No stupid idea or Nothing went'
            ' wrong'));
    expect(ruleOne.createdUtc, equals(1487830366.0));
    expect(ruleOne.priority, equals(0));
  });

  test('lib/subreddit/submission', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_submission.json');

    final subreddit = new Subreddit.name(reddit, 'politics');
    // Perform a search for content on /r/politics the day of the 2016
    // presidential elections. PRAW returns 753 results for this query, so we
    // expect to return the same.
    int count = 0;
    await for (final post in subreddit.submissions(
        start: new DateTime.utc(2016, 11, 8, 8, 0), // These dates are 12AM PST.
        end: new DateTime.utc(2016, 11, 9, 8, 0))) {
      ++count;
    }
    expect(count, equals(753));
  });

  test('lib/subreddit/sticky', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_sticky.json');

    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    final stickied = await subreddit.sticky();
    expect(await stickied.property('title'), equals('Official DRAW GitHub'));
  });

  test('lib/subreddit/submit', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_submit.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    final originalSubmission = await subreddit.newest().first;
    expect((await originalSubmission.property('title') == 'Testing3939057249'),
        isFalse);
    await subreddit.submit('Testing3939057249', selftext: 'Hello Reddit!');
    final submission = await subreddit.newest().first;
    expect(await submission.property('title'), equals('Testing3939057249'));
    expect(await submission.property('selftext'), equals('Hello Reddit!'));
  });

  test('lib/subreddit/subscribe_and_unsubscribe', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_subscribe_and_unsubscribe.json');

    final subreddit = new Subreddit.name(reddit, 'funny');
    await for (final subscription in reddit.user.subreddits()) {
      expect(await subscription.property('displayName') == 'funny', isFalse);
      expect(await subscription.property('displayName') == 'WTF', isFalse);
    }

    await subreddit
        .subscribe(otherSubreddits: [new Subreddit.name(reddit, 'WTF')]);

    // When running this live, Reddit seems to subscribe to the
    // 'otherSubreddits' slightly after the single subreddit is being subscribed
    // to. A short delay is enough to ensure Reddit finishes processing.
    // await new Future.delayed(const Duration(seconds: 1));

    bool hasFunny = false;
    bool hasWTF = false;
    await for (final subscription in reddit.user.subreddits()) {
      if (await subscription.property('displayName') == 'WTF') {
        hasWTF = true;
      } else if (await subscription.property('displayName') == 'funny') {
        hasFunny = true;
      }
    }

    expect(hasFunny && hasWTF, isTrue);

    await subreddit
        .unsubscribe(otherSubreddits: [new Subreddit.name(reddit, 'WTF')]);

    // When running this live, Reddit seems to unsubscribe to the
    // 'otherSubreddits' slightly after the single subreddit is being
    // unsubscribed from.  A short delay is enough to ensure Reddit finishes
    // processing.
    // await new Future.delayed(const Duration(seconds: 1));

    await for (final subscription in reddit.user.subreddits()) {
      expect(await subscription.property('displayName') == 'funny', isFalse);
      expect(await subscription.property('displayName') == 'WTF', isFalse);
    }
  });

  test('lib/subreddit/traffic', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_traffic.json');
    final subreddit = new Subreddit.name(reddit, 'drawapitesting');
    final traffic = await subreddit.traffic();
    expect(traffic is Map<String, List<SubredditTraffic>>, isTrue);
    expect(traffic.containsKey('day'), isTrue);
    expect(traffic.containsKey('hour'), isTrue);
    expect(traffic.containsKey('month'), isTrue);
    final october = traffic['month'][0];
    expect(october.uniques, equals(3));
    expect(october.pageviews, equals(17));
    expect(october.subscriptions, equals(0));
    expect(october.periodStart, equals(new DateTime.utc(2017, 10)));
  });
}
