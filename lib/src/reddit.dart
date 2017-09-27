// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:oauth2/oauth2.dart' as oauth2;

import 'auth.dart';
import 'draw_config_context.dart';
import 'exceptions.dart';
import 'objector.dart';
import 'user.dart';

/// The [Reddit] class provides access to Reddit's API and stores session state
/// for the current [Reddit] instance. This class contains objects that can be
/// used to interact with Reddit posts, comments, subreddits, multireddits, and
/// users.
class Reddit {
  /// The default [Uri] used to request an authorization token from Reddit.
  static final Uri defaultTokenEndpoint =
      Uri.parse(DRAWConfigContext.kDefaultAccessToken);

  /// The default [Uri] used to authenticate an authorization token from Reddit.
  static final Uri defaultAuthEndpoint =
      Uri.parse(DRAWConfigContext.kDefaultAuthorizeUri);

  /// The default path to the Reddit API.
  static final String defaultOAuthApiEndpoint =
      DRAWConfigContext.kDefaultOAuthUrl;

  /// The default object kind mapping for [Comment].
  static final String defaultCommentKind = DRAWConfigContext.kCommentKind;

  /// The default object kind mapping for [Message].
  static final String defaultMessageKind = DRAWConfigContext.kMessageKind;

  /// The default object kind mapping for [Redditor].
  static final String defaultRedditorKind = DRAWConfigContext.kRedditorKind;

  /// The default object kind mapping for [Submission].
  static final String defaultSubmissionKind = DRAWConfigContext.kSubmissionKind;

  /// The default object kind mapping for [Subreddit].
  static final String defaultSubredditKind = DRAWConfigContext.kSubredditKind;

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

  /// Provides methods for the currently authenticated user.
  User get user => _user;

  Authenticator _auth;
  User _user;
  bool _readOnly = true;
  final _initializedCompleter = new Completer();
  Objector _objector;

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
  /// [redirectUri] is the redirect URI associated with your Reddit application.
  /// This field is unused for script and read-only instances.
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  // TODO(bkonyi): inherit from some common base class.
  Reddit(String clientId, String clientSecret, String userAgent,
      {String username,
      String password,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint}) {
    //Loading passed in values into config file.
    final DRAWConfigContext config = new DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        username: username,
        password: password,
        redirectUri: redirectUri.toString(),
        accessToken: tokenEndpoint.toString(),
        authorizeUri: authEndpoint.toString());

    if (config.clientId == null) {
      throw new DRAWAuthenticationError('clientId cannot be null.');
    }
    if (config.clientSecret == null) {
      throw new DRAWAuthenticationError('clientSecret cannot be null.');
    }
    if (config.userAgent == null) {
      throw new DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = new oauth2.AuthorizationCodeGrant(config.clientId,
        Uri.parse(config.authorizeUri), Uri.parse(config.accessToken),
        secret: config.clientSecret);

    if (config.username == null &&
        config.password == null &&
        config.redirectUri == null) {
      ReadOnlyAuthenticator
          .create(grant, config.userAgent)
          .then(_initializationCallback);
      _readOnly = true;
    } else if (config.username == null && config.password != null) {
      // Check if we are creating an authorized client.
      ScriptAuthenticator
          .create(grant, config.userAgent, config.username, config.password)
          .then(_initializationCallback);
      _readOnly = false;
    } else if (config.username == null &&
        config.password == null &&
        config.redirectUri != null) {
      _initializationCallback(WebAuthenticator.create(
          grant, config.userAgent, Uri.parse(config.redirectUri)));
      _readOnly = false;
    } else {
      throw new DRAWUnimplementedError('Unsupported authentication type.');
    }
  }

  Reddit.fromAuthenticator(Authenticator auth) {
    if (auth == null) {
      throw new DRAWAuthenticationError('auth cannot be null.');
    }
    _initializationCallback(auth);
  }

  Future<dynamic> get(String api, {Map params}) async {
    if (!(await initialized)) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.get(path, params: params);
    return _objector.objectify(response);
  }

  Future<dynamic> post(String api, Map<String, String> body) async {
    if (!(await initialized)) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.post(path, body);
    return _objector.objectify(response);
  }

  Future put(String api, {/* Map<String, String>, String */ body}) async {
    if (!(await initialized)) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.put(path, body: body);
    return _objector.objectify(response);
  }

  Future delete(String api, {/* Map<String, String>, String */ body}) async {
    if (!(await initialized)) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.delete(path, body: body);
    return _objector.objectify(response);
  }

  void _initializationCallback(Authenticator auth) {
    _auth = auth;
    _objector = new Objector(this);
    _user = new User(this);
    _initializedCompleter.complete(true);
  }
}
