// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:draw/src/util.dart';

void main() {
  test('BoundedSet', () {
    final bounded = BoundedSet<int>(5);
    for (int i = 0; i < 5; ++i) {
      bounded.add(i);
      expect(bounded.contains(i), isTrue);
    }
    expect(bounded.contains(6), isFalse);
    bounded.add(6);
    expect(bounded.contains(6), isTrue);
    expect(bounded.contains(0), isFalse);
  });

  test('ExponentialCounter', () {
    final counter = ExponentialCounter(5);
    for (int i = 0; i < 25; ++i) {
      expect(counter.counter() <= 5.0, isTrue);
    }
    counter.reset();
    expect(counter.counter() <= 2.0, isTrue);
  });
}