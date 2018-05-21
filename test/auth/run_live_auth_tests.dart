// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'credentials.dart';
import 'read_only.dart' as readOnly;
import 'script_auth.dart' as script;

void main() {
  if (isScriptAuthConfigured) {
    script.main();
    readOnly.main();
  }
}
