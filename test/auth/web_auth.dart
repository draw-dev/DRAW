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
  const cookieFile = 'cookie.txt';
  const expectedState = 'foobar';
  const headerFile = 'response.txt';
  const redirect = 'https://www.google.com';
  const scope = '*';
  const userAgent = 'draw_web_test_agent';

  test('web authenticator', () async {
    final reddit = Reddit.createWebFlowInstance(
        clientId: kWebClientID,
        clientSecret: kWebClientSecret,
        redirectUri: Uri.parse(redirect),
        userAgent: userAgent + '_authenticated');
    expect(reddit.auth.userAgent, userAgent + '_authenticated');
    // Create our implicit grant flow URI.
    final dest = reddit.auth.url([scope], expectedState);

    // ------------------------------------------------------------------ //
    // Start Web Authentication Flow to Emulate User Granting Permissions //
    // ------------------------------------------------------------------ //

    // Login.
    final loginResult = Process.runSync('curl', [
      '-duser=$kUsername',
      '-dpasswd=$kPassword',
      '-dapi_type=json',
      '-j',
      '-A',
      '"$userAgent"',
      '-c$cookieFile',
      '-v',
      'https://ssl.reddit.com/api/login'
    ]);

    final loginResponseMap = json.decode(loginResult.stdout);
    final modhash = loginResponseMap['json']['data']['modhash'];

    // Wait 2 seconds to avoid being rate limited (just in case).
    await new Future.delayed(Duration(seconds: 2));

    // Accept permissions.
    try {
      // This sometimes throws with a FormatException: Bad UTF-8 encoding.
      // Should probably hunt the cause down and file an issue...
      Process.runSync('curl', [
        '-L',
        '--dump-header',
        headerFile,
        '-dclient_id=$kWebClientID',
        '-dredirect_uri=$redirect',
        '-dscope=$scope',
        '-dstate=$expectedState',
        '-dresponse_type=code',
        '-dduration=permanent',
        '-duh=$modhash',
        '-dauthorize=Allow',
        '-A',
        '"$userAgent"',
        '-c$cookieFile',
        '-b$cookieFile',
        Uri.decodeFull(dest.toString()),
      ]);
    } catch (e) {
      print('Exception caught: $e');
    }

    // The code is in the header of the response, which we've stored in
    // response.txt.
    final outputHeaderFile = new File(headerFile);
    expect(outputHeaderFile.existsSync(), isTrue);

    final fileLines = outputHeaderFile.readAsStringSync().split('\n');
    String state;
    String code;

    // Try and find the code and state in the response.
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

    // Check to see if we've found our code and state.
    expect(state, isNotNull);
    expect(state, expectedState);
    expect(code, isNotNull);

    if (code.codeUnitAt(code.length - 1) == 13) {
      // Remove \r (this was annoying to find).
      code = code.substring(0, code.length - 1);
    }

    // ------------------------------------------------------------------ //
    //  End Web Authentication Flow to Emulate User Granting Permissions  //
    // ------------------------------------------------------------------ //

    // Authorize via OAuth2.
    await reddit.auth.authorize(code);

    // Sanity check to ensure we have valid credentials.
    expect(await reddit.user.me(), isNotNull);

    final creds = reddit.auth.credentials.toJson();

    // Attempt to create a new instance with the saved credentials.
    final redditRestored = await Reddit.restoreAuthenticatedInstance(creds,
        clientId: kWebClientID,
        clientSecret: kWebClientSecret,
        userAgent: userAgent);
    expect(await redditRestored.user.me(), isNotNull);

    // Ensure we can refresh credentials.
    await redditRestored.auth.refresh();
    expect(await redditRestored.user.me(), isNotNull);

    // Revoke the OAuth2 token and ensure an exception is thrown.
    await redditRestored.auth.revoke();
    expect(() async => await redditRestored.user.me(),
        throwsA(isInstanceOf<DRAWAuthenticationError>()));
  });
}
