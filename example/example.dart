// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'package:draw/draw.dart';

Future main() async {
  // Create the `Reddit` instance and authenticate
  Reddit reddit = await Reddit.createInstance(
    clientId: CLIENT_ID,
    clientSecret: SECRET,
    userAgent: AGENT_NAME,
    username: "DRAWApiOfficial",
    password: "hunter12", // Fake
  );

  // Retrieve information for the currently authenticated user
  Redditor currentUser = await reddit.user.me();
  // Outputs: My name is DRAWApiOfficial
  print("My name is ${currentUser.displayName}");
}
