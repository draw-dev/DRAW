// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

// ignore_for_file: unused_local_variable
Reddit reddit;
Future<SubredditModeration> subredditModerationHelper(String path,
    {live: false, sub: 'MorbidReality'}) async {
  reddit = await createRedditTestInstance(path, live: live);
  final subreddit = reddit.subreddit(sub);
  return subreddit.mod;
}

Future<void> main() async {
  test('lib/subreddit/subreddit_edited', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_edited.json');

    // Retrieve recently edited `UserContent`.
    await for (final post in morbidRealityMod.edited(limit: 5)) {
      expect(post is UserContent, isTrue);
    }

    // Retrieve edited `Comment`s.
    await for (final Comment post in morbidRealityMod.edited(
        limit: 5, only: SubredditModerationContentTypeFilter.commentsOnly)) {
      expect(post.edited, isTrue);
      expect(post.runtimeType, Comment);
    }

    // Retrieve edited `Submission`s. These are always self-text posts.
    await for (final Submission post in morbidRealityMod.edited(
        limit: 5, only: SubredditModerationContentTypeFilter.submissionsOnly)) {
      expect(post.edited, isTrue);
      // Only self-posts can be edited.
      expect(post.isSelf, isTrue);
    }
  });

  // TODO(bkonyi): make this test more verbose once `ModeratorAction` is
  // fully implemented.
  test('lib/subreddit/subreddit_mod_log', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_log.json');

    // Retrieve the last mod action.
    final modAction = await morbidRealityMod.log(limit: 1).first;
    expect(modAction.subreddit, reddit.subreddit('MorbidReality'));
    expect(modAction.action, ModeratorActionType.removeComment);

    final cheese =
        await morbidRealityMod.log(limit: 1, mod: 'XtremeCheese').first;
    expect(cheese.mod.displayName, 'XtremeCheese');
    expect(cheese.action, ModeratorActionType.approveComment);

    final redditor =
        await morbidRealityMod.log(mod: reddit.redditor('XtremeCheese')).first;
    expect(redditor.mod.displayName, 'XtremeCheese');

    final redditorsList = <RedditorRef>[];
    redditorsList.add(reddit.redditor('XtremeCheese'));
    redditorsList.add(reddit.redditor('spez'));
    final redditors =
        await morbidRealityMod.log(mod: redditorsList, limit: 5).first;
    expect(redditors.mod.displayName, 'XtremeCheese');

    try {
      final wiki = await morbidRealityMod
          .log(
              mod: reddit.redditor('XtremeCheese'),
              type: ModeratorActionType.wikiUnbanned,
              limit: 1)
          .first;
    } on StateError catch (e) {} catch (e) {
      fail("Expected 'StateError' to be throw, got '$e'");
    }

    expect(redditors.toString(), isNotNull);
  });

  test('lib/subreddit/subreddit_mod_queue', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_mod_queue.json');

    // Retrieve recently posted `UserContent`.
    final Comment post = await morbidRealityMod.modQueue().first;
    expect(
        post.body, "If the toddler had a gun this wouldn't have happened /s");

    // Retrieve recently posted `Comment`s.
    await for (final post in morbidRealityMod.modQueue(
        limit: 5, only: SubredditModerationContentTypeFilter.commentsOnly)) {
      expect(post.runtimeType, Comment);
    }

    // Retrieve recently posted `Submission`s.
    await for (final post in morbidRealityMod.modQueue(
        limit: 5, only: SubredditModerationContentTypeFilter.submissionsOnly)) {
      expect(post.runtimeType, Submission);
    }
  });

  test('lib/subreddit/subreddit_reports', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_mod_reports.json');

    // Retrieve recently posted `UserContent`.
    final Comment post = await morbidRealityMod.reports().first;
    expect(post.modReports.length, 0);
    expect(post.userReports.length, 1);
    final userReport = post.userReports[0];
    expect(userReport[0], 'Rule #1 - tasteless humor');
    expect(userReport[1], 1);

    // Retrieve recently reported `Comment`s.
    await for (final post in morbidRealityMod.modQueue(
        limit: 5, only: SubredditModerationContentTypeFilter.commentsOnly)) {
      expect(post.runtimeType, Comment);
    }

    // Retrieve recently reported `Submission`s.
    await for (final post in morbidRealityMod.modQueue(
        limit: 5, only: SubredditModerationContentTypeFilter.submissionsOnly)) {
      expect(post.runtimeType, Submission);
    }
  });

  test('lib/subreddit/subreddit_spam', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_mod_spam.json');

    // Retrieve recently posted `UserContent`.
    final Comment post = await morbidRealityMod.spam().first;
    // Items in the spam queue aren't necessarily marked as spam.
    expect(post.spam, isFalse);

    // Nothing that can really be checked here to verify the items are in the
    // spam queue, so we'll just exercise the filters.
    await for (final Comment post in morbidRealityMod.spam(
        limit: 5, only: SubredditModerationContentTypeFilter.commentsOnly)) {}
    await for (final Submission post in morbidRealityMod.spam(
        limit: 5,
        only: SubredditModerationContentTypeFilter.submissionsOnly)) {}
  });

  test('lib/subreddit/subreddit_unmoderated', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_mod_unmoderated.json');

    // Retrieve unmoderated `UserContent`.
    final post = await morbidRealityMod.unmoderated().first;
    expect(post is UserContent, isTrue);

    // In this case, we know we're getting a submission back, but that's not
    // always the case.
    final Submission submission = post;

    // Unmoderated posts are never approved.
    expect(submission.approved, isFalse);
  });

  test('lib/subreddit/subreddit_inbox', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_inbox.json');

    final messages = <Message>[];
    await for (final message in morbidRealityMod.inbox(limit: 2)) {
      messages.add(message);
    }
    expect(messages.length, 2);

    // We'll just check the first message's content.
    final message = messages[0];
    expect(message.author, 'GoreFox');
    expect(message.destination, 'bluntmanandrobin');
    expect(message.subject, "you've been banned");
    expect(message.body, contains('you have been banned from posting to'));
    expect(message.replies.length, 10);
  });

  test('lib/subreddit/subreddit_mod_unread', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_unread.json');

    final Message message = await morbidRealityMod.unread().first;

    // Obviously, this message should be new.
    expect(message.newItem, isTrue);
    expect(message.author, 'AutoModerator');
    expect(message.subject, 'Doxxing Alert!');
    expect(message.subreddit.displayName, 'MorbidReality');
  });

  test('lib/subreddit/subreddit_settings', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_settings.json');
    final settings = await morbidRealityMod.settings();
    expect(settings.allowPostCrossposts, isTrue);
    expect(settings.defaultSet, isTrue);
    expect(settings.description, isNotNull);
    expect(settings.publicDescription, isNotNull);
    expect(settings.subredditType, SubredditType.publicSubreddit);
    expect(settings.commentScoreHideMins, 60);
    expect(settings.showMediaPreview, isTrue);
    expect(settings.allowImages, isTrue);
    expect(settings.allowFreeformReports, isTrue);
    expect(settings.wikiEditAge, 365);
    expect(settings.submitText, '');
    expect(settings.title, 'The darkest recesses of humanity');
    expect(settings.collapseDeletedComments, isTrue);
    expect(settings.publicTraffic, isFalse);
    expect(settings.over18, isTrue);
    expect(settings.allowVideos, isFalse);
    expect(settings.spoilersEnabled, isFalse);
    expect(settings.submitLinkLabel, 'Submit');
    expect(settings.submitTextLabel, isNull);
    expect(settings.language, 'en');
    expect(settings.wikiEditKarma, 1000);
    expect(settings.hideAds, isFalse);
    expect(settings.headerHoverText, 'MorbidReality');
    expect(settings.allowDiscovery, isTrue);
    expect(settings.showMediaPreview, isTrue);
    expect(settings.commentScoreHideMins, 60);
    expect(settings.excludeBannedModQueue, isTrue);
    expect(settings.toString(), isNotNull);
  });

  test('lib/subreddit/subreddit_settings_local_modify', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_settings.json');
    final settings = await morbidRealityMod.settings();
    expect(settings.allowPostCrossposts, isTrue);
    settings.allowPostCrossposts = false;
    expect(settings.allowPostCrossposts, isFalse);

    expect(settings.showMedia, isTrue);
    settings.showMedia = false;
    expect(settings.showMedia, isFalse);

    expect(settings.defaultSet, isTrue);
    settings.defaultSet = false;
    expect(settings.defaultSet, isFalse);

    expect(settings.description, isNotNull);
    settings.description = null;
    expect(settings.description, isNull);

    expect(settings.publicDescription, isNotNull);
    settings.publicDescription = null;
    expect(settings.publicDescription, isNull);

    expect(settings.subredditType, SubredditType.publicSubreddit);
    settings.subredditType = SubredditType.restrictedSubreddit;
    expect(settings.subredditType, SubredditType.restrictedSubreddit);

    expect(settings.commentScoreHideMins, 60);
    settings.commentScoreHideMins = 30;
    expect(settings.commentScoreHideMins, 30);

    expect(settings.showMediaPreview, isTrue);
    settings.showMediaPreview = false;
    expect(settings.showMediaPreview, isFalse);

    expect(settings.allowImages, isTrue);
    settings.allowImages = false;
    expect(settings.allowImages, isFalse);

    expect(settings.allowFreeformReports, isTrue);
    settings.allowFreeformReports = false;
    expect(settings.allowFreeformReports, isFalse);

    expect(settings.wikiEditAge, 365);
    settings.wikiEditAge = 10;
    expect(settings.wikiEditAge, 10);

    expect(settings.submitText, '');
    settings.submitText = 'foobar';
    expect(settings.submitText, 'foobar');

    expect(settings.title, 'The darkest recesses of humanity');
    settings.title = 'testing';
    expect(settings.title, 'testing');

    expect(settings.collapseDeletedComments, isTrue);
    settings.collapseDeletedComments = false;
    expect(settings.collapseDeletedComments, isFalse);

    expect(settings.publicTraffic, isFalse);
    settings.publicTraffic = true;
    expect(settings.publicTraffic, isTrue);

    expect(settings.over18, isTrue);
    settings.over18 = false;
    expect(settings.over18, isFalse);

    expect(settings.allowVideos, isFalse);
    settings.allowVideos = true;
    expect(settings.allowVideos, isTrue);

    expect(settings.spoilersEnabled, isFalse);
    settings.spoilersEnabled = true;
    expect(settings.spoilersEnabled, isTrue);

    expect(settings.submitLinkLabel, 'Submit');
    settings.submitLinkLabel = 'Post';
    expect(settings.submitLinkLabel, 'Post');

    expect(settings.submitTextLabel, isNull);
    settings.submitTextLabel = 'foobar';
    expect(settings.submitTextLabel, 'foobar');

    expect(settings.language, 'en');
    settings.language = 'de';
    expect(settings.language, 'de');

    expect(settings.wikiEditKarma, 1000);
    settings.wikiEditKarma = 10;
    expect(settings.wikiEditKarma, 10);

    expect(settings.hideAds, isFalse);
    settings.hideAds = true;
    expect(settings.hideAds, isTrue);

    expect(settings.headerHoverText, 'MorbidReality');
    settings.headerHoverText = 'foobar';
    expect(settings.headerHoverText, 'foobar');

    expect(settings.allowDiscovery, isTrue);
    settings.allowDiscovery = false;
    expect(settings.allowDiscovery, isFalse);

    expect(settings.excludeBannedModQueue, isTrue);
    settings.excludeBannedModQueue = false;
    expect(settings.excludeBannedModQueue, isFalse);

    expect(settings.toString(), isNotNull);
  });

  test('lib/subreddit/subreddit_settings_copy', () async {
    final morbidRealityMod = await subredditModerationHelper(
        'test/subreddit/subreddit_moderation_settings.json');

    final settings = await morbidRealityMod.settings();
    final settingsCopy = new SubredditSettings.copy(settings);
    expect(settings.allowPostCrossposts, settingsCopy.allowPostCrossposts);
    expect(settings.defaultSet, settingsCopy.defaultSet);
    expect(settings.description, settingsCopy.description);
    expect(settings.publicDescription, settingsCopy.publicDescription);
    expect(settings.subredditType, settingsCopy.subredditType);
    expect(settings.commentScoreHideMins, settingsCopy.commentScoreHideMins);
    expect(settings.showMediaPreview, settingsCopy.showMediaPreview);
    expect(settings.allowImages, settingsCopy.allowImages);
    expect(settings.allowFreeformReports, settingsCopy.allowFreeformReports);
    expect(settings.wikiEditAge, settingsCopy.wikiEditAge);
    expect(settings.submitText, settingsCopy.submitText);
    expect(settings.title, settingsCopy.title);
    expect(
        settings.collapseDeletedComments, settingsCopy.collapseDeletedComments);
    expect(settings.publicTraffic, settingsCopy.publicTraffic);
    expect(settings.over18, settingsCopy.over18);
    expect(settings.allowVideos, settingsCopy.allowVideos);
    expect(settings.spoilersEnabled, settingsCopy.spoilersEnabled);
    expect(settings.submitLinkLabel, settingsCopy.submitLinkLabel);
    expect(settings.submitTextLabel, settingsCopy.submitTextLabel);
    expect(settings.language, settingsCopy.language);
    expect(settings.wikiEditKarma, settingsCopy.wikiEditKarma);
    expect(settings.hideAds, settingsCopy.hideAds);
    expect(settings.headerHoverText, settingsCopy.headerHoverText);
    expect(settings.allowDiscovery, settingsCopy.allowDiscovery);
    expect(settings.showMediaPreview, settingsCopy.showMediaPreview);
    expect(settings.commentScoreHideMins, settingsCopy.commentScoreHideMins);
    expect(settings.excludeBannedModQueue, settingsCopy.excludeBannedModQueue);
    expect(settings.toString(), settingsCopy.toString());
  });

  test('lib/subreddit/subreddit_update_settings', () async {
    final drawApiTestingMod = await subredditModerationHelper(
        'test/subreddit/subreddit_update_settings.json',
        sub: 'drawapitesting');
    var settings = await drawApiTestingMod.settings();
    expect(settings.title, 'DRAW API Testing');
    final originalTitle = settings.title;
    settings.title = 'test title';

    await drawApiTestingMod.update(settings);
    final newSettings = await drawApiTestingMod.settings();
    expect(newSettings.title, settings.title);

    newSettings.title = originalTitle;
    await drawApiTestingMod.update(newSettings);

    settings = await drawApiTestingMod.settings();
    expect(settings.title, 'DRAW API Testing');
  });
}
