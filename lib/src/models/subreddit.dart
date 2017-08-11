// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../base.dart';
import '../reddit.dart';

// TODO(bkonyi) implement
class Subreddit extends RedditBase {
  final String _name;

  Subreddit(Reddit reddit, String name)
      : _name = name,
        super.loadData(reddit, null);

  Subreddit.parse(Reddit reddit, Map data)
      : _name = null,
        super.loadData(reddit, data['data']);

  int get hashCode => _name.hashCode;

  bool operator ==(other) {
    return (_name == other._name);
  }
}
