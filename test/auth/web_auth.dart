// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import 'credentials.dart';

Future<void> main() async {
  test('web authenticator', () async {
    final reddit = await Reddit.createInstance(
      clientId: kWebClientID,
      clientSecret: kWebClientSecret,
      redirectUri: Uri.parse('https://www.google.com'),
      userAgent: 'draw_web_test',
    );

    final dest = reddit.auth.url(['identity'], 'foobar');
    print('Destination URL: $dest');

    final loginResult = Process.runSync('curl', [
      '-d"user=$kUsername"',
      '-d"passwd=$kPassword"',
      '-d"api_type=json"',
      '-H"user-agent: draw_web_test"',
      '-j',
      '-c Cookie.txt',
      'https://ssl.reddit.com/api/login'
    ]);
    print(loginResult.stdout);
    print(loginResult.stderr);
    final loginResponseMap = json.decode(loginResult.stdout);
    final modhash = loginResponseMap['json']['data']['modhash'];

    final authResult = Process.runSync('curl', [
      '-L',
      '--dump-header foobar.txt',
      '-d"client_id=$kWebClientID"',
      '-d"redirect_uri=https://www.google.com"',
      '-d"scope=*"',
      '-d"state=foobar"',
      '-d"response_type=code"',
      '-d"duration=permanent"',
      '-d"uh=$modhash"',
      '-d"authorize=Allow"',
      '-H"user-agent: draw_web_test"',
      '-c Cookie.txt',
      '-b Cookie.txt',
      '$dest'
    ]);

    final outputHeaderFile = new File('foobar.txt');
    expect(outputHeaderFile.existsSync(), isTrue);
    final fileLines = outputHeaderFile.readAsStringSync().split('\n');
    String state;
    String code;
    for (final line in fileLines) {
      if (line.startsWith('location:')) {
        final split = line.split(' ');
        expect(split.length, 2);
        final responseParams = Uri.parse(split[1]).queryParameters;
        state = responseParams['state'];
        code = responseParams['code'];
        break;
      }
    }

    expect(state, isNotNull);
    expect(state, 'foobar');
    expect(code, isNotNull);
    await reddit.auth.authorize(code);
    expect(await reddit.user.me(), isNotNull);
  });
}
