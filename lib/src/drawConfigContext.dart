/// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';

import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import './exceptions.dart';

const String kFileName = 'draw.ini';
const String kMacEnvVar = 'HOME';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kWindowsEnvVar = 'APPDATA';

//fieldMapConstants
const String kShortUrl = 'short_url';
const String kCheckForUpdates = 'check_for_updates';
const String kKind = 'kind';
const String kOptionalField = 'optional_field';
const String kRequiredField = 'required_field';

const String kComment = 'comment';
const String kMessage = 'message';
const String kRedditor = 'redditor';
const String kSubmission = 'submission';
const String kSubReddit = 'subreddit';
const String kClientId = 'client_id ';
const String kClientSecret = 'child_secret ';
const String kHttpProxy = 'http_proxy ';
const String kHttpsProxy = 'https_proxy ';
const String kRedirectUri = 'redirect_uri ';
const String kRefreshToken = 'refresh_token ';
const String kPassword = 'password ';
const String kUserAgent = 'user_agent ';
const String kUsername = 'username ';

final kNotSet = null;

/// The [DrawConfigContext] class provides an iterface to store.
/// Load the DRAW's configuration file [draw.ini].
class DrawConfigContext {
  static Map<String, String> fieldMap = {
    kShortUrl: [kShortUrl],
    kCheckForUpdates: [kCheckForUpdates],
    kKind: [kComment, kMessage, kRedditor, kSubmission, kSubReddit],
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
    kRequiredField: ['oauth_url', 'reddit_url']
  };

  /// Path to Local, User, Global Config Files, with matching precedence.
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String _primarySiteName;

  //Required fields for basic configuration.
  bool checkForUpdates;
  String userAgent;

  //Fields for Oauth workflow and configuration.
  String _redirectUri;
  String clientId;
  String clientSecret;
  String refreshToken;
  String username;
  String password;

  String oauthUrl;
  String redditUrl;
  String redditURL;
  String httpProxy;
  String httpsProxy;

  Uri get redirectUri => Uri.parse(_redirectUri);

  //Note this Accesor throws if _shortURL is not set.
  String get shortURL {
    if (_shortURL == kNotSet) {
      throw new DRAWClientException('No short domain specified');
    }
    return _shortURL;
  }

  /// Creates a new [DrawConfigContext] instance.
  ///
  /// [siteName] is the site name associated with the section of the ini file
  /// that would like to be used to load additional configuration information.
  /// The default behaviour is to map to the section [default].
  ///
  /// [userAgent] is an arbitrary identifier used by the Reddit API to diffrentiate
  /// between client instances. Should be unqiue for example related to [siteName].
  ///
  /// TODO(kc3454): add ability to pass in additional prams directly.
  DrawConfigContext({String siteName = 'default', String userAgent}) {
    //Conigure custom fields if applicable.
    _primarySiteName = siteName;
    this.userAgent = userAgent ?? kNotSet;
    _initializeFilePaths();
    var primaryFile = _loadCorrectFile();
    //Parse the ini file.
    _customConfig = new Config.fromStrings(primaryFile.readAsLinesSync());
    fieldMap.forEach((key, value) => _fieldInitializer(key, value));
  }

  ///Retrive filePaths and load into private members.
  void _initializeFilePaths() {
    _localConfigPath = _getLocalConfigPath();
    _userConfigPath = _getUserConfigPath();
    _globalConfigPath = _getGlobalConfigPath();
  }

  bool _checkForExistance(File primaryFile) {
    bool fileLoaded;
    Future fileExistance = primaryFile.exists();
    fileExistance.then((bool fileExists) => fileLoaded = fileExists);
    return fileLoaded;
  }

  ///Loads file from [_localConfigPath] or [_userConfigPath] or [_globalConfigPath].
  File _loadCorrectFile() {
    //Check if file exists locally.
    var primaryFile = new File(this._localConfigPath.toString());
    if (_checkForExistance(primaryFile)) {
      return primaryFile;
    }
    //Check if File exists in user directory
    primaryFile = new File(this._userConfigPath.toString());
    if (_checkForExistance(primaryFile)) {
      return primaryFile;
    }
    //Check if File Exists in Global Directory
    primaryFile = new File(this._globalConfigPath.toString());
    if (_checkForExistance(primaryFile)) {
      return primaryFile;
    }
    throw new DRAWClientException('$kFileName, does not exist');
  }

  void _fieldInitializer(type, params) {
    params.forEach((value) => _initializeField(type, value));
  }

  /// Initialize the attributes of the configuration object using the ini file.
  void _initializeField(String type, String param) {
    if (type == kShortUrl) {
      _shortURL = _fetchDefault('short_url');
    } else if (type == kCheckForUpdates) {
      checkForUpdates = _configBool(_fetchDefault('check_for_updates'));
    } else if (type == kKind) {
      //TODO(kc3454): Learn how to do this one.
    } else if (type == kOptionalField) {
      String value = _fetchOrNotSet(param);
      if (value != null) {
        switch (param) {
          case kClientId:
            clientId = value;
            break;
          case kClientSecret:
            clientSecret = value;
            break;
          case kHttpProxy:
            httpProxy = value;
            break;
          case kHttpsProxy:
            httpsProxy = value;
            break;
          case kRedirectUri:
            _redirectUri = value;
            break;
          case kRefreshToken:
            refreshToken = value;
            break;
          case kPassword:
            password = value;
            break;
          case kUserAgent:
            userAgent = value;
            break;
          case kUsername:
            username = value;
            break;
          default:
            throw new DRAWInternalError(
                'Param $param does not exist in the fieldMap for $type');
            break;
        }
      }
    } else if (type == kRequiredField) {
      String value = _fetch(param);
      if (value != null) {
        switch (param) {
          case 'oauth_url':
            oauthUrl = value;
            break;
          case 'reddit_url':
            redditUrl = value;
            break;
          default:
            throw new DRAWInternalError(
                'Param $param does not exist in the fieldMap for $type');
            break;
        }
      }
    }
  }

  /// Safely return the truth value associated with [item].
  bool _configBool(var item) {
    if (item is bool) {
      return item;
    } else {
      final trueValues = ['1', 'yes', 'true', 'on'];
      return trueValues.contains(item.toLowerCase());
    }
  }

  /// Fetch the value under the default site section in the ini file
  String _fetchDefault(String key) {
    return this._customConfig.get('default', key);
  }

  /// Fetch value based on the [_primarySiteName] in the ini file.
  String _fetch(String key) =>
      (_customConfig.get(_primarySiteName, key) ?? _fetchDefault(key));

  /// Checks if [key] is contained in the parsed ini file, if not returns [kNotSet].
  ///
  /// [key] is the key to be searched in the draw.ini file.
  String _fetchOrNotSet(String key) => (_fetchDefault(key) ?? kNotSet);

  /// Returns path to user level configuration file
  Uri _getUserConfigPath() {
    final environment = Platform.environment;

    var osConfigPath;

    /// Load correct config path based on operating system
    if (Platform.isMacOS) {
      osConfigPath = Uri.parse(path.join(environment[kMacEnvVar], '.config'));
    } else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environment[kLinuxEnvVar]);
    } else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environment[kWindowsEnvVar]);
    }
    return osConfigPath;
  }

  /// Returns path to global configuration file
  Uri _getGlobalConfigPath() {
    final path.Context context = new path.Context();
    final cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  /// Returns path to local Configuration file
  Uri _getLocalConfigPath() {
    return Uri.parse(kFileName);
  }
}
