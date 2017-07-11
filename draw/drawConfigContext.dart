// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import '../lib/src/exceptions.dart';

const String kFileName = 'praw.ini';
const String kMacEnvVar = 'HOME';
const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kWindowsEnvVar = 'APPDATA';

class DrawConfigContext{

  File configFile;

  Config _config;

  //Path to Local, User, Global Config Files, with matching precedence
  Uri _localConfigPath;
  Uri _userConfigPath;
  Uri _globalConfigPath;

  Map<String, String> settings;

  String _shortURL;
  String clientId;
  String redditURL;
  String password;

  DrawConfigContext(){
    //Get file paths
    this._localConfigPath = this._getLocalConfigPath();
    this._userConfigPath = this._getUserConfigPath();
    this._globalConfigPath = this._getGlobalConfigPath();

    //TODO: check weather these files exist
    //TODO: Load settings into master data-structure Settings
    this._config = new Config.fromStrings(this.configFile.readAsLinesSync());
  }

  //Returns path user level configuration file
  Uri _getUserConfigPath(){
    Map<String, String> environ = Platform.environment;

    Uri osConfigPath = null;
    //Load correct config path based on operating system
    if (Platform.isMacOS) {
      osConfigPath = Uri.parse(path.join(environ[kMacEnvVar], '.config'));
    }
    else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environ[kLinuxEnvVar]);
    }
    else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environ[kWindowsEnvVar]);
    }
    return osConfigPath;
  }
w
  //Returns path to global configuration file
  Uri _getGlobalConfigPath(){
    path.Context context = new path.Context();
    String cwd = context.current;
    return Uri.parse(path.join(cwd, kFileName));
  }

  //Returns path to local Configuration file
  Uri _getLocalConfigPath(){
    return Uri.parse(kFileName);
  }

  //TODO: Kartik implment (kc3454)
  String shortURL(){
    return this._shortURL;
  }

}

