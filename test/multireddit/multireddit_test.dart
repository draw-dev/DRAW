// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'package:color/color.dart';
import 'package:draw/draw.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

Future<void> main() async {
  final expectedSubredditList = [
    {'name': 'solotravel'},
    {'name': 'Fishing'},
    {'name': 'geocaching'},
    {'name': 'Yosemite'},
    {'name': 'CampingandHiking'},
    {'name': 'whitewater'},
    {'name': 'remoteplaces'},
    {'name': 'Adirondacks'},
    {'name': 'caving'},
    {'name': 'travelphotos'},
    {'name': 'canyoneering'},
    {'name': 'Backcountry'},
    {'name': 'Bushcraft'},
    {'name': 'Kayaking'},
    {'name': 'scuba'},
    {'name': 'bouldering'},
    {'name': 'CampingGear'},
    {'name': 'urbanexploration'},
    {'name': 'WWOOF'},
    {'name': 'adventures'},
    {'name': 'climbing'},
    {'name': 'Mountaineering'},
    {'name': 'sailing'},
    {'name': 'hiking'},
    {'name': 'iceclimbing'},
    {'name': 'tradclimbing'},
    {'name': 'backpacking'},
    {'name': 'trailmeals'},
    {'name': 'Climbingvids'},
    {'name': 'camping'},
    {'name': 'climbharder'},
    {'name': 'skiing'},
    {'name': 'Outdoors'},
    {'name': 'alpinism'},
    {'name': 'PacificCrestTrail'},
    {'name': 'Ultralight'},
    {'name': 'Hammocks'},
    {'name': 'AppalachianTrail'}
  ];

  test('lib/multireddit/copy_parse_constructor_basic', () async {
    final reddit = await createRedditTestInstance(
        'test/multireddit/lib_multireddit_copy.json');
    final data = {
      'kind': 'LabeledMulti',
      'data': {
        'can_edit': false,
        'display_name': 'adventure',
        'name': 'adventure',
        'subreddits': expectedSubredditList,
        'path': '/user/MyFifthOne/m/adventure/',
      }
    };
    final multireddit = Multireddit.parse(reddit, data);
    final newMulti = await multireddit.copy('test-copy-adventure-2');
    expect(newMulti.displayName, 'test_copy_adventure_2');
    expect(newMulti.subreddits, multireddit.subreddits);
  });

  test('lib/multireddit/copy_without_parsing_basic', () async {
    final newMultiName = 'CopyOfMultireddit';
    final newMultiNameSlug = 'copyofmultireddit';
    final reddit = await createRedditTestInstance(
        'test/multireddit/lib_multireddit_copy_2.json');
    final oldMulti = (await reddit.user.multireddits())[1];
    final newMulti = await oldMulti.copy(newMultiName);
    expect(newMulti.displayName, newMultiNameSlug);
    expect(newMulti.subreddits, oldMulti.subreddits);
  });

  test('lib/multireddit/multis_from_user_non_trival', () async {
    final reddit = await createRedditTestInstance(
        'test/multireddit/lib_user_multireddits.json');
    final multis = await reddit.user.multireddits();
    expect(multis.length, 9);
    final multi = multis[1];

    // Testing using data variable.
    expect(multi.data['name'], 'drawtestingmulti');
    expect(multi.data['display_name'], 'drawtestingmulti');
    expect(multi.data['can_edit'], isTrue);
    expect(multi.data['subreddits'].length, 81);

    // Testing using getters.
    expect(multi.author.displayName, (await reddit.user.me()).displayName);
    expect(multi.over18, isFalse);
    expect(multi.keyColor, HexColor('#cee3f8'));
    expect(multi.visibility, Visibility.public);
    expect(multi.weightingScheme, WeightingScheme.classic);
    expect(multi.iconName, isNull);
    expect(multi.displayName, 'drawtestingmulti');
    expect(multi.fullname, 'drawtestingmulti');
    expect(multi.canEdit, isTrue);
    expect(multi.subreddits.length, 81);
  });

  test('lib/multireddit/delete_multi_basic', () async {
    final reddit = await createRedditTestInstance(
      'test/multireddit/lib_multireddit_delete.json',
    );
    final multis = await reddit.user.multireddits();
    expect(multis.length, 5);
    await multis[1].delete();
    final newMultis = await reddit.user.multireddits();
    expect(newMultis.length, 4);
  });

  test('lib/multireddit/add_subreddit_basic', () async {
    final reddit = await createRedditTestInstance(
      'test/multireddit/lib_multireddit_add_subreddit.json',
    );
    final multis = await reddit.user.multireddits();
    final multi = multis[1];
    await multi.add('camping');
  });
}
