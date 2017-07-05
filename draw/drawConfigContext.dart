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

    //Load correct config path based on operating system
    if (Platform.isMacOS) {
       osConfigPath = Uri.parse(path.join(environ['HOME'], '.config'));
    }
    else if (Platform.isLinux) {
       osConfigPath = Uri.parse(environ['XDG_CONFIG_HOME']);
    }
    else if (Platform.isWindows) {
       osConfigPath = Uri.parse(environ['APPDATA']);
    }

    var context = new path.Context;
    String cwd = context.current;

    List<Uri> locations = [Uri.parse(path.join(cwd, 'praw.ini')), Uri.parse('praw.ini')];

    if(osConfigPath != null) {
      locations.add(Uri.parse(path.join(osConfigPath, 'praw.ini')));
    }

    var it = locations.iterator;
    List<File> iniFiles;
    while(it.moveNext()){
        iniFiles.add(new File(Uri.parse(it.current)));
    }

    //File file = new File(locations); TODO (k5chopra): Implement a list of files for each praw.ini location

    throw new UnimplementedError();
  }

  void shortURL(){
    //TODO: Kartik implment (kc3454)
  }

}