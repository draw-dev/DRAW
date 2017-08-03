// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:draw/draw.dart';
import 'package:draw/src/auth.dart';

import 'test_authenticator.dart';

void main() async {
  test('api/v1/me_RawTest', () async {
    final testAuth = new TestAuthenticator('test/records/api_v1_me_raw.json');
    final reddit = new Reddit.fromAuthenticator(testAuth);
    await reddit.initialized;
    final response =
        await reddit.auth.get(Uri.parse('https://oauth.reddit.com/api/v1/me'));
    expect(response['is_employee'], equals(false));
    expect(response['name'], equals('DRAWApiOfficial'));
    expect(response['created'], equals(1501830779.0));
    expect(response['features'], isNot(null));
    Map features = response['features'];
    expect(features['do_not_track'], equals(true));
  });
}
