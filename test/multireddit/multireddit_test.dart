// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

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
}
