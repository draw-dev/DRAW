/// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';

import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import 'exceptions.dart';

const String kAccessToken = 'access_token';
const String kAuthorize = 'authorize_uri';
const String kCheckForUpdates = 'check_for_updates';
const String kClientId = 'client_id';
const String kClientSecret = 'client_secret';
const String kComment = 'comment_kind';
const String kDefaultAccessToken =
    r'https://www.reddit.com/api/v1/access_token';
const String kDefaultAuthorizeUrl = r'https://reddit.com/api/v1/authorize';
const String kDefaultOAuthUrl = r'oauth.reddit.com';
const String kDefaultRedditUrl = 'https://www.reddit.com';
const String kDefaultRevokeToken =
    r'https://www.reddit.com/api/v1/revoke_token';
const String kDefaultShortUrl = 'https://redd.it';
const String kFileName = 'draw.ini';
const String kHttpProxy = 'http_proxy';
const String kHttpsProxy = 'https_proxy';
const String kKind = 'kind';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kMacEnvVar = 'HOME';
const String kMessage = 'message_kind';
const String kOauthUrl = 'oauth_url';
const String kOptionalField = 'optional_field';
const String kOptionalWithDefaultValues = 'optional_with_default';
const String kPassword = 'password';
const String kRedditUrl = 'reddit_url';
const String kRedditor = 'redditor_kind';
const String kRedirectUrl = 'redirect_uri';
const String kRefreshToken = 'refresh_token';
const String kRequiredField = 'required_field';
const String kRevokeToken = 'revoke_token';
const String kShortUrl = 'short_url';
const String kSubmission = 'submission_kind';
const String kSubreddit = 'subreddit_kind';
const String kUserAgent = 'user_agent';
const String kUsername = 'username';
const String kWindowsEnvVar = 'APPDATA';

final kNotSet = null;

/// The [DRAWConfigContext] class provides an interface to store.
/// Load the DRAW's configuration file draw.ini.
class DRAWConfigContext {
  /// The default Object Mapping key for [Comment].
  static const String kCommentKind = 't1';

  /// The default Object Mapping key for [Message].
  static const String kMessageKind = 't4';

  /// The default Object Mapping key for [Redditor].
  static const String kRedditorKind = 't2';

  /// The default Object Mapping key for [Submission].
  static const String kSubmissionKind = 't3';

  /// The default Object Mapping key for [Subreddit].
  static const String kSubredditKind = 't5';

  static const Map<String, List<String>> fieldMap = const {
    kShortUrl: const [kShortUrl],
    kCheckForUpdates: const [kCheckForUpdates],
    kKind: const [kComment, kMessage, kRedditor, kSubmission, kSubreddit],
    kOptionalField: const [
      kClientId,
      kClientSecret,
      kHttpProxy,
      kHttpsProxy,
      kRedirectUrl,
      kRefreshToken,
      kPassword,
      kUserAgent,
      kUsername,
    ],
    kOptionalWithDefaultValues: const [
      kAuthorize,
      kAccessToken,
      kRevokeToken,
    ],
    kRequiredField: const [kOauthUrl, kRedditUrl]
  };

  /// Path to Local, User, Global Configuration Files, with matching precedence.
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> _kind;

  bool checkForUpdates;

  String _accessToken;
  String _authorizeUrl;
  String _clientId;
  String _clientSecret;
  String _httpProxy;
  String _httpsProxy;
  String _oauthUrl;
  String _password;
  String _primarySiteName;
  String _redditUrl;
  String _redirectUrl;
  String _refreshToken;
  String _revokeToken;
  String _shortURL;
  String _userAgent;
  String _username;

  String get accessToken => _accessToken;
  String get authorizeUrl => _authorizeUrl;
  String get clientId => _clientId;
  String get clientSecret => _clientSecret;
  String get commentKind => _kind[kComment] ?? kCommentKind;
  String get httpProxy => _httpProxy;
  String get httpsProxy => _httpsProxy;
  String get messageKind => _kind[kMessage] ?? kMessage;
  String get oauthUrl => _oauthUrl;
  String get password => _password;
  String get redditUrl => _redditUrl;
  String get redditorKind => _kind[kRedditor] ?? kRedditor;
  String get redirectUrl => _redirectUrl;
  String get refreshToken => _refreshToken;
  String get revokeToken => _revokeToken;
  String get submissionKind => _kind[kSubmission] ?? kSubmissionKind;
  String get subredditKind => _kind[kSubreddit] ?? kSubredditKind;
  String get userAgent => _userAgent;
  String get username => _username;

  //Note this accessor throws if _shortURL is not set.
  String get shortUrl {
    if (_shortURL == kNotSet) {
      throw new DRAWClientError('No short domain specified');
    }
    return _shortURL;
  }

  /// Creates a new [DRAWConfigContext] instance.
  ///
  /// [siteName] is the site name associated with the section of the ini file
  /// that would like to be used to load additional configuration information.
  /// The default behaviour is to map to the section [default].
  ///
  /// [_userAgent] is an arbitrary identifier used by the Reddit API to differentiate
  /// between client instances. Should be unique for example related to [siteName].
  ///
  DRAWConfigContext({
    String clientId,
    String clientSecret,
    String userAgent,
    String username,
    String password,
    String redirectUrl,
    String accessToken,
    String authorizeUrl,
    String siteName = 'default',
  }) {
    // Give passed in values highest precedence for assignment.
    _primarySiteName = siteName;
    _clientId = clientId ?? kNotSet;
    _clientSecret = clientSecret ?? kNotSet;
    _username = username ?? kNotSet;
    _password = password ?? kNotSet;
    _redirectUrl = redirectUrl ?? kNotSet;
    // _accessToken = accessToken ?? kNotSet;
    // _authorizeUrl = authorizeUrl ?? kNotSet;
    _accessToken = kDefaultAccessToken;
    _authorizeUrl = kDefaultAuthorizeUrl;
    _userAgent = userAgent ?? kNotSet;

    return;
    // Initialize Paths.
    _localConfigPath = _getLocalConfigPath();
    _userConfigPath = _getUserConfigPath();
    _globalConfigPath = _getGlobalConfigPath();
    // Load the first file found in order of path preference.
    final primaryFile = _loadCorrectFile();
    try {
      _customConfig = new Config.fromStrings(primaryFile.readAsLinesSync());
    } catch (exception) {
      throw new DRAWClientError('Could not parse configuration file.');
    }
    // Load values found in the ini file, into the object fields.
    fieldMap.forEach((key, value) => _fieldInitializer(key, value));
  }

  /// Loads file from [_localConfigPath] or [_userConfigPath] or [_globalConfigPath].
  File _loadCorrectFile() {
    // Check if file exists locally.
    var primaryFile = new File(_localConfigPath.toString());
    if (primaryFile.existsSync()) {
      return primaryFile;
    }
    // Check if file exists in user directory.
    primaryFile = new File(_userConfigPath.toString());
    if (primaryFile.existsSync()) {
      return primaryFile;
    }
    // Check if file exists in global directory.
    primaryFile = new File(_globalConfigPath.toString());
    if (primaryFile.existsSync()) {
      return primaryFile;
    }
    throw new DRAWClientError('$kFileName, does not exist');
  }

  /// Take in the [type] which reflects the key in the [fieldMap]
  /// [params] is the list of values found in [kFileName] file.
  void _fieldInitializer(type, params) {
    params.forEach((value) => _initializeField(type, value));
  }

  /// Initialize the attributes of the configuration object using the ini file.
  void _initializeField(String type, String param) {
    if (type == kShortUrl) {
      _shortURL = _fetchDefault('short_url') ?? kDefaultShortUrl;
    } else if (type == kCheckForUpdates) {
      checkForUpdates = _configBool(_fetchOrNotSet('check_for_updates'));
    } else if (type == kKind) {
      final value = _fetchOrNotSet(param);
      if (value != null) {
        _kind[param] = value;
      }
    } else if (type == kOptionalField) {
      final value = _fetchOrNotSet(param);
      if (value != null) {
        switch (param) {
          case kClientId:
            _clientId = value;
            break;
          case kClientSecret:
            _clientSecret = value;
            break;
          case kHttpProxy:
            _httpProxy = value;
            break;
          case kHttpsProxy:
            _httpsProxy = value;
            break;
          case kRedirectUrl:
            _redirectUrl = value;
            break;
          case kRefreshToken:
            _refreshToken = value;
            break;
          case kPassword:
            _password = value;
            break;
          case kUserAgent:
            //Null aware operator is here to give precedence to passed in values.
            _userAgent ??= value;
            break;
          case kUsername:
            _username = value;
            break;
          default:
            throw new DRAWInternalError(
                'Parameter $param does not exist in the fieldMap for $type');
            break;
        }
      }
    } else if (type == kOptionalWithDefaultValues) {
      final value = _fetchOrNotSet(param);
      switch (param) {
        case kAccessToken:
          _accessToken = value ?? kDefaultAccessToken;
          break;
        case kAuthorize:
          _authorizeUrl = value ?? kDefaultAuthorizeUrl;
          break;
        case kRevokeToken:
          _revokeToken = value ?? kDefaultRevokeToken;
          break;
        default:
          throw new DRAWInternalError(
              'Parameter $param does not exist in the fieldMap for $type');
          break;
      }
    } else if (type == kRequiredField) {
      final value = _fetchOrNotSet(param);
      switch (param) {
        case kOauthUrl:
          _oauthUrl = value ?? kDefaultOAuthUrl;
          break;
        case kRedditUrl:
          _redditUrl = value ?? kDefaultRedditUrl;
          break;
        default:
          throw new DRAWInternalError(
              'Parameter $param does not exist in the fieldMap for $type');
          break;
      }
    }
  }

  /// Safely return the truth value associated with [item].
  bool _configBool(final item) {
    if (item is bool) {
      return item;
    } else {
      final trueValues = ['1', 'yes', 'true', 'on'];
      return trueValues.contains(item?.toLowerCase());
    }
  }

  /// Fetch the value under the default site section in the ini file.
  String _fetchDefault(String key) {
    return _customConfig.get('default', key);
  }

  String _fetchOptional(String key) {
    return _customConfig.get(_primarySiteName, key);
  }

  /// Checks if [key] is contained in the parsed ini file, if not returns [kNotSet].
  ///
  /// [key] is the key to be searched in the draw.ini file.
  String _fetchOrNotSet(final key) =>
      (_fetchOptional(key) ?? _fetchDefault(key) ?? kNotSet);

  /// Returns path to user level configuration file.
  Uri _getUserConfigPath() {
    final environment = Platform.environment;
    String osConfigPath;
    // Load correct path for user level configuration paths based on operating system.
    if (Platform.isMacOS) {
      osConfigPath = path.join(environment[kMacEnvVar], '.config');
    } else if (Platform.isLinux) {
      osConfigPath = environment[kLinuxEnvVar];
    } else if (Platform.isWindows) {
      osConfigPath = environment[kWindowsEnvVar];
    } else {
      throw new DRAWInternalError('OS not Recognized by DRAW');
    }
    return Uri.parse(path.join(osConfigPath, kFileName));
  }

  /// Returns path to global configuration file.
  Uri _getGlobalConfigPath() {
    final path.Context context = new path.Context();
    final cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  /// Returns path to local configuration file.
  Uri _getLocalConfigPath() {
    final path.Context context = new path.Context();
    final cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }
}
