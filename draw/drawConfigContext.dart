// Copyright (c) 2017, krishchopra. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as path;

import '../lib/src/exceptions.dart';

class DrawConfigContext{

  DrawConfigContext();

  Map<String, String> customDataStructure;

  String _shortURL;
  String settings;
  String clientId;
  String redditURL;
  String password;

  //Load Config File
  void _loadConfig(){
    Uri currURI = Platform.script;
    Uri path = Uri.parse(currURI.toFilePath());

    Map<String, String> environ = Platform.environment;
    Uri osConfigPath = null;

    if (Platform.isMacOS) {
       osConfigPath = Uri.parse(path.join(environ['HOME'], '.config'));
    }
    else if (Platform.isLinux) {
       osConfigPath = Uri.parse(environ['XDG_CONFIG_HOME']);
    }
    else if (Platform.isWindows) {
       osConfigPath = Uri.parse(environ['APPDATA']);
    }
    String cwd = path.current;
    List<Uri> locations = [Uri.parse(path.current)]

    File file = new File();

    throw new UnimplementedError();
  }

  void shortURL(){
    //TODO: Kartik implment (kc3454)
  }

  void longURL()
    //TODO: Kartik implment (kc3454)
  }


}