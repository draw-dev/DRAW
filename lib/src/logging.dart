// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:convert';

import 'package:logging/logging.dart';
export 'package:logging/logging.dart' show Level, Logger;

const JsonEncoder e = const JsonEncoder.withIndent('  ');

abstract class DRAWLoggingUtils {
  static void initialize() {
    Logger.root.level = Level.OFF;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name} (${rec.loggerName}): ${rec.message}');
    });
  }

  static void setLogLevel(Level l) => Logger.root.level = l;

  static String jsonify(jObj) => e.convert(jObj);
}
