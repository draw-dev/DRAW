// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/user_content_moderation/contest-mode', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_contest_mode.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    expect(submission.contestMode, false);
    await submission.mod.contestMode();
    await submission.refresh();
    expect(submission.contestMode, true);
    await submission.mod.contestMode(state: false);
    await submission.refresh();
    expect(submission.contestMode, false);
  });

  test('lib/user_content_moderation/set-flair', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_set_flair.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    expect(submission.data!['link_flair_text'], isNull);

    await submission.mod.flair(text: 'Test Flair');
    await submission.refresh();
    expect(submission.data!['link_flair_text'], 'Test Flair');

    await submission.mod.flair();
    await submission.refresh();
    expect(submission.data!['link_flair_text'], isNull);
  });

  test('lib/user_content_moderation/lock-unlock', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_lock_unlock.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    expect(submission.locked, isFalse);

    await submission.mod.lock();
    await submission.refresh();
    expect(submission.locked, isTrue);

    await submission.mod.unlock();
    await submission.refresh();
    expect(submission.locked, isFalse);
  });

  test('lib/user_content_moderation/nsfw-sfw', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_nsfw_sfw.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    expect(submission.over18, isFalse);

    await submission.mod.nsfw();
    await submission.refresh();
    expect(submission.over18, isTrue);

    await submission.mod.sfw();
    await submission.refresh();
    expect(submission.over18, isFalse);
  });

  test('lib/user_content_moderation/spoiler', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_spoiler.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();
    expect(submission.spoiler, isFalse);

    await submission.mod.spoiler();
    await submission.refresh();
    expect(submission.spoiler, isTrue);

    await submission.mod.unspoiler();
    await submission.refresh();
    expect(submission.spoiler, isFalse);
  });

  String _commentSortTypeToString(CommentSortType t) {
    switch (t) {
      case CommentSortType.confidence:
        return 'confidence';
      case CommentSortType.top:
        return 'top';
      case CommentSortType.newest:
        return 'new';
      case CommentSortType.controversial:
        return 'controversial';
      case CommentSortType.old:
        return 'old';
      case CommentSortType.random:
        return 'random';
      case CommentSortType.qa:
        return 'qa';
      case CommentSortType.blank:
        return 'blank';
      default:
        throw DRAWInternalError('CommentSortType: $t is not supported.');
    }
  }

  // TODO(bkonyi): add suggestedSort property to Submission
  test('lib/user_content_moderation/suggested-sort', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_suggested_sort.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    for (final s in CommentSortType.values) {
      await submission.mod.suggestedSort(sort: s);
      await submission.refresh();
      if (s != CommentSortType.blank) {
        expect(submission.data!['suggested_sort'], _commentSortTypeToString(s));
      } else {
        expect(submission.data!['suggested_sort'], isNull);
      }
    }
    expect(submission.data!['suggested_sort'], isNull);
  }, skip: 'Needs updating to support "CommentSortType.best"');

  test('lib/user_content_moderation/sticky', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_sticky.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    expect(submission.stickied, isFalse);
    await submission.mod.sticky();
    await submission.refresh();

    expect(submission.stickied, isTrue);
    await submission.mod.sticky(state: false);
    await submission.refresh();

    expect(submission.stickied, isFalse);
    await submission.mod.sticky(bottom: false);
    await submission.refresh();

    expect(submission.stickied, isTrue);
    await submission.mod.sticky(state: false);
    await submission.refresh();

    expect(submission.stickied, isFalse);
  });

  test('lib/user_content_moderation/remove-approve', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_remove_approve.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    expect(submission.removed, isFalse);
    expect(submission.approved, isTrue);

    await submission.mod.remove();
    await submission.refresh();

    expect(submission.removed, isTrue);
    expect(submission.approved, isFalse);

    await submission.mod.approve();
    await submission.refresh();

    expect(submission.removed, isFalse);
    expect(submission.approved, isTrue);
  });

  test('lib/user_content_moderation/distinguish', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_distinguish.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    expect(submission.distinguished, null);
    expect(submission.stickied, isFalse);

    await submission.mod.distinguish(how: DistinctionType.yes);
    await submission.refresh();

    expect(submission.distinguished, 'moderator');

    await submission.mod.undistinguish();
    await submission.refresh();

    expect(submission.distinguished, null);
    expect(submission.stickied, isFalse);
  });

  test('lib/user_content_moderation/reports', () async {
    final reddit = await createRedditTestInstance(
        'test/user_content_moderation/lib_user_content_moderation_reports.json');
    final submission = await reddit.submission(id: '7x6ew7').populate();

    expect(submission.ignoreReports, isFalse);

    await submission.mod.ignoreReports();
    await submission.refresh();

    expect(submission.ignoreReports, isTrue);

    await submission.mod.unignoreReports();
    await submission.refresh();

    expect(submission.ignoreReports, isFalse);
  });
}
