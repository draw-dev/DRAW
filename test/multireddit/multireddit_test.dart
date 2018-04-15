// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:draw/draw.dart';
import 'package:test/test.dart';
import 'package:color/color.dart';

import '../test_utils.dart';

Future main() async {
  final expectedSubredditList = [
    {"name": "solotravel"},
    {"name": "Fishing"},
    {"name": "geocaching"},
    {"name": "Yosemite"},
    {"name": "CampingandHiking"},
    {"name": "whitewater"},
    {"name": "remoteplaces"},
    {"name": "Adirondacks"},
    {"name": "caving"},
    {"name": "travelphotos"},
    {"name": "canyoneering"},
    {"name": "Backcountry"},
    {"name": "Bushcraft"},
    {"name": "Kayaking"},
    {"name": "scuba"},
    {"name": "bouldering"},
    {"name": "CampingGear"},
    {"name": "urbanexploration"},
    {"name": "WWOOF"},
    {"name": "adventures"},
    {"name": "climbing"},
    {"name": "Mountaineering"},
    {"name": "sailing"},
    {"name": "hiking"},
    {"name": "iceclimbing"},
    {"name": "tradclimbing"},
    {"name": "backpacking"},
    {"name": "trailmeals"},
    {"name": "Climbingvids"},
    {"name": "camping"},
    {"name": "climbharder"},
    {"name": "skiing"},
    {"name": "Outdoors"},
    {"name": "alpinism"},
    {"name": "PacificCrestTrail"},
    {"name": "Ultralight"},
    {"name": "Hammocks"},
    {"name": "AppalachianTrail"}
  ];

  test('lib/multireddit/copy', () async {
    final reddit = await createRedditTestInstance(
        'test/multireddit/lib_multireddit_copy.json');
    final data = {
      "kind": "LabeledMulti",
      "data": {
        "can_edit": false,
        "display_name": "adventure",
        "name": "adventure",
        "subreddits": expectedSubredditList,
        "path": "/user/MyFifthOne/m/adventure/",
      }
    };
    final multireddit = new Multireddit.parse(reddit, data);
    final newMulti = await multireddit.copy('test-copy-adventure-2');
    expect(newMulti.displayName, 'test_copy_adventure_2');
    expect(newMulti.subreddits, multireddit.subreddits);
  });

  test('lib/multireddit/userMultis', () async {
    final reddit = await createRedditTestInstance(
        'test/multireddit/lib_user_multireddits.json');
    final multis = await reddit.user.multireddits();
    expect(multis.length, equals(9));
    final multi = multis[1];

    // Testing using data variable.
    expect(multi.data['name'], equals('drawtestingmulti'));
    expect(multi.data['display_name'], equals('drawtestingmulti'));
    expect(multi.data['can_edit'], isTrue);
    expect(multi.data['subreddits'].length, equals(81));

    // Testing using getters.
    expect(multi.author.displayName,
        await reddit.user.me().then((redditor) => redditor.displayName));
    expect(multi.over18, false);
    expect(multi.keyColor, new HexColor('#cee3f8'));
    expect(multi.visibility, Visibility.public);
    expect(multi.weightingScheme, WeightingScheme.classic);
    expect(multi.iconName, null);
    expect(multi.displayName, equals('drawtestingmulti'));
    expect(multi.fullname, equals('drawtestingmulti'));
    expect(multi.canEdit, isTrue);
    expect(multi.subreddits.length, equals(81));
//    expect(multi.data['subreddits'][0]['name'], equals('lisp'));
  });

  test('lib/multireddit/deleteMulti', () async {
    final reddit = await createRedditTestInstance(
      'test/multireddit/lib_multireddit_delete.json',
    );
    final multis = await reddit.user.multireddits();
    expect(multis.length, equals(5));
    await multis[1].delete();
    final newMultis = await reddit.user.multireddits();
    expect(newMultis.length, equals(4));
//    await reddit.auth.writeRecording();
  });

  test('lib/multireddit/AddSubreddit', () async {
    final reddit = await createRedditTestInstance(
      'test/multireddit/lib_multireddit_add_subreddit.json',
      live: true
    );
    final multis = await reddit.user.multireddits();
    final multi = multis[1];
    await multi.add('camping');
//    sleep(new Duration(seconds: 10)); Not working for some reason.???
//    expect(multi.data['subreddits'].length, equals(3));
//    expect(multi.subreddits.length, equals(3));
    await reddit.auth.writeRecording();
  });
}
