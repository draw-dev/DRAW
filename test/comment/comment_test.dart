// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future<void> prettyPrint(comments, depth) async {
  if (comments == null) {
    return;
  }
  for (var i = 0; i < comments.length; ++i) {
    final tabs = '$depth \t' * depth;
    final comment = comments[i];
    if (comment is MoreComments) {
      await prettyPrint(await comment.comments(), depth);
    } else {
      final body = (await comment.body ?? 'Null');
      print(tabs + body);
      await prettyPrint(comment.replies, depth + 1);
    }
  }
}

// Note: these tests are skipped on Windows due to issues with line endings.
// TODO(bkonyi): fix these tests on Windows at some point?
Future<void> main() async {
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
        new ZoneSpecification(print: (self, parent, zone, message) {
      output += message + '\n';
    }));
    final actual =
        new File('test/comment/continue_test_expected.out').readAsStringSync();
    expect(output, equals(actual));
  }, skip: Platform.isWindows);

  test('lib/comment/tons_of_comments_test', () async {
    final reddit = await createRedditTestInstance(
        'test/comment/tons_of_comments_test.json');
    final submission = await reddit.submission(id: '7gylz9').populate();
    final comments = submission.comments;
    final printer = () async {
      await prettyPrint(comments, 0);
    };

    var output = "";
    var count = 0;
    await runZoned(printer, zoneSpecification:
        new ZoneSpecification(print: (self, parent, zone, message) {
      count++;
      output += "$count" + message + '\n';
    }));
    final actual = new File('test/comment/tons_of_comments_expected.out')
        .readAsStringSync();
    expect(output, equals(actual));
  }, skip: Platform.isWindows);

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
}
