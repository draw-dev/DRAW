import 'package:test/test.dart';
import 'package:draw/src/draw_config_context.dart';

void main() {
  test('Simple tests for default section of local file.', () {
    final DRAWConfigContext configContext = new DRAWConfigContext();
    expect(configContext.clientId, equals('Y4PJOclpDQy3xZ'));
    expect(configContext.clientSecret, equals('UkGLTe6oqsMk5nHCJTHLrwgvHpr'));
    expect(configContext.password, equals('pni9ubeht4wd50gk'));
    expect(configContext.username, equals('fakebot1'));
  });

  test('Testing non-default section.', () {
    final DRAWConfigContext configContext =
        new DRAWConfigContext(siteName: 'section');
    expect(configContext.password, equals('different'));
    expect(configContext.oauthUrl, equals('https://oauth.reddit.com'));
  });

  test(
      'Testing non-default section for parameters not present in default site.',
      () {
    final DRAWConfigContext configContext =
        new DRAWConfigContext(siteName: 'section1');
    expect(configContext.password, equals('pni9ubeht4wd50gk'));
    expect(configContext.username, equals('sectionbot'));
  });

  test('Testing non-default parameters with empty strings.', () {
    final DRAWConfigContext configContext =
        new DRAWConfigContext(siteName: 'emptyTest');
    expect(configContext.username, equals(''));
  });

  test('Testing default values for unset parameters.', () {
    final DRAWConfigContext configContext = new DRAWConfigContext();
    expect(configContext.shortUrl, equals('https://redd.it'));
    expect(configContext.checkForUpdates, equals(false));
    expect(configContext.revokeToken,
        equals('https://www.reddit.com/api/v1/revoke_token'));
    expect(configContext.oauthUrl, equals('oauth.reddit.com'));
    expect(configContext.authorizeUrl,
        equals('https://reddit.com/api/v1/authorize'));
    expect(configContext.accessToken,
        equals('https://www.reddit.com/api/v1/access_token'));
  });

  test('Test for CheckForUpdates Truth value check', () {
    final DRAWConfigContext configContext =
        new DRAWConfigContext(siteName: 'testUpdateCheck1');
    expect(configContext.checkForUpdates, equals(true));
    final DRAWConfigContext configContext1 =
        new DRAWConfigContext(siteName: 'testUpdateCheckOn');
    expect(configContext1.checkForUpdates, equals(true));
    final DRAWConfigContext configContext2 =
        new DRAWConfigContext(siteName: 'testUpdateCheckTrue');
    expect(configContext2.checkForUpdates, equals(true));
    final DRAWConfigContext configContext3 =
        new DRAWConfigContext(siteName: 'testUpdateCheckYes');
    expect(configContext3.checkForUpdates, equals(true));
    final DRAWConfigContext configContext4 =
        new DRAWConfigContext(siteName: 'testUpdateCheckFalse');
    expect(configContext4.checkForUpdates, equals(false));
  });
}
