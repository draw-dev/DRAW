// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/auth.dart';
import 'package:draw/src/draw_config_context.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/frontpage.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/inbox.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/subreddits.dart';
import 'package:draw/src/objector.dart';
import 'package:draw/src/user.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

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

  /// The default object kind mapping for [Trophy].
  static final String defaultTrophyKind = DRAWConfigContext.kTrophyKind;

  /// A flag representing whether or not this [Reddit] instance can only make
  /// read requests.
  bool get readOnly => _readOnly;

  /// The authorized client used to interact with Reddit APIs.
  Authenticator get auth => _auth;

  /// Provides methods to retrieve content from the Reddit front page.
  FrontPage get front => _front;

  Inbox get inbox => _inbox;

  /// Provides methods to interact with sets of subreddits.
  Subreddits get subreddits => _subreddits;

  /// Provides methods for the currently authenticated user.
  User get user => _user;

  /// The configuration for the current [Reddit] instance.
  DRAWConfigContext get config => _config;

  /// A utility class that converts Reddit API responses to DRAW objects.
  Objector get objector => _objector;

  Authenticator _auth;
  DRAWConfigContext _config;
  FrontPage _front;
  Inbox _inbox;
  Subreddits _subreddits;
  User _user;
  bool _readOnly = true;
  bool _initialized = false;
  final _initializedCompleter = Completer<bool>();
  Objector _objector;

  /// Creates a new read-only [Reddit] instance for installed application types.
  ///
  /// This method should be used to create a read-only instance in
  /// circumstances where a client secret would not be secure.
  ///
  /// [clientId] is the identifier associated with your authorized application
  /// on Reddit. To get a client ID, create an authorized application
  /// [here](http://www.reddit.com/prefs/apps).
  ///
  /// [deviceId] is a unique ID per-device or per-user. See
  /// [Application Only OAuth](https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth)
  /// for best practices regarding device IDs.
  ///
  /// [userAgent] is an arbitrary identifier used by the Reddit API to
  /// differentiate between client instances. This should be relatively unique.
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Future<Reddit> createUntrustedReadOnlyInstance(
      {String clientId,
      String deviceId,
      String userAgent,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName = 'default'}) async {
    final reddit = Reddit._untrustedReadOnlyInstance(clientId, deviceId,
        userAgent, tokenEndpoint, authEndpoint, configUri, siteName);
    final initialized = await reddit._initializedCompleter.future;
    if (initialized) {
      return reddit;
    }
    throw DRAWAuthenticationError(
        'Unable to get valid OAuth token for read-only instance');
  }

  /// Creates a new [Reddit] instance for use with the installed application
  /// authentication flow. This instance is not authenticated until a valid
  /// response code is provided to `WebAuthenticator.authorize`
  /// (see test/auth/web_auth.dart for an example usage).
  ///
  /// [clientId] is the identifier associated with your authorized application
  /// on Reddit. To get a client ID, create an authorized application
  /// [here](http://www.reddit.com/prefs/apps).
  ///
  /// [userAgent] is an arbitrary identifier used by the Reddit API to
  /// differentiate between client instances. This should be relatively unique.
  ///
  /// [redirectUri] is the redirect URI associated with your Reddit application.
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Reddit createInstalledFlowInstance(
          {String clientId,
          String userAgent,
          Uri redirectUri,
          Uri tokenEndpoint,
          Uri authEndpoint,
          Uri configUri,
          String siteName = 'default'}) =>
      Reddit._webFlowInstance(clientId, '', userAgent, redirectUri,
          tokenEndpoint, authEndpoint, configUri, siteName);

  /// Creates a new read-only [Reddit] instance for web and script applications.
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
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Future<Reddit> createReadOnlyInstance(
      {String clientId,
      String clientSecret,
      String userAgent,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName = 'default'}) async {
    final reddit = Reddit._readOnlyInstance(clientId, clientSecret, userAgent,
        tokenEndpoint, authEndpoint, configUri, siteName);
    final initialized = await reddit._initializedCompleter.future;
    if (initialized) {
      return reddit;
    }
    throw DRAWAuthenticationError('Unable to authenticate with Reddit');
  }

  /// Creates a new authenticated [Reddit] instance for use with personal use
  /// scripts.
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
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Future<Reddit> createScriptInstance(
      {String clientId,
      String clientSecret,
      String userAgent,
      String username,
      String password,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName = 'default'}) async {
    final reddit = Reddit._scriptInstance(clientId, clientSecret, userAgent,
        username, password, tokenEndpoint, authEndpoint, configUri, siteName);
    final initialized = await reddit._initializedCompleter.future;
    if (initialized) {
      return reddit;
    }
    throw DRAWAuthenticationError('Unable to authenticate with Reddit');
  }

  /// Creates a new [Reddit] instance for use with the web authentication flow.
  /// This instance is not authenticated until a valid response code is
  /// provided to `WebAuthenticator.authorize` (see test/auth/web_auth.dart
  /// for an example usage).
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
  /// [redirectUri] is the redirect URI associated with your Reddit application.
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Reddit createWebFlowInstance(
          {String clientId,
          String clientSecret,
          String userAgent,
          Uri redirectUri,
          Uri tokenEndpoint,
          Uri authEndpoint,
          Uri configUri,
          String siteName = 'default'}) =>
      Reddit._webFlowInstance(clientId, clientSecret, userAgent, redirectUri,
          tokenEndpoint, authEndpoint, configUri, siteName);

  /// Creates a new authenticated [Reddit] instance from cached credentials.
  ///
  /// [credentialsJson] is a json string containing the cached credentials. This
  /// parameter is required and cannot be 'null'.
  ///
  /// This string can be retrieved from an authenticated [Reddit] instance in
  /// the following manner:
  ///
  /// ```dart
  /// final credentialsJson = reddit.auth.credentials.toJson();
  /// ```
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
  /// [redirectUri] is the redirect URI associated with your Reddit application.
  ///
  /// [tokenEndpoint] is a [Uri] to an alternative token endpoint. If not
  /// provided, [defaultTokenEndpoint] is used.
  ///
  /// [authEndpoint] is a [Uri] to an alternative authentication endpoint. If not
  /// provided, [defaultAuthTokenEndpoint] is used.
  ///
  /// [configUri] is a [Uri] pointing to a 'draw.ini' file, which can be used to
  /// populate the previously described parameters.
  ///
  /// [siteName] is the name of the configuration to use from draw.ini. Defaults
  /// to 'default'.
  static Reddit restoreAuthenticatedInstance(String credentialsJson,
      {String clientId,
      String clientSecret,
      String userAgent,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName = 'default'}) {
    if (credentialsJson == null) {
      throw DRAWArgumentError('credentialsJson cannot be null.');
    }
    return Reddit._webFlowInstanceRestore(
        clientId,
        clientSecret,
        userAgent,
        credentialsJson,
        redirectUri,
        tokenEndpoint,
        authEndpoint,
        configUri,
        siteName);
  }

  static Reddit restoreInstalledAuthenticatedInstance(String credentialsJson,
      {String clientId,
      String clientSecret,
      String userAgent,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName = 'default'}) {
    if (credentialsJson == null) {
      throw DRAWArgumentError('credentialsJson cannot be null.');
    }
    return Reddit._webFlowInstanceRestore(
        clientId,
        '',
        userAgent,
        credentialsJson,
        redirectUri,
        tokenEndpoint,
        authEndpoint,
        configUri,
        siteName);
  }

  Reddit._readOnlyInstance(
      String clientId,
      String clientSecret,
      String userAgent,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.userAgent == null) {
      throw DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = oauth2.AuthorizationCodeGrant(_config.clientId,
        Uri.parse(_config.authorizeUrl), Uri.parse(_config.accessToken),
        secret: _config.clientSecret);
    _readOnly = true;
    ReadOnlyAuthenticator.create(_config, grant)
        .then(_initializationCallback)
        .catchError(_initializationError);
  }

  Reddit._untrustedReadOnlyInstance(
      String clientId,
      String deviceId,
      String userAgent,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = DRAWConfigContext(
        clientId: clientId,
        clientSecret: '',
        userAgent: userAgent,
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.userAgent == null) {
      throw DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = oauth2.AuthorizationCodeGrant(_config.clientId,
        Uri.parse(_config.accessToken), Uri.parse(_config.accessToken),
        secret: null);

    _readOnly = true;
    ReadOnlyAuthenticator.createUntrusted(_config, grant, deviceId)
        .then(_initializationCallback)
        .catchError(_initializationError);
  }

  Reddit._scriptInstance(
      String clientId,
      String clientSecret,
      String userAgent,
      String username,
      String password,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        username: username,
        password: password,
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.clientId == null) {
      throw DRAWAuthenticationError('clientId cannot be null.');
    }
    if (_config.clientSecret == null) {
      throw DRAWAuthenticationError('clientSecret cannot be null.');
    }
    if (_config.userAgent == null) {
      throw DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = oauth2.AuthorizationCodeGrant(_config.clientId,
        Uri.parse(_config.authorizeUrl), Uri.parse(_config.accessToken),
        secret: _config.clientSecret);

    _readOnly = false;
    ScriptAuthenticator.create(_config, grant)
        .then(_initializationCallback)
        .catchError(_initializationError);
  }

  Reddit._webFlowInstance(
      String clientId,
      String clientSecret,
      String userAgent,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        redirectUrl: redirectUri.toString(),
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.clientId == null) {
      throw DRAWAuthenticationError('clientId cannot be null.');
    }
    if (_config.clientSecret == null) {
      throw DRAWAuthenticationError('clientSecret cannot be null.');
    }
    if (_config.userAgent == null) {
      throw DRAWAuthenticationError('userAgent cannot be null.');
    }

    final grant = oauth2.AuthorizationCodeGrant(_config.clientId,
        Uri.parse(_config.authorizeUrl), Uri.parse(_config.accessToken),
        secret: _config.clientSecret);

    _initializationCallback(WebAuthenticator.create(_config, grant));
    _readOnly = false;
  }

  Reddit._webFlowInstanceRestore(
      String clientId,
      String clientSecret,
      String userAgent,
      String credentialsJson,
      Uri redirectUri,
      Uri tokenEndpoint,
      Uri authEndpoint,
      Uri configUri,
      String siteName) {
    // Loading passed in values into config file.
    _config = DRAWConfigContext(
        clientId: clientId,
        clientSecret: clientSecret,
        userAgent: userAgent,
        redirectUrl: redirectUri.toString(),
        accessToken: tokenEndpoint.toString(),
        authorizeUrl: authEndpoint.toString(),
        configUrl: configUri.toString(),
        siteName: siteName);

    if (_config.clientId == null) {
      throw DRAWAuthenticationError('clientId cannot be null.');
    }
    if (_config.userAgent == null) {
      throw DRAWAuthenticationError('userAgent cannot be null.');
    }

    _initializationCallback(WebAuthenticator.restore(_config, credentialsJson));
    _readOnly = false;
  }

  Reddit.fromAuthenticator(Authenticator auth) {
    if (auth == null) {
      throw DRAWAuthenticationError('auth cannot be null.');
    }
    _config = DRAWConfigContext();
    _initializationCallback(auth);
  }

  /// Creates a lazily initialized [CommentRef].
  ///
  /// `id` is the fullname ID of the comment without the ID prefix
  /// (i.e., t1_).
  ///
  /// `url` is the URL to the comment.
  ///
  /// Only one of `id` and `url` can be provided.
  CommentRef comment({String id, /* Uri, String */ url}) {
    if ((id != null) && (url != null)) {
      throw DRAWArgumentError('One of either id or url can be provided');
    } else if ((id == null) && (url == null)) {
      throw DRAWArgumentError('id and url cannot both be null');
    } else if (id != null) {
      return CommentRef.withID(this, id);
    }
    return CommentRef.withPath(this, (url is Uri) ? url.toString() : url);
  }

  /// Creates a lazily initialized [SubmissionRef].
  ///
  /// `id` is the fullname ID of the submission without the ID prefix
  /// (i.e., t3_).
  ///
  /// `url` is the URL to the submission.
  ///
  /// Only one of `id` and `url` can be provided.
  SubmissionRef submission({String id, /* Uri, String */ url}) {
    if ((id != null) && (url != null)) {
      throw DRAWArgumentError('One of either id or url can be provided');
    } else if ((id == null) && (url == null)) {
      throw DRAWArgumentError('id and url cannot both be null');
    } else if (id != null) {
      return SubmissionRef.withID(this, id);
    }
    return SubmissionRef.withPath(this, (url is Uri) ? url.toString() : url);
  }

  RedditorRef redditor(String redditor) => RedditorRef.name(this, redditor);

  SubredditRef subreddit(String subreddit) =>
      SubredditRef.name(this, subreddit);

  Future<dynamic> get(String api,
      {Map<String, String> params,
      bool objectify = true,
      bool followRedirects = false}) async {
    if (!_initialized) {
      throw DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = Uri.https(defaultOAuthApiEndpoint, api);
    final response =
        await auth.get(path, params: params, followRedirects: followRedirects);
    return objectify ? _objector.objectify(response) : response;
  }

  Future<dynamic> post(String api, Map<String, String> body,
      {bool discardResponse = false, bool objectify = true}) async {
    if (!_initialized) {
      throw DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.post(path, body);
    if (discardResponse) {
      return null;
    }
    return objectify ? _objector.objectify(response) : response;
  }

  Future<dynamic> put(String api,
      {/* Map<String, String>, String */ body}) async {
    if (!_initialized) {
      throw DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.put(path, body: body);
    return _objector.objectify(response);
  }

  Future<dynamic> delete(String api,
      {/* Map<String, String>, String */ body}) async {
    if (!_initialized) {
      throw DRAWAuthenticationError(
          'Cannot make requests using unauthenticated client.');
    }
    final path = Uri.https(defaultOAuthApiEndpoint, api);
    final response = await auth.delete(path, body: body);
    return _objector.objectify(response);
  }

  void _initializationCallback(Authenticator auth) {
    _auth = auth;
    _front = FrontPage(this);
    _inbox = Inbox(this);
    _objector = Objector(this);
    _subreddits = Subreddits(this);
    _user = User(this);
    _initialized = true;
    _initializedCompleter.complete(true);
  }

  void _initializationError(e) {
    _initialized = false;
    _initializedCompleter.completeError(e);
  }
}
