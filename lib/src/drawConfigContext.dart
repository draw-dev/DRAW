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

class DrawConfigContext {
  ///Path to Local, User, Global Config Files, with matching precedence
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String _clientId;
  String _clientSecret;
  String _oauth_url;
  String _userAgent;
  String _username;
  String _password;
  String _redirectURI;
  String _refreshToken;
  String _redditURL;

  DrawConfigContext() {
    ///Get file paths
    _localConfigPath  = _getLocalConfigPath();
    _userConfigPath   = _getUserConfigPath();
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
    _shortUrl = _fetchDefault('short_url');
    _checkForUpdates = _configBool(_fetchDefault('check_for_updates'));

    ///Fetch
    _oauthUrl = _fetch('oauth_url');
    _redditUrl = _fetch('reddit_url');

    ///Fetch_or_not_set_
    _clientId = _fetchOrNotSet('client_id');
    _clientSecret = _fetchOrNotSet('client_secret');
    _httpProxy = _fetchOrNotSet('http_proxy');
    _httpsProxy = _fetchOrNotSet('https_proxy');
    _redirectUri = _fetchOrNotSet('redirect_uri');
    _refreshToken = _fetchOrNotSet('refresh_token');
    _password = _fetchOrNotSet('password');
    _userAgent = _fetchOrNotSet('user_agent');
    _username = _fetchOrNotSet('username');
  }

  ///Safely return the truth value associated with [item].
  bool _configBool(var item) {
    if (item is bool) {
      return item;
    } else {
      const Set<String> trueValues = ['1', 'yes', 'true', 'on'];
      return trueValues.contains(item);
    }
  }

  String _fetchDefault(String key) {
    return this._customConfig.get("default", key);
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
    final String cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  ///Returns path to local Configuration file
  Uri _getLocalConfigPath() {
    return Uri.parse(kFileName);
  }

  ///TODO: Kartik implment (kc3454)
  String shortURL() {
    return this._shortURL;
  }
}
