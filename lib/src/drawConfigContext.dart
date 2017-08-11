/// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;
import 'dart:async';

import './exceptions.dart';

const String kFileName = 'praw.ini';
const String kMacEnvVar = 'HOME';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kWindowsEnvVar = 'APPDATA';

final kNotSet = null;

class DrawConfigContext {
  ///Path to Local, User, Global Config Files, with matching precedence
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String _primarySiteName;
  String _redirectUri;

  bool checkForUpdates;

  String clientId;
  String clientSecret;
  String oauthUrl;
  String redditUrl;
  String userAgent;
  String username;
  String password;
  String refreshToken;
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

  DrawConfigContext([String siteName = "default"]) {
    _primarySiteName = siteName;

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

    ///TODO: Load settings into master data-structure Settings
    ///TODO: Load main file into configFile
    ///this._config = new Config.fromStrings(this.configFile.readAsLinesSync());
  }

  void _initializeAttributes() {
    ///Fetch Default
    _shortURL = _fetchDefault('short_url');
    checkForUpdates = _configBool(_fetchDefault('check_for_updates'));

    ///Fetch
    oauthUrl = _fetch('oauth_url');
    redditUrl = _fetch('reddit_url');

    ///Fetch_or_not_set_
    clientId = _fetchOrNotSet('client_id');
    clientSecret = _fetchOrNotSet('client_secret');
    httpProxy = _fetchOrNotSet('http_proxy');
    httpsProxy = _fetchOrNotSet('https_proxy');
    _redirectUri = _fetchOrNotSet('redirect_uri');
    refreshToken = _fetchOrNotSet('refresh_token');
    password = _fetchOrNotSet('password');
    userAgent = _fetchOrNotSet('user_agent');
    username = _fetchOrNotSet('username');
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

  String _fetchDefault(String key) {
    return this._customConfig.get("default", key);
  }

  String _fetch(String key) {
    String value =
        _customConfig.get(_primarySiteName, key) ?? _fetchDefault(key);
    return value;
  }

  String _fetchOrNotSet(String key) {
    //TODO: Check if key is part of passed in settings and return it
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
