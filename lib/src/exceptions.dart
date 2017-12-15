// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

/// Thrown when there is an error during the authentication flow.
class DRAWAuthenticationError implements Exception {
  DRAWAuthenticationError(this.message);
  final String message;
  String toString() => 'DRAWAuthenticationError: $message';
}

/// Thrown due to invalid arguments being provided to a DRAW method.
class DRAWArgumentError implements Exception {
  DRAWArgumentError(this.message);
  final String message;
  String toString() => 'DRAWArgumentError: $message';
}

/// Thrown due to a fatal error encountered inside DRAW. If you're not adding
/// functionality to DRAW you should never see this. Otherwise, please file a
/// bug at github.com/draw-dev/DRAW/issues.
class DRAWInternalError implements Exception {
  DRAWInternalError(this.message);
  final String message;
  String toString() => 'DRAWInternalError: $message';
}

/// Thrown due to a error on the side of the client due to incorrect integration of DRAW.
class DRAWClientError implements Exception {
  DRAWClientError(this.message);
  final String message;
  String toString() =>
      'DRAWClientError: $message This is likely due to issues with your ini file.';
}

/// Thrown when a redirect is requested after a network call. Used to notify
/// various APIs that additional work needs to be done.
class DRAWRedirectResponse implements Exception {
  final String path;
  final response;
  DRAWRedirectResponse(this.path, this.response);
  String toString() => 'DRAWRedirectResponse: Unexpected redirect to ${path}.';
}

/// Thrown by unfinished code that hasn't yet implemented all the features it
/// needs.
class DRAWUnimplementedError extends UnimplementedError {
  DRAWUnimplementedError([String message]) : super(message);
}
