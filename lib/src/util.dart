// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'models/user_content.dart';

/// A set that can only contain up to a max number of elements. If the set is
/// full and another item is added, the oldest item in the set is removed.
class BoundedSet<T> {
  final int _maxItems;
  final List _fifo;
  final Set _set;

  BoundedSet(int maxItems)
      : _maxItems = maxItems,
        _fifo = new List<T>(),
        _set = new Set<T>();

  bool contains(T object) {
    return _set.contains(object);
  }

  void add(T object) {
    if (_set.length == _maxItems) {
      assert(_set.remove(_fifo.removeAt(0)));
    }
    _fifo.add(object);
    _set.add(object);
  }
}

/// A counter class which increases count exponentially with jitter up to a
/// maximum value.
class ExponentialCounter {
  final double _maxCounter;
  final Random _random;
  double _base = 1.0;

  ExponentialCounter(int maxCounter)
      : _maxCounter = maxCounter.toDouble(),
        _random = new Random();

  int counter() {
    // See the following for a description of jitter and why we should use it:
    // https://www.awsarchitectureblog.com/2015/03/backoff.html
    final maxJitter = _base / 16.0;
    final value = _base + _random.nextDouble() * maxJitter - maxJitter / 2.0;
    _base = min(_base * 2, _maxCounter);
    return value.round();
  }

  void reset() => _base = 1.0;
}

Stream<UserContent> streamGenerator(function, {int pauseAfter}) async* {
  final counter = new ExponentialCounter(16);
  final seen = new BoundedSet<String>(301);
  var withoutBeforeCounter = 0;
  var responsesWithoutNew = 0;
  var beforeFullname;

  while (true) {
    var limit = 100;
    var found = false;
    var newestFullname;
    if (beforeFullname == null) {
      limit -= withoutBeforeCounter;
      withoutBeforeCounter = (withoutBeforeCounter + 1) % 30;
    }

    final results = [];
    await for (final item
        in function(params: {'limit': limit, 'before': beforeFullname})) {
      results.add(item);
    }

    for (final item in results.reversed) {
      final fullname = await item.property('name');
      if (seen.contains(fullname)) {
        continue;
      }
      found = true;
      seen.add(fullname);
      newestFullname = fullname;
      yield item;
    }

    beforeFullname = newestFullname;
    if (pauseAfter != null && pauseAfter < 0) {
      yield null;
    } else if (found) {
      counter.reset();
      responsesWithoutNew = 0;
    } else {
      responsesWithoutNew += 1;
      if (pauseAfter != null && (responsesWithoutNew > pauseAfter)) {
        responsesWithoutNew = 0;
        yield null;
      } else {
        sleep(new Duration(seconds: counter.counter()));
      }
    }
  }
}
