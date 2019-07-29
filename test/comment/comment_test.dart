// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> prettyPrint(comments, depth) async {
  if (comments == null) {
    return;
  }
  for (var i = 0; i < comments.length; ++i) {
    final tabs = '$depth \t' * depth;
    final comment = comments[i];
    if (comment is MoreComments) {
      expect(
          comment.isContinueThisThread || comment.isLoadMoreComments, isTrue);
      await prettyPrint(await comment.comments(), depth);
    } else {
      final body = (await comment.body ?? 'Null');
      print(tabs + body);
      await prettyPrint(comment.replies, depth + 1);
    }
  }
}

void submissionChecker(rootSubmission, comments) {
  if (comments == null) {
    return;
  }
  for (final c in comments.toList()) {
    expect(c.submission.hashCode, rootSubmission.hashCode);
  }
}

Future<void> main() async {
  test('lib/comment/invalid_comment_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/invalid_test.json');
    await expectLater(
        () async => await CommentRef.withID(reddit, 'abc123').populate(),
        throwsA(TypeMatcher<DRAWInvalidCommentException>()));
  });

  test('lib/comment/continue_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/continue_test.json');
    final submission = await reddit.submission(id: '7czz1q').populate();
    final comments = submission.comments;
    final printer = () async {
      await prettyPrint(comments, 0);
    };

    var output = "";
    await runZoned(printer, zoneSpecification:
        ZoneSpecification(print: (self, parent, zone, message) {
      output += message + '\n';
    }));
    final expected =
        File('test/comment/continue_test_expected.out').readAsStringSync();
    expect(output, expected);
  });

  test('lib/comment/more_comment_expand_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/more_comment_expand_test');
    final Comment comment = await reddit.comment(id: 'e1mnhdn').populate();
    submissionChecker(comment.submission, comment.replies);

    await comment.replies.replaceMore();
    final printer = () async {
      await prettyPrint(<Comment>[comment], 0);
    };

    var output = "";
    var count = 0;
    await runZoned(printer, zoneSpecification:
        ZoneSpecification(print: (self, parent, zone, message) {
      count++;
      output += "$count" + message + '\n';
    }));
    final expected = File('test/comment/more_comment_expand_test_expected.out')
        .readAsStringSync();
    expect(output, expected);
  });

  int getMoreCommentsCount(Submission submission) {
    int moreComments = 0;
    submission.comments.toList().forEach((v) {
      if (v is MoreComments) {
        moreComments++;
      }
    });
    return moreComments;
  }

  void checkNoDuplicates(Submission submission) {
    final Set ids = new Set<String>();
    final comments = submission.comments.toList();
    for (dynamic comment in comments) {
      if (ids.contains(comment.fullname)) {
        fail('Multiple comments with the same ID are in the CommentForest');
      }
      ids.add(comment.fullname);
    }
  }

  test('lib/comment/more_comment_count_test', () async {
    final reddit = await createRedditTestInstance(
        'test/comment/more_comment_count_test.json');
    final submission = await reddit.submission(id: 'bpvpfm').populate();
    expect(getMoreCommentsCount(submission), 2);
    expect(submission.comments.toList().length, 202);
    checkNoDuplicates(submission);

    await submission.comments.replaceMore();
    expect(getMoreCommentsCount(submission), 0);
    expect(submission.comments.toList().length, 501);
    checkNoDuplicates(submission);

    await submission.comments.replaceMore();
    expect(getMoreCommentsCount(submission), 0);
    expect(submission.comments.toList().length, 501);
    checkNoDuplicates(submission);
  });

  test('lib/comment/tons_of_comments_test', () async {
    final reddit = await createRedditTestInstance(
        'test/comment/tons_of_comments_test.json');
    final submission = await reddit.submission(id: '7gylz9').populate();
    final comments = submission.comments;
    submissionChecker(submission, comments);
    final printer = () async {
      await prettyPrint(comments, 0);
    };

    var output = "";
    var count = 0;
    await runZoned(printer, zoneSpecification:
        ZoneSpecification(print: (self, parent, zone, message) {
      count++;
      output += "$count" + message + '\n';
    }));
    final expected =
        File('test/comment/tons_of_comments_expected.out').readAsStringSync();
    expect(output, equals(expected));
  });

  test('lib/comment/comment_ref_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/comment_ref_test.json');
    final comment = await reddit.comment(id: 'dxj0i8m').populate();
    final commentWithPath = await reddit
        .comment(
            url:
                'https://www.reddit.com/r/pics/comments/8cz8v0/owls_born_outside_of_office_window_wont_stop/dxj0i8m/')
        .populate();

    expect(
        comment.body, '“ ok class, everyone have a look into our Humanarium”');
    expect(commentWithPath.body, comment.body);
    expect(commentWithPath.id, comment.id);
    expect(comment.id, 'dxj0i8m');
    expect(comment.submission.shortlink, commentWithPath.submission.shortlink);
  });

  test('lib/comment/comment_properties_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/continue_test.json');
    final submission = await reddit.submission(id: '7czz1q').populate();
    final comment = submission.comments[0] as Comment;

    expect(comment.approved, isFalse);
    expect(comment.approvedAtUtc, isNull);
    expect(comment.approvedBy, isNull);
    expect(comment.archived, isFalse);
    expect(comment.authorFlairText, isNull);
    expect(comment.bannedAtUtc, isNull);
    expect(comment.bannedBy, isNull);
    expect(comment.canGild, isFalse);
    expect(comment.canModPost, isTrue);
    expect(comment.collapsed, isFalse);
    expect(comment.collapsedReason, isNull);
    expect(comment.createdUtc,
        DateTime.fromMillisecondsSinceEpoch(1510703692 * 1000, isUtc: true));
    expect(comment.depth, 0);
    expect(comment.downvotes, 0);
    expect(comment.edited, isFalse);
    expect(comment.ignoreReports, isFalse);
    expect(comment.isSubmitter, isTrue);
    expect(comment.vote, VoteState.upvoted);
    expect(comment.linkId, 't3_7czz1q');
    expect(comment.numReports, 0);
    expect(comment.parentId, 't3_7czz1q');
    expect(comment.permalink,
        '/r/drawapitesting/comments/7czz1q/testing/dpty59t/');
    expect(comment.removalReason, isNull);
    expect(comment.removed, isFalse);
    expect(comment.saved, isFalse);
    expect(comment.score, 1);
    expect(comment.scoreHidden, isFalse);
    expect(comment.spam, isFalse);
    expect(comment.stickied, isFalse);
    expect(comment.subreddit, reddit.subreddit('drawapitesting'));
    expect(comment.subredditId, 't5_3mqw1');
    expect(comment.subredditType, 'restricted');
    expect(comment.upvotes, 1);
    expect(comment.isRoot, isTrue);
  });
}
