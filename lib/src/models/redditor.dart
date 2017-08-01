// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../base.dart';
import '../exceptions.dart';
import '../reddit.dart';

class Redditor extends RedditBase {
  String _name;
  Uri _path;

  Redditor.parse(Reddit reddit, Map data) : super.loadData(reddit, data) {
    if (!data.containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception
      throw new DRAWUnimplementedError();
    }
    _name = data['name'];
  }
}
