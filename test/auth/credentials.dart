// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:io';

final kScriptClientID = Platform.environment['SCRIPT_CLIENT_ID'];
final kScriptClientSecret = Platform.environment['SCRIPT_CLIENT_SECRET'];
final kWebClientID = Platform.environment['WEB_CLIENT_ID'];
final kWebClientSecret = Platform.environment['WEB_CLIENT_SECRET'];
const kUsername = 'DRAWApiOfficial';
final kPassword = Platform.environment['PASSWORD'];

bool isScriptAuthConfigured =
    (kScriptClientID != null) && (kScriptClientSecret != null);

bool isWebAuthConfigured = (kWebClientID != null) && (kWebClientSecret != null);
