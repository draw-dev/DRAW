import 'package:test/test.dart';
import 'package:draw/src/draw_config_context.dart';

void main() {
  test('Tests for default section of local file', () {
    final DRAWConfigContext configContext = new DRAWConfigContext();
    expect(
        configContext.oauthUrl, equals(Uri.parse('https://oauth.reddit.com')));
    expect(configContext.shortUrl, equals(Uri.parse('https://redd.it')));
    expect(
        configContext.redditUrl, equals(Uri.parse('https://www.reddit.com')));
    expect(configContext.clientId, equals('Y4PJOclpDQy3xZ'));
    expect(configContext.clientSecret, equals('UkGLTe6oqsMk5nHCJTHLrwgvHpr'));
    expect(configContext.password, equals('pni9ubeht4wd50gk'));
    expect(configContext.username, equals('fakebot1'));
  });
}
