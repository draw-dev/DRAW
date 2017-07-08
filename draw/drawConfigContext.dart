// Copyright (c) 2017, krishchopra. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import '../lib/src/exceptions.dart';

class DrawConfigContext{

  static final fileName = 'praw.ini';
  static final macEnvVar = 'HOME';
  static final linuxEnvVar = 'XDG_CONFIG_HOME';
  static final windowsEnvVar = 'APPDATA';

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
      osConfigPath = Uri.parse(path.join(environ[macEnvVar], '.config'));
    }
    else if (Platform.isLinux) {
      osConfigPath = Uri.parse(environ[linuxEnvVar]);
    }
    else if (Platform.isWindows) {
      osConfigPath = Uri.parse(environ[windowsEnvVar]);
    }
    return osConfigPath;
  }

  //Returns list of URI potential locations of
  List<Uri> _getLocations(){

    path.Context context = new path.Context();
    String cwd = context.current;

    List<Uri> locations = [Uri.parse(path.join(cwd, fileName)), Uri.parse(fileName)];

    if(this._osConfigPath != null) {
      locations.add(Uri.parse(path.join(this._osConfigPath.path, fileName)));
    }

    //TODO: Remove
    return locations;
  }

  void shortURL(){
    //TODO: Kartik implment (kc3454)

  }

}

