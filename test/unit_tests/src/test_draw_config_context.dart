import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../../../lib/src/draw_config_context.dart';

//Mocking
class MockPlatform extends Mock implements Platform {}

/*
//TODO(ckartik): Utilize mirrors lib here to get access to private methods.
void _testUserConfigPathGetter() {
  //Platform os = new MockPlatform();
  final dummy_mac_envs = {
    'TERM_SESSION_ID': 'w0t0p0:8DC4D1FE-DF20-48B5-824E-56692EB7F544',
    'SSH_AUTH_SOCK': '/private/tmp/com.apple.launchd.7oRE2BfsAa/Listeners',
    'Apple_PubSub_Socket_Render':
        '/private/tmp/com.apple.launchd.07ZqI5EHtp/Render',
    'COLORFGBG': '7;0',
    'ITERM_PROFILE': 'Dark',
    'XPC_FLAGS': '0x0',
    'LANG': 'en_US.UTF-8',
    'PWD': '/Users/krishchopra/src/DRAW/mockito_tests/src',
    'SHELL': '/bin/zsh',
    'TERM_PROGRAM_VERSION': '3.1.4',
    'TERM_PROGRAM': 'iTerm.app',
    'PATH':
        '/Users/krishchopra/.rvm/gems/ruby-2.2.1/bin:/Users/krishchopra/.rvm/gems/ruby-2.2.1@global/bin:/Users/krishchopra/.rvm/rubies/ruby-2.2.1/bin:/Users/krishchopra/flutter/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/git/bin:/Applications/Racket v6.2.1/bin:/Library/TeX/texbin:~/.pub-cache/bin:/Users/krishchopra/.fzf/bin:/Users/krishchopra/.rvm/bin',
    'DISPLAY':
        '/private/tmp/com.apple.launchd.d7TtJnpcM3/org.macosforge.xquartz:0',
    'COLORTERM': 'truecolor',
    'TERM': 'xterm-256color',
    'HOME': '/Users/krishchopra',
    'TMPDIR': '/var/folders/nt/hdfptzsd5w9gy38mp9rpttnw0000gn/T/',
    'USER': 'krishchopra',
    'XPC_SERVICE_NAME': '0',
    'LOGNAME': 'krishchopra',
    '__CF_USER_TEXT_ENCODING': '0x1F5:0x0:0x0',
    'ITERM_SESSION_ID': 'w0t0p0:8DC4D1FE-DF20-48B5-824E-56692EB7F544',
    'SHLVL': '1',
    'OLDPWD': '/Users/krishchopra/src/DRAW/mockito_tests',
    'ZSH': '/Users/krishchopra/.oh-my-zsh',
    'PAGER': 'less',
    'LESS': '-R',
    'LC_CTYPE': 'en_US.UTF-8',
    'LSCOLORS': 'Gxfxcxdxbxegedabagacad',
    'rvm_prefix': '/Users/krishchopra',
    'rvm_path': '/Users/krishchopra/.rvm',
    'rvm_bin_path': '/Users/krishchopra/.rvm/bin',
    '_system_type': 'Darwin',
    '_system_name': 'OSX',
    '_system_version': '10.12',
    '_system_arch': 'x86_64',
    'rvm_version': '1.27.0 (latest)',
    'GEM_HOME': '/Users/krishchopra/.rvm/gems/ruby-2.2.1',
    'GEM_PATH':
        '/Users/krishchopra/.rvm/gems/ruby-2.2.1:/Users/krishchopra/.rvm/gems/ruby-2.2.1@global',
    'MY_RUBY_HOME': '/Users/krishchopra/.rvm/rubies/ruby-2.2.1',
    'IRBRC': '/Users/krishchopra/.rvm/rubies/ruby-2.2.1/.irbrc',
    'RUBY_VERSION': 'ruby-2.2.1',
    'rvm_alias_expanded': '',
    'rvm_bin_flag': '',
    'rvm_docs_type': '',
    'rvm_gemstone_package_file': '',
    'rvm_gemstone_url': '',
    'rvm_niceness': '',
    'rvm_nightly_flag': '',
    'rvm_only_path_flag': '',
    'rvm_proxy': '',
    'rvm_quiet_flag': '',
    'rvm_ruby_bits': '',
    'rvm_ruby_file': '',
    'rvm_ruby_make': '',
    'rvm_ruby_make_install': '',
    'rvm_ruby_mode': '',
    'rvm_script_name': '',
    'rvm_sdk': '',
    'rvm_silent_flag': '',
    'rvm_use_flag': '',
    'rvm_wrapper_name': '',
    'rvm_hook': '',
    '_': '/usr/local/bin/dart'
  };
  //Mac Stubbing
  //when(os.enviroment).thenReturn(dummy_mac_envs);
}
*/

void main() {
  // Given an range of different inputs for [checkForUpdates],
  // verify the resulting bool for checkForUpdates.
  group('checkForUpdates: ', () {
    test('false', () {
      final expectedTruthValue = false;
      final falseValues = [false, 'False', 'other', 'anything', '0', 0];
      for (var value in falseValues) {
        final config = new DRAWConfigContext(checkForUpdates: value);
        expect(config.checkForUpdates, expectedTruthValue);
      }
    });

    test('true', () {
      final expectedTruthValue = true;
      final trueValues = [true, '1', 'true', 'YES', 'on'];
      for (var value in trueValues) {
        final config = new DRAWConfigContext(checkForUpdates: value);
        assert(
            config.checkForUpdates == expectedTruthValue, "failed on $value");
      }
    });
  });
}
