// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

/// Thrown when client side configures api incorrectly.
class DRAWClientError implements Exception {
	DRAWClientError(this.message);
	String message;
	String toString() => 'DRAWClientError: $message';
}

/// Thrown when there is an error during the authentication flow.
class DRAWAuthenticationError implements Exception {
  DRAWAuthenticationError(this.message);
  String message;
  String toString() => 'DRAWAuthenticationError: $message';
}

/// Thrown by unfinished code that hasn't yet implemented all the features it
/// needs.
class DRAWUnimplementedError extends UnimplementedError {
  DRAWUnimplementedError([String message]) : super(message);
}

/// Thrown due to a fatal error encountered inside DRAW. If you're not adding
/// functionality to DRAW you should never see this. Otherwise, please file a
/// bug at github.com/draw-dev/DRAW/issues.
class DRAWInternalError implements Exception {
  DRAWInternalError(this.message);
  String message;
  String toString() => 'DRAWInternalError: $message';
}
