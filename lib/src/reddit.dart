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

import 'models/inbox.dart';
import 'models/submission.dart';
import 'models/subreddit.dart';

/// The [Reddit] class provides access to Reddit's API and stores session state
/// for the current [Reddit] instance. This class contains objects that can be
/// used to interact with Reddit posts, comments, subreddits, multireddits, and
/// users.
class Reddit {
  ///The default Url for the OAuthEndpoint
  static final String defaultOAuthApiEndpoint = r'oauth.reddit.com';

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

  /// A flag representing whether or not this [Reddit] instance can only make
  /// read requests.
  bool get readOnly => _readOnly;

  /// The authorized client used to interact with Reddit APIs.
  Authenticator get auth => _auth;

  Inbox get inbox => _inbox;

  /// Provides methods for the currently authenticated user.
  User get user => _user;

  /// The configuration for the current [Reddit] instance.
  DRAWConfigContext get config => _config;

  /// A utility class that converts Reddit API responses to DRAW objects.
  Objector get objector => _objector;

  Authenticator _auth;
  DRAWConfigContext _config;
  Inbox _inbox;
  User _user;
  bool _readOnly = true;
  bool _initialized = false;
  final _initializedCompleter = new Completer();
  Objector _objector;

  /// Creates a new authenticated [Reddit] instance.
  ///
  /// [clientId] is the identifier associated with your authorized application
  /// on Reddit. To get a client ID, create an authorized application
  /// [here](http://www.reddit.com/prefs/apps).
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
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Future<Reddit> createInstance({
    String clientId,
    String clientSecret,
    String userAgent,
    String username,
    String password,
    Uri redirectUri,
    Uri tokenEndpoint,
    Uri authEndpoint,
    Uri configUri,
    String siteName = 'default',
  }) async {
    final reddit = new Reddit._(
        clientId,
        clientSecret,
        userAgent,
        username,
        password,
        redirectUri,
        tokenEndpoint,
        authEndpoint,
        configUri,
        siteName);
    final initialized = await reddit._initializedCompleter.future;
    if (initialized) {
      return reddit;
    }
    throw new DRAWAuthenticationError('Unable to authenticate with Reddit');
  }

  // TODO(bkonyi): inherit from some common base class.
  Reddit._(
      String clientId,
      String clientSecret,
      String userAgent,
      String username,
      String password,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = new DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        username: username,
        password: password,
        redirectUrl: redirectUri.toString(),
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.clientId == null) {
      throw new DRAWAuthenticationError('clientId cannot be null.');
    }
    if (_config.clientSecret == null) {
      throw new DRAWAuthenticationError('clientSecret cannot be null.');
    }
    if (_config.userAgent == null) {
      throw new DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = new oauth2.AuthorizationCodeGrant(_config.clientId,
        Uri.parse(_config.authorizeUrl), Uri.parse(_config.accessToken),
        secret: _config.clientSecret);

    if (_config.username == null &&
        _config.password == null &&
        _config.redirectUrl == null) {
      ReadOnlyAuthenticator
          .create(_config, grant)
          .then(_initializationCallback);
      _readOnly = true;
    } else if (_config.username != null && _config.password != null) {
      // Check if we are creating an authorized client.
      ScriptAuthenticator.create(_config, grant).then(_initializationCallback);
      _readOnly = false;
    } else if (_config.username == null &&
        _config.password == null &&
        _config.redirectUrl != null) {
      _initializationCallback(WebAuthenticator.create(_config, grant));
      _readOnly = false;
    } else {
      throw new DRAWUnimplementedError('Unsupported authentication type.');
    }
  }

  Reddit.fromAuthenticator(Authenticator auth) {
    if (auth == null) {
      throw new DRAWAuthenticationError('auth cannot be null.');
    }
    _config = new DRAWConfigContext();
    _initializationCallback(auth);
  }

  Submission submission({String id, /* Uri, String */ url}) {
    if ((id != null) && (url != null)) {
      throw new DRAWArgumentError('One of either id or url can be provided');
    } else if ((id == null) && (url == null)) {
      throw new DRAWArgumentError('id and url cannot both be null');
    } else if (id != null) {
      return new Submission.withID(this, id);
    }
    return new Submission.withPath(this, (url is Uri) ? url.toString() : url);
  }

  Subreddit subreddit(String subreddit) => new Subreddit.name(this, subreddit);

  Future<dynamic> get(String api, {Map params}) async {
    if (!_initialized) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.get(path, params: params);
    return _objector.objectify(response);
  }

  Future<dynamic> post(String api, Map<String, String> body,
      {bool discardResponse: false}) async {
    if (!_initialized) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.post(path, body);
    if (discardResponse) {
      return null;
    }
    return _objector.objectify(response);
  }

  Future put(String api, {/* Map<String, String>, String */ body}) async {
    if (!_initialized) {
      throw new DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = new Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.put(path, body: body);
    return _objector.objectify(response);
  }

  Future delete(String api, {/* Map<String, String>, String */ body}) async {
    if (!_initialized) {
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
    _inbox = new Inbox(this);
    _user = new User(this);
    _initialized = true;
    _initializedCompleter.complete(true);
  }
}
