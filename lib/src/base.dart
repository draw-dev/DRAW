// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'reddit.dart';

class RedditBase {
  final Reddit reddit;
  final RegExp _snakecaseRegExp = new RegExp("[A-Z]");
  Map _data;
  Map get data => _data;
  String _infoPath;

  RedditBase(this.reddit);

  RedditBase.withPath(this.reddit, String infoPath) : _infoPath = infoPath;

  RedditBase.loadData(this.reddit, Map data) : _data = data;

  String _snakeCase(String name, [separator = '_']) => name.replaceAllMapped(
      _snakecaseRegExp,
      (Match match) =>
          (match.start != 0 ? separator : '') + match.group(0).toLowerCase());

  Future<Map> _fetch() async => reddit.get(_infoPath);

  Future property(String key) async {
    if (_data == null) {
      _data = await _fetch();
      // TODO(bkonyi): should we throw an exception here instead?
      assert(_data != null);
    }
    if (_data.containsKey(_snakeCase(key))) {
      return _data[_snakeCase(key)];
    }
    return null;
  }

  @override
  String toString() {
    return _data?.toString();
  }
}
