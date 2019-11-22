/// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

export 'image_file_reader_unsupported.dart'
    if (dart.library.io) 'image_file_reader_io.dart';
