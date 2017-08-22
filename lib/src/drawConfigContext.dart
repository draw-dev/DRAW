/// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';

import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import 'exceptions.dart';

const String kCheckForUpdates = 'check_for_updates';
const String kClientId = 'client_id ';
const String kClientSecret = 'child_secret ';
const String kComment = 'comment';
const String kDefaultShortUrl = 'https://redd.it';
const String kFileName = 'draw.ini';
const String kHttpProxy = 'http_proxy ';
const String kHttpsProxy = 'https_proxy ';
const String kKind = 'kind';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kMacEnvVar = 'HOME';
const String kMessage = 'message';
const String kOauthUrl = 'oauth_url';
const String kOptionalField = 'optional_field';
const String kPassword = '_password ';
const String kRedditUrl = 'reddit_url';
const String kRedditor = 'redditor';
const String kRedirectUri = 'redirect_uri ';
const String kRefreshToken = 'refresh_token ';
const String kRequiredField = 'required_field';
const String kShortUrl = 'short_url';
const String kSubreddit = 'subreddit';
const String kSubmission = 'submission';
const String kUserAgent = 'user_agent ';
const String kUsername = '_username ';
const String kWindowsEnvVar = 'APPDATA';

final kNotSet = null;

/// The [DRAWConfigContext] class provides an interface to store.
/// Load the DRAW's configuration file draw.ini.
class DRAWConfigContext {
  static final Map<String, List<String>> fieldMap = {
    kShortUrl: [kShortUrl],
    kCheckForUpdates: [kCheckForUpdates],
    kKind: [kComment, kMessage, kRedditor, kSubmission, kSubreddit],
    kOptionalField: [
      kClientId,
      kClientSecret,
      kHttpProxy,
      kHttpsProxy,
      kRedirectUri,
      kRefreshToken,
      kPassword,
      kUserAgent,
      kUsername,
    ],
    kRequiredField: [kOauthUrl, kRedditUrl]
  };

  /// Path to Local, User, Global Config Files, with matching precedence.
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String _primarySiteName;

  bool checkForUpdates;
  String _userAgent;

  String _redirectUri;
  String _clientId;
  String _clientSecret;
  String _refreshToken;
  String _username;
  String _password;

  String _oauthUrl;
  String _redditUrl;
  String _httpProxy;
  String _httpsProxy;


  String get userAgent => _userAgent;
  String get clientId => _clientId;
  String get clientSecret => _clientSecret;
  String get redirectUri => _redirectUri;
  String get refreshToken => _refreshToken;
  String get username => _username;
  String get password => _password;
  String get oauthUrl => _oauthUrl;
  String get redditUrl => _redditUrl;
  String get httpProxy => _httpProxy;
  String get httpsProxy => _httpsProxy;

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
  /// TODO(kc3454): add ability to pass in additional prams directly.
  DRAWConfigContext({String siteName = 'default', String userAgent}) {
    // Give passed in values highest precedence for assignment.
    _primarySiteName = siteName;
    this._userAgent = userAgent ?? kNotSet;
    // Initialize Paths.
    _localConfigPath = _getLocalConfigPath();
    _userConfigPath = _getUserConfigPath();
    _globalConfigPath = _getGlobalConfigPath();
    // Load the first file found in order of path preference.
    final primaryFile = _loadCorrectFile();
    try{
        _customConfig = new Config.fromStrings(primaryFile.readAsLinesSync());
    } catch(exception, stackTrace){
        throw new DRAWClientError('There was an issue parsing the draw.ini file.');
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
      checkForUpdates = _configBool(_fetchDefault('check_for_updates'));
    } else if (type == kKind) {
      // TODO(kc3454): Learn how to do this one.
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
          case kRedirectUri:
            _redirectUri = value;
            break;
          case kRefreshToken:
            _refreshToken = value;
            break;
          case kPassword:
            _password = value;
            break;
          case kUserAgent:
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
    } else if (type == kRequiredField) {
      final value = _fetch(param);
      if (value != null) {
        switch (param) {
          case kOauthUrl:
            _oauthUrl = value;
            break;
          case kRedditUrl:
            _redditUrl = value;
            break;
          default:
            throw new DRAWInternalError(
                'Parameter $param does not exist in the fieldMap for $type');
            break;
        }
      } else {
        throw new DRAWClientError(
            'The required field $param, was not found in $kFileName');
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

  /// Fetch value based on the [_primarySiteName] in the ini file.
  String _fetch(String key) =>
      (_customConfig.get(_primarySiteName, key) ?? _fetchDefault(key));

  /// Checks if [key] is contained in the parsed ini file, if not returns [kNotSet].
  ///
  /// [key] is the key to be searched in the draw.ini file.
  String _fetchOrNotSet(final key) => (_fetchDefault(key) ?? kNotSet);

  /// Returns path to user level configuration file.
  Uri _getUserConfigPath() {
    final environment = Platform.environment;

    var osConfigPath;

    /// Load correct path for user level configuration paths  based on operating system.
    if (Platform.isMacOS) {
      osConfigPath = Uri.parse(path.join(environment[kMacEnvVar], '.config'));
    } else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environment[kLinuxEnvVar]);
    } else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environment[kWindowsEnvVar]);
    } else {
      throw new DRAWInternalError('OS not Recognized by DRAW');
    }
    return osConfigPath;
  }

  /// Returns path to global configuration file.
  Uri _getGlobalConfigPath() {
    final path.Context context = new path.Context();
    final cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  /// Returns path to local configuration file.
  Uri _getLocalConfigPath() {
    return Uri.parse(kFileName);
  }
}
