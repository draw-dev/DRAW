/// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io' as io;

class Platform {
  static bool get isAndroid => io.Platform.isAndroid;
  static bool get isFuchsia => io.Platform.isFuchsia;
  static bool get isIOS => io.Platform.isIOS;
  static bool get isLinux => io.Platform.isLinux;
  static bool get isMacOS => io.Platform.isMacOS;
}
