// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

// ignore_for_file: unused_local_variable

Future<void> main() async {
  test('lib/subreddit/invalid', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_invalid.json');
    await expectLater(
        () async => await reddit.subreddit('drawapitesting2').populate(),
        throwsA(TypeMatcher<DRAWInvalidSubredditException>()));
  });

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
    expect(october.periodStart, equals(DateTime.utc(2017, 10)));
  });

  test('lib/subreddit_stylesheet/call', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_call.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final stylesheetHelper = subreddit.stylesheet;
    final stylesheet = await stylesheetHelper();
    expect(stylesheet, TypeMatcher<StyleSheet>());
    expect(stylesheet.stylesheet,
        '.flair-redandblue { color: blue; background: red; }');
    expect(stylesheet.toString(), stylesheet.stylesheet);
    expect(stylesheet.images?.length, 1);

    final dartLogo = stylesheet.images.first;
    expect(
        dartLogo.url,
        Uri.parse(
            'https://a.thumbs.redditmedia.com/firXjrOhN2odPDDkXWwvtIM1BttrTiZbPobp0MqO6b4.png'));
    expect(dartLogo.link, 'url(%%dart-logo-400x400%%)');
    expect(dartLogo.name, 'dart-logo-400x400');
    expect(dartLogo.toString(), dartLogo.name);
  });

  test('lib/subreddit_stylesheet/delete_header', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_delete_header.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    expect(
        subreddit.headerImage,
        Uri.parse(
            'https://b.thumbs.redditmedia.com/cXqC_cP8q0_exlq0HyaeW607ZIEU0o7yOSHnLnPUv-k.png'));
    final stylesheet = subreddit.stylesheet;
    await stylesheet.deleteHeader();
    await subreddit.refresh();
    expect(subreddit.headerImage, null);
  });

  test('lib/subreddit_stylesheet/delete_image', () async {
    const kImageName = 'dart-logo-400x400';
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_delete_image.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final stylesheet = subreddit.stylesheet;
    var images = (await stylesheet()).images;
    expect(images.length, 1);
    expect(images.first.name, kImageName);
    await stylesheet.deleteImage(kImageName);

    images = (await stylesheet()).images;
    expect(images.length, 0);
  });

  test('lib/subreddit_stylesheet/delete_mobile_header', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_delete_mobile_header.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    expect(
        subreddit.mobileHeaderImage,
        Uri.parse(
            'https://b.thumbs.redditmedia.com/cXqC_cP8q0_exlq0HyaeW607ZIEU0o7yOSHnLnPUv-k.png'));
    final stylesheet = subreddit.stylesheet;
    await stylesheet.deleteMobileHeader();
    await subreddit.refresh();
    expect(subreddit.mobileHeaderImage, null);
  });

  test('lib/subreddit_stylesheet/delete_mobile_icon', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_delete_mobile_icon.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final stylesheet = subreddit.stylesheet;
    expect(
        subreddit.iconImage,
        Uri.parse(
            'https://a.thumbs.redditmedia.com/4N-5XL7FZ6sA0WS7UpbdS1OSw9sGYHmNiIQ8SlFJ8b0.png'));
    await stylesheet.deleteMobileIcon();
    await subreddit.refresh();
    expect(subreddit.iconImage, null);
  });

  test('lib/subreddit_stylesheet/update', () async {
    const kNewStyle = '.flair-blueandred { color: red; background: blue; }';
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_update.json');
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final stylesheetHelper = subreddit.stylesheet;
    var stylesheet = await stylesheetHelper();
    expect(stylesheet.stylesheet,
        '.flair-redandblue { color: blue; background: red; }');
    await stylesheetHelper.update(kNewStyle, reason: 'Test');
    stylesheet = await stylesheetHelper();
    expect(stylesheet.stylesheet, kNewStyle);
  });

  test('lib/subreddit_stylesheet/upload', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;
    final uri = await stylesheet.upload('foobar',
        imagePath: Uri.file('test/images/dart_header.png'));
    expect(uri.toString(),
        'https://a.thumbs.redditmedia.com/MJGdqUs7bXLgG7-pYG5zVRdI_6qUQ6svvlZXURe5K98.png');
  });

  test('lib/subreddit_stylesheet/upload_bytes', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload_bytes.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;
    final imageBytes =
        await File.fromUri(Uri.file('test/images/dart_header.png'))
            .readAsBytes();
    final uri = await stylesheet.upload('foobar',
        bytes: imageBytes, format: ImageFormat.png);
    expect(uri.toString(),
        'https://a.thumbs.redditmedia.com/MJGdqUs7bXLgG7-pYG5zVRdI_6qUQ6svvlZXURe5K98.png');
  });

  test('lib/subreddit_stylesheet/upload_invalid_cases', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload_invalid_cases.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;

    // Missing args.
    await expectLater(() async => await stylesheet.upload('foobar'),
        throwsA(TypeMatcher<DRAWArgumentError>()));

    // Bad format.
    await expectLater(
        () async => await stylesheet.upload('foobar',
            imagePath: Uri.file('test/test_utils.dart')),
        throwsA(TypeMatcher<DRAWImageUploadException>()));

    // Too small.
    await expectLater(
        () async => await stylesheet.upload('foobar',
            imagePath: Uri.file('test/images/bad.jpg')),
        throwsA(TypeMatcher<FormatException>()));

    // File doesn't exist.
    await expectLater(
        () async => await stylesheet.upload('foobar',
            imagePath: Uri.file('foobar.bad')),
        throwsA(TypeMatcher<FileSystemException>()));
  });

  test('lib/subreddit_stylesheet/upload_header', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload_header.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;
    final uri = await stylesheet.uploadHeader(
        imagePath: Uri.file('test/images/dart_header.png'));
    expect(uri.toString(),
        'https://a.thumbs.redditmedia.com/MJGdqUs7bXLgG7-pYG5zVRdI_6qUQ6svvlZXURe5K98.png');
  });

  test('lib/subreddit_stylesheet/upload_mobile_header', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload_mobile_header.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;
    final uri = await stylesheet.uploadMobileHeader(
        imagePath: Uri.file('test/images/10by3.jpg'));
    expect(uri.toString(),
        'https://a.thumbs.redditmedia.com/MkErrkhg6-Iou7zdTRxnpwOSNK4DPWXZ3xI35LiKTU0.png');
  });

  test('lib/subreddit_stylesheet/upload_mobile_icon', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_stylesheet_upload_mobile_icon.json');
    final stylesheet = reddit.subreddit('drawapitesting').stylesheet;
    final uri = await stylesheet.uploadMobileIcon(
        imagePath: Uri.file('test/images/256.jpg'));
    expect(uri.toString(),
        'https://b.thumbs.redditmedia.com/GJSQRXiRY-2CH4PTgrrPNXqSPaQSKJYUikUr15m2n3Y.png');
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
        'test/subreddit/lib_subreddit_wiki_create_wiki_page.json');
    final wiki = reddit.subreddit('drawapitesting').wiki;
    final page = await wiki.create('Test wiki page', 'This is a test page!');
    expect(page.name, 'test_wiki_page');
    expect(page.contentMarkdown, 'This is a test page!');
    expect(page.contentHtml.contains('This is a test page!'), true);
    expect(page.mayRevise, true);
    expect(page.revisionBy.displayName, 'DRAWApiOfficial');
    expect(page.revisionDate,
        DateTime.fromMillisecondsSinceEpoch(1540940785 * 1000, isUtc: true));
  });

  test('lib/subreddit_wiki/invalid_wiki_page', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_invalid_wiki_page.json');
    final wiki = reddit.subreddit('drawapitesting').wiki;
    await expectLater(() async => await wiki['invalid'].populate(),
        throwsA(TypeMatcher<DRAWNotFoundException>()));
  });

  test('lib/subreddit_wiki/edit_wiki_page', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_edit_wiki_page.json');
    final wiki = reddit.subreddit('drawapitesting').wiki;
    final page = await wiki['test_wiki_page'].populate();
    expect(page.contentMarkdown, 'This is a test page!');
    expect(page.revisionBy.displayName, 'DRAWApiOfficial');
    expect(page.revisionDate,
        DateTime.fromMillisecondsSinceEpoch(1540895666 * 1000, isUtc: true));
    await page.edit('This is an edited test page!', reason: 'Test edit');
    await page.refresh();
    expect(page.contentMarkdown, 'This is an edited test page!');
    expect(page.revisionBy.displayName, 'DRAWApiOfficial');
    expect(page.revisionDate,
        DateTime.fromMillisecondsSinceEpoch(1540896189 * 1000, isUtc: true));
  });

  test('lib/subreddit_wiki/wiki_equality', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_equality.json');
    final wiki = reddit.subreddit('drawapitesting').wiki;
    final pageRef = wiki['test_wiki_page'];
    final page = await pageRef.populate();
    final pageRef2 = wiki['test_page'];
    final page2 = await pageRef2.populate();
    expect(pageRef == page, true);
    expect(pageRef == pageRef2, false);
    expect(page == page2, false);
    expect(page == pageRef2, false);
  });

  test('lib/subreddit_wiki/wiki_revisions', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_revisions.json');
    final wiki = reddit.subreddit('drawapitesting').wiki;
    final revisions = await wiki.revisions().toList();
    expect(revisions.length, 5);
    for (final r in revisions) {
      expect(r.author.displayName, 'DRAWApiOfficial');
    }
    final last = revisions.last;
    expect(last.page.name, 'test_page');
    expect(last.reason, null);
    expect(last.revision, '1445cccc-dbec-11e8-a780-0ef34ad82884');
    expect(last.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1540895563 * 1000, isUtc: true));
    expect(last == last, true);
    expect(last.toString(), last.data.toString());
    final lastRevisionPage =
        await wiki['test_page'].revision(last.revision).populate();
    expect(lastRevisionPage, last.page);
    expect(lastRevisionPage.revisionDate, last.timestamp);

    await lastRevisionPage.edit('Edited again!', reason: 'testing');
    final newRevisions = await wiki.revisions().toList();
    expect(newRevisions.length, 6);
    final newRevision = newRevisions.first;
    expect(newRevision.reason, 'testing');
    expect(newRevision.revision, '091e41d0-dc5a-11e8-bdfa-0e7c30bc6e32');
    expect(newRevision.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1540942789 * 1000, isUtc: true));
    expect(last == newRevision, false);
    final newRevisionPage =
        await wiki['test_page'].revision(newRevision.revision).populate();
    expect(newRevisionPage.contentMarkdown, 'Edited again!');
  });

  test('lib/subreddit_wiki/wiki_page_revisions', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_page_revisions.json');
    final wikiPage =
        await reddit.subreddit('drawapitesting').wiki['test_page'].populate();
    final initial = await wikiPage.revisions().toList();
    expect(initial.length, 27);
    for (final edit in initial) {
      expect(edit.page, wikiPage);
    }
    expect(initial.first.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1540942789 * 1000, isUtc: true));
    await wikiPage.edit('New content');
    final after = await wikiPage.revisions().toList();
    expect(after.length, 28);
    for (final edit in after) {
      expect(edit.page, wikiPage);
    }
    expect(after.first.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1540981349 * 1000, isUtc: true));
  });

  test('lib/subreddit_wiki/wiki_page_moderation_add_remove', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_page_moderation_add_remove.json');
    final wikiPage = reddit.subreddit('drawapitesting').wiki['test_page'];
    final wikiPageMod = wikiPage.mod;

    final settings = await wikiPageMod.settings();
    expect(settings.editors.length, 0);
    await wikiPageMod.add('Toxicity-Moderator');
    await settings.refresh();
    expect(settings.editors.length, 1);
    expect(settings.editors[0].displayName, 'Toxicity-Moderator');
    await wikiPageMod.remove(reddit.redditor('Toxicity-Moderator'));
    await settings.refresh();
    expect(settings.editors.length, 0);
  });

  test('lib/subreddit_wiki/wiki_page_moderation_invalid_add_remove', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_page_moderation_invalid_add_remove.json');
    final wikiPage = reddit.subreddit('drawapitesting').wiki['test_page'];
    final wikiPageMod = wikiPage.mod;

    await expectLater(() async => await wikiPageMod.add('DrAwApIoFfIcIaL2'),
        throwsA(TypeMatcher<DRAWInvalidRedditorException>()));
    await expectLater(() async => await wikiPageMod.remove('DrAwApIoFfIcIaL2'),
        throwsA(TypeMatcher<DRAWInvalidRedditorException>()));
  });

  test('lib/subreddit_wiki/wiki_page_moderation_settings', () async {
    final reddit = await createRedditTestInstance(
        'test/subreddit/lib_subreddit_wiki_page_moderation_settings.json');
    final wikiPage = reddit.subreddit('drawapitesting').wiki['test_page'];
    final wikiPageMod = wikiPage.mod;
    final settings = await wikiPageMod.settings();
    expect(
        settings.permissionLevel, WikiPermissionLevel.approvedWikiContributors);
    expect(settings.listed, true);
    expect(settings.editors.length, 0);

    final updated =
        await wikiPageMod.update(false, WikiPermissionLevel.modsOnly);
    expect(updated.permissionLevel, WikiPermissionLevel.modsOnly);
    expect(updated.listed, false);
    expect(updated.editors.length, 0);
  });

  test('lib/subreddit_wiki/WikiPermissionLevelOrdering', () {
    expect(WikiPermissionLevel.values.length, 3);
    expect(WikiPermissionLevel.values[0],
        WikiPermissionLevel.useSubredditWikiPermissions);
    expect(WikiPermissionLevel.values[1],
        WikiPermissionLevel.approvedWikiContributors);
    expect(WikiPermissionLevel.values[2], WikiPermissionLevel.modsOnly);
  });
}
