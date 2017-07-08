// Copyright (c) 2017, krishchopra. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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

  //Path to user level configuration file
  Uri _osConfigPath;

  Config _config;

  DrawConfigContext(){
    this._osConfigPath = _getConfigPath();
    List<Uri> locations = _getLocations();
    this._config = new Config.fromStrings(this.configFile.readAsLinesSync());
  }

  Map<String, String> settings;

  String _shortURL;
  String clientId;
  String redditURL;
  String password;

  //Returns Config location based on OS Enviroment
  Uri _getConfigPath(){
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

  //Returns list of URI potential locations of
  List<Uri> _getLocations(){

    path.Context context = new path.Context();
    String cwd = context.current;

    List<Uri> locations = [Uri.parse(path.join(cwd, kFileName)), Uri.parse(kFileName)];

    if(this._osConfigPath != null) {
      locations.add(Uri.parse(path.join(this._osConfigPath.path, kFileName)));
    }

    //TODO: Remove
    return locations;
  }

  String shortURL(){
    //TODO: Kartik implment (kc3454)
    return this._shortURL;
  }

}

