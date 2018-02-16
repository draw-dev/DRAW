/// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'package:ini/ini.dart';

import 'config_file_reader.dart';
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
const String kHttpProxy = 'http_proxy';
const String kHttpsProxy = 'https_proxy';
const String kKind = 'kind';
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

  Config _customConfig;

  final Map<String, String> _kind = new Map<String, String>();

  bool _checkForUpdates;

  bool get checkForUpdates => _checkForUpdates ?? false;

  String _accessToken;
  String _authorizeUrl;
  String _clientId;
  String _clientSecret;
  String _configUrl;
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
  String get configUrl => _configUrl;
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
    String configUrl,
    String siteName = 'default',
    var checkForUpdates,
  }) {
    // Give passed in values highest precedence for assignment.
    // TODO(ckartik): Find a more robust way of giving passed in values higher priority.
    // Look in to the possiblity of storing these values in a map and checking against
    // it in the fetchOrNotSet function.
    _primarySiteName = siteName;
    _clientId = clientId;
    _clientSecret = clientSecret;
    _configUrl = configUrl;
    _username = username;
    _password = password;
    _redirectUrl = redirectUrl;
    _accessToken = accessToken;
    _authorizeUrl = authorizeUrl;
    _userAgent = userAgent;
    _checkForUpdates =
        checkForUpdates == null ? null : _configBool(checkForUpdates);

    final configFileReader = new ConfigFileReader(_configUrl);

    // Load the first file found in order of path preference.
    final primaryFile = configFileReader.loadCorrectFile();
    if (primaryFile != null) {
      try {
        _customConfig = new Config.fromStrings(primaryFile.readAsLinesSync());
      } catch (exception) {
        throw new DRAWClientError('Could not parse configuration file.');
      }
    } else {
      _customConfig = new Config();
    }
    // Load values found in the ini file, into the object fields.
    fieldMap.forEach((key, value) => _fieldInitializer(key, value));
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
      _checkForUpdates ??= _configBool(_fetchOrNotSet('check_for_updates'));
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
    } else if (item is String) {
      final trueValues = ['1', 'yes', 'true', 'on'];
      return trueValues.contains(item?.toLowerCase());
    } else {
      return false;
    }
  }

  /// Fetch the value under the default site section in the ini file.
  String _fetchDefault(String key) {
    return _customConfig.get('default', key);
  }

  String _fetchOptional(String key) {
    try {
      return _customConfig.get(_primarySiteName, key);
    } catch (exception) {
      throw new DRAWArgumentError(
          'Invalid paramter value, siteName cannot be null');
    }
  }

  /// Checks if [key] is contained in the parsed ini file, if not returns [kNotSet].
  ///
  /// [key] is the key to be searched in the draw.ini file.
  String _fetchOrNotSet(final key) =>
      (_fetchOptional(key) ?? _fetchDefault(key) ?? kNotSet);
}
