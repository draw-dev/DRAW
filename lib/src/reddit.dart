// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:oauth2/oauth2.dart' as oauth2;

import 'auth.dart';
import 'exceptions.dart';

/// The [Reddit] class provides access to Reddit's API and stores session state
/// for the current [Reddit] instance. This class contains objects that can be
/// used to interact with Reddit posts, comments, subreddits, multireddits, and
/// users.
class Reddit {
  /// The default [Uri] used to request an authorization token from Reddit.
  static final Uri defaultTokenEndpoint =
      Uri.parse(r'https://www.reddit.com/api/v1/access_token');

  /// The default [Uri] used to authenticate an authorization token from Reddit.
  static final Uri defaultAuthEndpoint =
      Uri.parse(r'https://reddit.com/api/v1/authorize');

  /// A flag representing the initialization state of the current [Reddit]
  /// instance.
  ///
  /// Returns a [Future<bool>] which represents whether or not the [Reddit]
  /// instance is initialized. This [Future] completes with 'false' if an error
  /// occurred during initialization, and 'true' if the instance is ready.
  Future<bool> get initialized => _initializedCompleter.future;

  /// A flag representing whether or not this [Reddit] instance can only make
  /// read requests.
  bool get readOnly => _readOnly;

  /// The authorized client used to interact with Reddit APIs.
  Authenticator get auth => _auth;

  Authenticator _auth;
  bool _readOnly = true;
  Completer _initializedCompleter = new Completer();

  // TODO(bkonyi) update clientId entry to show hyperlink.
  /// Creates a new authenticated [Reddit] instance.
  ///
  /// [clientId] is the identifier associated with your authorized application
  /// on Reddit. To get a client ID, create an authorized application here:
  /// http://www.reddit.com/prefs/apps.
  ///
  /// [clientSecret] is the unique secret associated with your client ID. This
  /// is required for script and web applications.
  ///
  /// [userAgent] is an arbitrary identifier used by the Reddit API to
  /// differentiate between client instances. This should be relatively unique.
  ///
  /// [username] and [password] is a valid Reddit username password combination.
  /// These fields are required in order to perform any account actions or make
  /// posts.
  ///
  /// [redirectUri]
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  Reddit(String clientId, String clientSecret, String userAgent,
      {String username,
      String password,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint}) {
    if (clientId == null) {
      throw new DRAWAuthenticationError('clientId cannot be null.');
    }
    if (clientSecret == null) {
      throw new DRAWAuthenticationError('clientSecret cannot be null.');
    }
    if (userAgent == null) {
      throw new DRAWAuthenticationError('userAgent cannot be null.');
    }
    oauth2.AuthorizationCodeGrant grant = new oauth2.AuthorizationCodeGrant(
        clientId,
        authEndpoint ?? defaultAuthEndpoint,
        tokenEndpoint ?? defaultTokenEndpoint,
        secret: clientSecret);
    if ((username == null) && (password == null) && (redirectUri == null)) {
      ReadOnlyAuthenticator
          .Create(grant, userAgent)
          .then(_initializationCallback);
      _readOnly = true;
    } else if ((username != null) && (password != null)) {
      // Check if we are creating an authorized client.
      ScriptAuthenticator
          .Create(grant, userAgent, username, password)
          .then(_initializationCallback);
      _readOnly = false;
    } else if ((username == null) &&
        (password == null) &&
        (redirectUri != null)) {
      _initializationCallback(
          WebAuthenticator.Create(grant, userAgent, redirectUri));
      _readOnly = false;
    } else {
      throw new UnimplementedError('Unsupported authentication type.');
    }
  }

  void _initializationCallback(Authenticator auth) {
    _auth = auth;
    _initializedCompleter.complete(true);
  }
}
