// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:draw/draw.dart';

import '../test_utils.dart';

Future main() async {
  test('lib/redditor/friend', () async {
    final reddit = await createRedditTestInstance('test/redditor/lib_redditor_friend.json');
    final friendToBe = new Redditor.name(reddit, 'XtremeCheese');
    await friendToBe.friend(note: 'My best friend!');

    final myFriends = await reddit.user.friends();
    expect(myFriends.length, equals(1));
    final friend = myFriends[0];
    expect(friend['name'], equals('XtremeCheese'));
    expect(friend['note'], equals('My best friend!'));
  });
}
