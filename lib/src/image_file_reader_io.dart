/// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:io';
import 'package:draw/src/models/subreddit.dart';
import 'package:collection/collection.dart';

const String _kJpegHeader = '\xff\xd8\xff';

Future<Map> loadImage(Uri imagePath) async {
  final image = File.fromUri(imagePath);
  if (!await image.exists()) {
    throw FileSystemException('File does not exist', imagePath.toString());
  }
  final imageBytes = await image.readAsBytes();
  if (imageBytes.length < _kJpegHeader.length) {
    throw FormatException('Invalid image format for file $imagePath.');
  }
  final header = imageBytes.sublist(0, _kJpegHeader.length);
  final isJpeg =
      const IterableEquality().equals(_kJpegHeader.codeUnits, header);
  return {
    'imageBytes': imageBytes,
    'imageType': isJpeg ? ImageFormat.jpeg : ImageFormat.png,
  };
}
