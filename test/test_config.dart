import 'dart:io';

import 'package:test/test.dart';
import 'package:draw/src/drawConfigContext.dart';
import 'package:draw/src/exceptions.dart';

main() {
  test('Tests Initialization of Constructor', () {
    var configContext = new DRAWConfigContext();
    expect(configContext.password, equals(null));
    expect(configContext.oauthUrl, equals('https://oauth.reddit.com'));
    expect(configContext.shortUrl, equals('https://redd.it'));
    expect(configContext.redditUrl, equals('https://www.reddit.com'));
  });
}
