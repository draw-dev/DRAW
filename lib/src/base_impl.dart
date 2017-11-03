// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'exceptions.dart';
import 'reddit.dart';

void setData(RedditBase base, Map data) {
  base._data = data;
}

abstract class RedditBase {
  final Reddit reddit;
  final RegExp _snakecaseRegExp = new RegExp("[A-Z]");
  Map _data;
  Map get data => _data;
  String get infoPath => _infoPath;
  String _infoPath;

  RedditBase(this.reddit);

  RedditBase.withPath(this.reddit, String infoPath) : _infoPath = infoPath;

  RedditBase.loadData(this.reddit, Map data) : _data = data;

  RedditBase.loadDataWithPath(this.reddit, Map data, String infoPath)
      : _data = data,
        _infoPath = infoPath;

  String _snakeCase(String name, [separator = '_']) => name.replaceAllMapped(
      _snakecaseRegExp,
      (Match match) =>
          (match.start != 0 ? separator : '') + match.group(0).toLowerCase());

  Future<Map> _fetch() async => reddit.get(_infoPath);

  Future property(String key) async {
    if (_data == null) {
      await refresh();
      // TODO(bkonyi): should we throw an exception here instead?
      assert(_data != null);
    }
    if (_data.containsKey(_snakeCase(key))) {
      return _data[_snakeCase(key)];
    }
    return null;
  }

  Future refresh() async {
    final response = await _fetch();
    if (response is Map) {
      _data = response;
    } else if (response is List) {
      // TODO(bkonyi): this is for populating a Submission, since requesting
      // Submission returns a list of listings, containing a Submission at [0]
      // and a listing of Comments at [1]. This probably needs to be changed
      // at some point to be a bit more robust, but it works for now.
      _data = response[0]['listing'][0].data;
    } else {
      throw new DRAWInternalError('Refresh response is of unknown type: '
          '${response.runtimeType}.');
    }
  }

  @override
  String toString() {
    return _data?.toString();
  }
}
