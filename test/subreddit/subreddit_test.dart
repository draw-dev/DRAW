// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

// ignore_for_file: unused_local_variable

Future<void> main() async {
  test('lib/subreddit/banned', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_banned.json');
    final subreddit = reddit.subreddit('drawapitesting');
    await for (final user in subreddit.banned()) {
      fail('Expected no returned values, got: $user');
    }
    await subreddit.banned.add('spez');
    expect((await subreddit.banned().first).displayName, equals('spez'));
    await subreddit.banned.remove('spez');
    await for (final user in subreddit.banned()) {
      fail('Expected no returned values, got: $user');
    }
  });

  test('lib/subreddit/comment_stream', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_comments_stream.json');
    int count = 0;
    await for (final comment
        in reddit.subreddit('drawapitesting').stream.comments(limit: 10)) {
      expect(comment is CommentRef, isTrue);
      count++;
    }
    expect(count, 10);
  });

  test('lib/subreddit/contributor', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_contributor.json');
    final subreddit = reddit.subreddit('drawapitesting');
    await subreddit.contributor.add('spez');
    expect((await subreddit.contributor().first).displayName, equals('spez'));
    await subreddit.contributor.remove('spez');
    await for (final user in subreddit.contributor()) {
      expect(user.displayName == 'spez', isFalse);
    }
  });

  test('lib/subreddit/filter', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_filter.json');
    final all = reddit.subreddit('all');
    await all.filters.add('the_donald');

    await for (final sub in all.filters()) {
      expect(sub is SubredditRef, isTrue);
      expect(sub.displayName.toLowerCase(), 'the_donald');
    }

    await all.filters.remove('the_donald');
    await for (final sub in all.filters()) {
      fail('There should be no subreddits being filtered, but $sub still is');
    }
  });

  // Note: this test data is sanitized since it's garbage and I don't want that
  // in my repo.
  test('lib/subreddit/quarantine', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_quarantine.json');
    final garbage = reddit.subreddit('whiteswinfights');

    // Risky subreddit that's quarantined. In we go...
    await garbage.quarantine.optIn();
    try {
      await for (final Submission submission in garbage.top()) {
        break;
      }
    } catch (e) {
      fail('Got exception when we expected a submission. Exception: $e');
    }

    // Let's opt back out of seeing this subreddit...
    await garbage.quarantine.optOut();
    try {
      await for (final Submission submission in garbage.top()) {
        fail('Expected DRAWAuthenticationError but got a submission');
      }
    } on DRAWAuthenticationError catch (e) {
      // Phew, no more trash!
      e.hashCode; // To get the analyzer to be quiet; does nothing.
    } catch (e) {
      fail('Expected DRAWAuthenticationError, got $e');
    }
  });

  test('lib/subreddit/random', () async {
    const randomTitle = 'A sentry slacking on the job';
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_random.json');

    final subreddit = reddit.subreddit('tf2');
    final submission = await (await subreddit.random()).populate();
    expect(submission.title, equals(randomTitle));
  });

  test('lib/subreddit/rules', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_rules.json');

    final subreddit = reddit.subreddit('whatcouldgowrong');
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

  test('lib/subreddit/sticky', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_sticky.json');

    final subreddit = reddit.subreddit('drawapitesting');
    final stickied = await (await subreddit.sticky()).populate();
    expect(stickied.title, equals('Official DRAW GitHub'));
  });

  test('lib/subreddit/submit', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_submit.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final originalSubmission = await subreddit.newest().first as Submission;
    expect((originalSubmission.title == 'Testing3939057249'), isFalse);
    await subreddit.submit('Testing3939057249', selftext: 'Hello Reddit!');
    final submission = await subreddit.newest().first as Submission;
    expect(submission.title, equals('Testing3939057249'));
    expect(submission.selftext, equals('Hello Reddit!'));
  });

  test('lib/subreddit/subscribe_and_unsubscribe', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_subscribe_and_unsubscribe.json');

    final subreddit = reddit.subreddit('funny');
    await for (final subscription in reddit.user.subreddits()) {
      expect(subscription.displayName == 'funny', isFalse);
      expect(subscription.displayName == 'WTF', isFalse);
    }

    await subreddit
        .subscribe(otherSubreddits: <SubredditRef>[reddit.subreddit('WTF')]);

    // When running this live, Reddit seems to subscribe to the
    // 'otherSubreddits' slightly after the single subreddit is being subscribed
    // to. A short delay is enough to ensure Reddit finishes processing.
    // await new Future.delayed(const Duration(seconds: 1));

    bool hasFunny = false;
    bool hasWTF = false;
    await for (final subscription in reddit.user.subreddits()) {
      if (subscription.displayName == 'WTF') {
        hasWTF = true;
      } else if (subscription.displayName == 'funny') {
        hasFunny = true;
      }
    }

    expect(hasFunny && hasWTF, isTrue);

    await subreddit.unsubscribe(otherSubreddits: [reddit.subreddit('WTF')]);

    // When running this live, Reddit seems to unsubscribe to the
    // 'otherSubreddits' slightly after the single subreddit is being
    // unsubscribed from.  A short delay is enough to ensure Reddit finishes
    // processing.
    // await new Future.delayed(const Duration(seconds: 1));

    await for (final subscription in reddit.user.subreddits()) {
      expect(subscription.displayName == 'funny', isFalse);
      expect(subscription.displayName == 'WTF', isFalse);
    }
  });

  test('lib/subreddit/traffic', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_traffic.json');
    final subreddit = reddit.subreddit('drawapitesting');
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

  test('lib/subreddit_flair/call', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_call.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final subredditFlair = subreddit.flair;
    final flair = await subredditFlair().first;
    expect(flair.user.displayName, 'DRAWApiOfficial');
    expect(flair.flairCssClass, '');
    expect(flair.flairText, 'Test Flair');
  });

  // TODO(bkonyi): Check that changes are sticking.
  test('lib/subreddit_flair/configure', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_configure.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final subredditFlair = subreddit.flair;
    await subredditFlair.configure(
        linkPosition: FlairPosition.left,
        position: FlairPosition.right,
        linkSelfAssign: true,
        selfAssign: true);
    await subredditFlair.configure();
  });

  test('lib/subreddit_flair/setFlair', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_set_flair.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final subredditFlair = subreddit.flair;
    final flairs = <Flair>[];
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 1);
    await subredditFlair.setFlair('XtremeCheese', text: 'Test flair 2');
    flairs.clear();
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 2);
  });

  test('lib/subreddit_flair/deleteAll', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_delete_all.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final subredditFlair = subreddit.flair;
    final flairs = <Flair>[];
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 1);
    await subredditFlair.deleteAll();

    flairs.clear();
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 0);
  });

  test('lib/subreddit_flair/delete', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_delete.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final subredditFlair = subreddit.flair;
    final flairs = <Flair>[];
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 1);
    await subredditFlair.delete('DRAWApiOfficial');

    flairs.clear();
    await for (final f in subredditFlair()) {
      flairs.add(f);
    }
    expect(flairs.length, 0);
  });

  test('lib/subreddit_flair/update', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_update.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final subredditFlair = subreddit.flair;

    final users = <String>['DRAWApiOfficial', 'XtremeCheese'];
    await subredditFlair.update(users, text: 'Flair Test');

    int count = 0;
    await for (final f in subredditFlair()) {
      expect(f.flairText, 'Flair Test');
      ++count;
    }
    expect(count, 2);

    final redditors =
        users.map<RedditorRef>((String user) => reddit.redditor(user)).toList();
    await subredditFlair.update(redditors);
    count = 0;
    await for (final f in subredditFlair()) {
      ++count;
    }
    expect(count, 0);
  });

  test('lib/subreddit_flair/redditor_templates', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_redditor_templates.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final template = subreddit.flair.templates;
    await template.add('Foobazbar', textEditable: true);
    await template.add('Foobarz');
    final list = <FlairTemplate>[];
    await for (final t in template()) {
      list.add(t);
    }
    expect(list.length, 2);
    await template.delete(list[0].flairTemplateId);
    list.clear();
    await for (final t in template()) {
      list.add(t);
    }
    expect(list.length, 1);
    await template.update(list[0].flairTemplateId, 'Foo');
    await template.clear();
    await for (final t in template()) {
      fail('Should not be any flair templates left');
    }
  });

  test('lib/subreddit_flair/link_templates', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_flair_link_templates.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final linkTemplate = subreddit.flair.linkTemplates;
    await linkTemplate.add('Foobazbar', textEditable: true);
    await linkTemplate.add('Foobarz');
    final list = <FlairTemplate>[];
    await for (final t in linkTemplate()) {
      list.add(t);
    }
    expect(list.length, 2);
    await linkTemplate.delete(list[0].flairTemplateId);
    list.clear();
    await for (final t in linkTemplate()) {
      list.add(t);
    }
    expect(list.length, 1);
    await linkTemplate.update(list[0].flairTemplateId, 'Foo');
    await linkTemplate.clear();
    await for (final t in linkTemplate()) {
      fail('Should not be any link flair templates left');
    }
  });

  test('lib/subreddit_wiki/create_wiki_page', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_create_wiki_page.json',
        live: true);
    final wiki = reddit.subreddit('drawapitesting').wiki;
    //final page = await wiki.create('Test page', 'This is a test page!');
    final page =
        WikiPage(reddit, reddit.subreddit('drawapitesting'), 'Test page');
    await page.fetch();
    print(page);
    //await page.edit('Test edit');
    final revisions = await wiki.revisions().toList();
    print(revisions.length);
    revisions.forEach((e) => print(e.timestamp));
  });
}
