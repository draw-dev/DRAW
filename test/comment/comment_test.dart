// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future prettyPrint(comments, depth) async {
  if (comments == null) {
    return;
  }
  for (var i = 0; i < comments.length; ++i) {
    final tabs = '$depth \t' * depth;
    final comment = comments[i];
    if (comment is MoreComments) {
      await prettyPrint(await comment.comments(), depth);
    } else {
      final body = (await comment.property('body') ?? 'Null');
      print(tabs + body);
      await prettyPrint(comment.replies, depth + 1);
    }
  }
}

Future main() async {
  test('lib/comment/continue_test', () async {
    final reddit =
        await createRedditTestInstance('test/comment/continue_test.json');
    final submission = reddit.submission(id: '7czz1q');
    final comments = await submission.comments;
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
  });

  test('lib/comment/tons_of_comments_test', () async {
    final reddit = await createRedditTestInstance(
        'test/comment/tons_of_comments_test.json');
    final submission = reddit.submission(id: '7gylz9');
    final comments = await submission.comments;
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
  });
}
