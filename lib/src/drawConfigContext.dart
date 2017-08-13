/// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import './exceptions.dart';

const String kFileName = 'praw.ini';
const String kMacEnvVar = 'HOME';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kWindowsEnvVar = 'APPDATA';

final kNotSet = null;

///The [DrawConfigContext] class provides an iterface to store and load
///the DRAW's configuration file [praw.ini].
class DrawConfigContext {
  ///Path to Local, User, Global Config Files, with matching precedence
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String _primarySiteName;

  //Required fields for basic configuration
  bool checkForUpdates;
  String userAgent;

  //Fields for Oauth workflow and configuration
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

  get redirectUri => Uri.parse(_redirectUri);

  //Note this Accesor throws if _shortURL is not set
  get shortURL {
    if (_shortURL == kNotSet) {
      throw new DRAWClientException("No short domain specified");
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
  /// between client instances. Should be unqiue for example related to [sitenam].
  ///
  /// TODO: add ability to pass in additional prams directly
  DrawConfigContext({String siteName = "default", String userAgent}) {
    //Conigure custom fields if applicable
    _primarySiteName = siteName;
    this.userAgent = userAgent ?? kNotSet;

    ///Get file paths
    _localConfigPath = _getLocalConfigPath();
    _userConfigPath = _getUserConfigPath();
    _globalConfigPath = _getGlobalConfigPath();

    ///Check for file existence
    File primaryFile = new File(this._localConfigPath.toString());
    if (primaryFile.exists() == false) {
      primaryFile = new File(this._userConfigPath.toString());
    }
    if (primaryFile.exists() == false) {
      primaryFile = new File(this._globalConfigPath.toString());
    }

    ///Parse file
    primaryFile
        .readAsLines()
        .then((lines) => new Config.fromStrings(lines))
        .then((Config config) {
          this._customConfig = config;
        })
        .catchError((e) {
          print("Placeholder for error while reading/parsing file");
          print(e);
        })
        .then((_) => this._initializeAttributes())
        .catchError((e) {
          print("Placeholder for catching error while initializing");
          print(e);
        });
  }

  //Initialize the attributes of the configuration object using the ini file
  void _initializeAttributes() {
    _shortURL = _fetchDefault('short_url');
    checkForUpdates = _configBool(_fetchDefault('check_for_updates'));

    oauthUrl = _fetch('oauth_url');
    redditUrl = _fetch('reddit_url');

    ///The use of null aware operators here is to give highest precedence to
    ///passed in values to the constructor.
    clientId ??= _fetchOrNotSet('client_id');
    clientSecret ??= _fetchOrNotSet('client_secret');
    httpProxy ??= _fetchOrNotSet('http_proxy');
    httpsProxy ??= _fetchOrNotSet('https_proxy');
    _redirectUri ??= _fetchOrNotSet('redirect_uri');
    refreshToken ??= _fetchOrNotSet('refresh_token');
    password ??= _fetchOrNotSet('password');
    userAgent ??= _fetchOrNotSet('user_agent');
    username ??= _fetchOrNotSet('username');
  }

  ///Safely return the truth value associated with [item].
  bool _configBool(var item) {
    if (item is bool) {
      return item;
    } else {
      final trueValues = ['1', 'yes', 'true', 'on'];
      return trueValues.contains(item.toLowerCase());
    }
  }

  ///Fetch the value under the default site section in the ini file
  String _fetchDefault(String key) {
    return this._customConfig.get("default", key);
  }

  ///Fetch value based on the [_primarySiteName] in the ini file.
  String _fetch(String key) {
    String value =
        _customConfig.get(_primarySiteName, key) ?? _fetchDefault(key);
    return value;
  }

  ///
  String _fetchOrNotSet(String key) {
    //TODO:Check in env variables
    String iniValue = _fetchDefault(key);
    return iniValue ?? kNotSet;
  }

  ///Returns path to user level configuration file
  Uri _getUserConfigPath() {
    final Map<String, String> environ = Platform.environment;

    Uri osConfigPath;

    ///Load correct config path based on operating system
    if (Platform.isMacOS) {
      osConfigPath = Uri.parse(path.join(environ[kMacEnvVar], '.config'));
    } else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environ[kLinuxEnvVar]);
    } else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environ[kWindowsEnvVar]);
    }
    return osConfigPath;
  }

  ///Returns path to global configuration file
  Uri _getGlobalConfigPath() {
    final path.Context context = new path.Context();
    final cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  ///Returns path to local Configuration file
  Uri _getLocalConfigPath() {
    return Uri.parse(kFileName);
  }
}
