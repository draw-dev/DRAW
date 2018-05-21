// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:io';

final SCRIPT_CLIENT_ID = Platform.environment['SCRIPT_CLIENT_ID'];
final SCRIPT_CLIENT_SECRET = Platform.environment['SCRIPT_CLIENT_SECRET'];
final WEB_CLIENT_ID = Platform.environment['WEB_CLIENT_ID'];
final WEB_CLIENT_SECRET = Platform.environment['WEB_CLIENT_SECRET'];
const USERNAME = 'DRAWApiOfficial';
final PASSWORD = Platform.environment['PASSWORD'];

bool isScriptAuthConfigured =
    (SCRIPT_CLIENT_ID != null) && (SCRIPT_CLIENT_SECRET != null);
