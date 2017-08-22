import 'package:test/test.dart';
import 'package:draw/src/drawConfigContext.dart';

main() {
  test('Tests for default section of local file', () {
    final configContext = new DRAWConfigContext();
    expect(configContext.oauthUrl, equals('https://oauth.reddit.com'));
    expect(configContext.shortUrl, equals('https://redd.it'));
    expect(configContext.redditUrl, equals('https://www.reddit.com'));
    expect(configContext.clientId, equals('Y4PJOclpDQy3xZ'));
    expect(configContext.clientSecret, equals('UkGLTe6oqsMk5nHCJTHLrwgvHpr'));
    expect(configContext.password, equals('pni9ubeht4wd50gk'));
    expect(configContext.username, equals('fakebot1'));
  });
}
