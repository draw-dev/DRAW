// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

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
  //Path to Local, User, Global Config Files, with matching precedence
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Config _customConfig;

  Map<String, String> custom;

  String _shortURL;
  String clientId;
  String redditURL;
  String password;

  DrawConfigContext() {
    //Get file paths
    this._localConfigPath = this._getLocalConfigPath();
    this._userConfigPath = this._getUserConfigPath();
    this._globalConfigPath = this._getGlobalConfigPath();

    //Check for file existence
    File primaryFile = new File(this._localConfigPath.toString());

    if (primaryFile.exists() == false) {
      primaryFile = new File(this._userConfigPath.toString());
    }
    if (primaryFile.exists() == false) {
      primaryFile = new File(this._globalConfigPath.toString());
    }

    //Parse file
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

    //TODO: Load settings into master data-structure Settings
    //TODO: Load main file into configFile
    //this._config = new Config.fromStrings(this.configFile.readAsLinesSync());
  }

  String _fetch_default(string key) {
    return this._customConfig[key];
  }

  void _initializeAttributes() {
    this._shortUrl = this._fetch_default('short_url');
    this._oauthUrl = this._fetch_default('oauth_url');
    this._username = this._fetch_default('client_id');
  }

  //Returns path to user level configuration file
  Uri _getUserConfigPath() {
    final Map<String, String> environ = Platform.environment;

    Uri osConfigPath;
    //Load correct config path based on operating system
    if (Platform.isMacOS) {
      osConfigPath = Uri.parse(path.join(environ[kMacEnvVar], '.config'));
    } else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environ[kLinuxEnvVar]);
    } else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environ[kWindowsEnvVar]);
    }
    return osConfigPath;
  }

  //Returns path to global configuration file
  Uri _getGlobalConfigPath() {
    final path.Context context = new path.Context();
    final String cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  //Returns path to local Configuration file
  Uri _getLocalConfigPath() {
    return Uri.parse(kFileName);
  }

  //TODO: Kartik implment (kc3454)
  String shortURL() {
    return this._shortURL;
  }
}
