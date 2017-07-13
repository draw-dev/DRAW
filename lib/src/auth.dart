// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import "package:oauth2/src/handle_access_token_response.dart";

import 'exceptions.dart';

const String kGetRequest = 'GET';
const String kPostRequest = 'POST';

const String kDurationKey = 'duration';
const String kErrorKey = 'error';
const String kGrantTypeKey = 'grant_type';
const String kMessageKey = 'message';
const String kPasswordKey = 'password';
const String kTokenKey = 'token';
const String kTokenTypeHintKey = 'token_type_hint';
const String kUserAgentKey = 'user-agent';
const String kUsernameKey = 'username';

/// The [Authenticator] class provides an interface to interact with the Reddit API
/// using OAuth2. An [Authenticator] is responsible for keeping track of OAuth2
/// credentials, refreshing and revoking access tokens, and issuing HTTPS
/// requests using OAuth2 credentials.
abstract class Authenticator {
  oauth2.AuthorizationCodeGrant _grant;
  oauth2.Client _client;
  String _userAgent;

  Authenticator(oauth2.AuthorizationCodeGrant grant, String userAgent)
      : _grant = grant,
        _userAgent = userAgent,
        _client = null;

  /// Request a new access token from the Reddit API. Throws a
  /// [DRAWAuthenticationError] if the [Authenticator] is not yet initialized.
  Future refresh() async {
    if (_client == null) {
      throw new DRAWAuthenticationError(
          'cannot refresh uninitialized Authenticator.');
    }
    await _authenticationFlow();
  }

  /// Revokes any outstanding tokens associated with the authenticator.
  Future revoke() async {
    if (credentials == null) {
      return;
    }
    final tokens = new List<Map>();
    final accessToken = {
      kTokenKey: credentials.accessToken,
      kTokenTypeHintKey: 'access_token',
    };
    tokens.add(accessToken);

    if (credentials.refreshToken != null) {
      final refreshToken = {
        kTokenKey: credentials.refreshToken,
        kTokenTypeHintKey: 'refresh_token',
      };
      tokens.add(refreshToken);
    }
    for (final token in tokens) {
      final revokeAccess = new Map<String, String>();
      revokeAccess[kTokenKey] = token[kTokenKey];
      revokeAccess[kTokenTypeHintKey] = token[kTokenTypeHintKey];

      // TODO(bkonyi) we shouldn't have hardcoded urls like this. Move to common
      // file with all API related strings.
      var path = Uri.parse(r'https://www.reddit.com/api/v1/revoke_token');

      // Retrieve the client ID and secret.
      final clientId = _grant.identifier;
      final clientSecret = _grant.secret;

      if ((clientId != null) && (clientSecret != null)) {
        final userInfo = '$clientId:$clientSecret';
        path = path.replace(userInfo: userInfo);
      }

      final headers = new Map<String, String>();
      headers[kUserAgentKey] = _userAgent;

      final httpClient = new http.Client();

      // Request the token from the server.
      final response =
          await httpClient.post(path, headers: headers, body: revokeAccess);

      if (response.statusCode != 204) {
        // We should always get a 204 response for this call.
        final parsed = JSON.decode(response.body);
        _throwAuthenticationError(parsed);
      }
    }
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate. All classes inheriting from
  /// [Authenticator] must implement this method.
  Future _authenticationFlow();

  /// Make a simple `GET` request. [path] is the destination URI that the
  /// request will be made to.
  Future<Map> get(Uri path) async {
    return _request(kGetRequest, path);
  }

  /// Make a simple `POST` request. [path] is the destination URI and [body]
  /// contains the POST parameters that will be sent with the request.
  Future<Map> post(Uri path, Map<String, String> body) async {
    return _request(kPostRequest, path, body);
  }

  /// Request data from Reddit using our OAuth2 client.
  ///
  /// [type] can be one of `GET`, `POST`, and `PUT`. [path] represents the
  /// request parameters. [body] is an optional parameter which contains the
  /// body fields for a POST request.
  Future<Map> _request(String type, Uri path,
      [Map<String, String> body]) async {
    if (_client == null) {
      throw new DRAWAuthenticationError(
          'The authenticator does not have a valid token.');
    }
    if (!isValid) {
      await refresh();
    }
    final request = new http.Request(type, path);
    if (body != null) {
      request.bodyFields = body;
    }
    final http.StreamedResponse response = await _client.send(request);
    final parsed = JSON.decode(await response.stream.bytesToString());
    if (parsed.containsKey(kErrorKey)) {
      _throwAuthenticationError(parsed);
    }
    return parsed;
  }

  /// Requests the authentication token from Reddit based on parameters provided
  /// in [accountInfo] and [_grant].
  Future _requestToken(Map<String, String> accountInfo) async {
    // Retrieve the client ID and secret.
    final clientId = _grant.identifier;
    final clientSecret = _grant.secret;
    String userInfo;

    if ((clientId != null) && (clientSecret != null)) {
      userInfo = '$clientId:$clientSecret';
    }

    final httpClient = new http.Client();
    final start = new DateTime.now();
    final headers = new Map<String, String>();
    headers[kUserAgentKey] = _userAgent;

    // Request the token from the server.
    final response = await httpClient.post(
        _grant.tokenEndpoint.replace(userInfo: userInfo),
        headers: headers,
        body: accountInfo);

    // Check for error response.
    final responseMap = JSON.decode(response.body);
    if (responseMap.containsKey(kErrorKey)) {
      _throwAuthenticationError(responseMap);
    }

    // Create the Credentials object from the authentication token.
    final credentials = handleAccessTokenResponse(
        response, _grant.tokenEndpoint, start, ['*'], ',');

    // Generate the OAuth2 client that will be used to query Reddit servers.
    _client = new oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret, httpClient: httpClient);
  }

  void _throwAuthenticationError(Map response) {
    final statusCode = response[kErrorKey];
    final reason = response[kMessageKey];
    throw new DRAWAuthenticationError(
        'Status Code: ${statusCode} Reason: ${reason}');
  }

  /// The credentials associated with this authenticator instance.
  ///
  /// Returns an [oauth2.Credentials] object associated with the current
  /// authenticator instance, otherwise returns [null].
  oauth2.Credentials get credentials => _client?.credentials;

  /// The user agent value to be presented to Reddit.
  ///
  /// Returns the user agent value which is used as an identifier for this
  /// session. Provided on authenticator creation.
  String get userAgent => _userAgent;

  /// A flag representing whether or not this authenticator instance is valid.
  ///
  /// Returns `false` if the authentication flow has not yet been completed, if
  /// [revoke] has been called, or the access token has expired.
  bool get isValid {
    return !(credentials?.isExpired ?? true);
  }
}

/// The [ScriptAuthenticator] class allows for the creation of an [Authenticator]
/// instance which is associated with a valid Reddit user account. This is to be
/// used with the 'Script' app type credentials. Refer to
/// https://github.com/reddit/reddit/wiki/OAuth2-App-Types for descriptions of
/// valid app types.
class ScriptAuthenticator extends Authenticator {
  String _username;
  String _password;

  ScriptAuthenticator._(oauth2.AuthorizationCodeGrant grant, String userAgent,
      String username, String password)
      : _username = username,
        _password = password,
        super(grant, userAgent);

  static Future<ScriptAuthenticator> create(oauth2.AuthorizationCodeGrant grant,
      String userAgent, String username, String password) async {
    final ScriptAuthenticator authenticator =
        new ScriptAuthenticator._(grant, userAgent, username, password);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future _authenticationFlow() async {
    final accountInfo = new Map<String, String>();
    accountInfo[kUsernameKey] = _username;
    accountInfo[kPasswordKey] = _password;
    accountInfo[kGrantTypeKey] = 'password';
    accountInfo[kDurationKey] = 'permanent';
    await _requestToken(accountInfo);
  }
}

/// The [ReadOnlyAuthenticator] class allows for the creation of an [Authenticator]
/// instance which is not associated with any reddit account. As the name
/// implies, the [ReadOnlyAuthenticator] can only be used to make read-only
/// requests to the Reddit API that do not require access to a valid Reddit user
/// account. Refer to https://github.com/reddit/reddit/wiki/OAuth2-App-Types for
/// descriptions of valid app types.
class ReadOnlyAuthenticator extends Authenticator {
  ReadOnlyAuthenticator._(oauth2.AuthorizationCodeGrant grant, String userAgent)
      : super(grant, userAgent);

  static Future<ReadOnlyAuthenticator> create(
      oauth2.AuthorizationCodeGrant grant, String userAgent) async {
    final ReadOnlyAuthenticator authenticator =
        new ReadOnlyAuthenticator._(grant, userAgent);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future _authenticationFlow() async {
    final accountInfo = new Map<String, String>();
    accountInfo[kGrantTypeKey] = 'client_credentials';
    await _requestToken(accountInfo);
  }
}

/// The [WebAuthenticator] class allows for the creation of an [Authenticator]
/// that exposes functionality which allows for the user to authenticate through
/// a browser. The [url] method is used to generate the URL that the user uses
/// to authenticate on www.reddit.com, and the [authorize] method retrieves the
/// access token given the returned `code`. This is to be
/// used with the 'Web' app type credentials. Refer to
/// https://github.com/reddit/reddit/wiki/OAuth2-App-Types for descriptions of
/// valid app types.
class WebAuthenticator extends Authenticator {
  Uri _redirect;

  WebAuthenticator._(
      oauth2.AuthorizationCodeGrant grant, String userAgent, Uri redirect)
      : _redirect = redirect,
        super(grant, userAgent) {
    assert(_redirect != null);
  }

  static WebAuthenticator create(
      oauth2.AuthorizationCodeGrant grant, String userAgent, Uri redirect) {
    final WebAuthenticator authenticator =
        new WebAuthenticator._(grant, userAgent, redirect);
    return authenticator;
  }

  /// Generates the authentication URL used for Reddit user verification in a
  /// browser.
  ///
  /// [scopes] is the list of all scopes that can be requested (see
  /// https://www.reddit.com/api/v1/scopes for a list of valid scopes). [state]
  /// should be a unique [String] for the current [Authenticator] instance.
  /// The value of [state] will be returned via the redirect Uri and should be
  /// verified against the original value of [state] to ensure the app access
  /// response corresponds to the correct request. [duration] indicates whether
  /// or not a permanent token is needed for the client, and can take the value
  /// of either 'permanent' (default) or 'temporary'. If [compactLogin] is true,
  /// then the Uri will link to a mobile-friendly Reddit authentication screen.
  Uri url(List<String> scopes, String state,
      {String duration = 'permanent', bool compactLogin = false}) {
    // TODO(bkonyi) do we want to add the [implicit] flag to the argument list?
    if (scopes == null) {
      // scopes cannot be null.
      throw new DRAWAuthenticationError('Parameter scopes cannot be null.');
    }
    Uri redditAuthUri =
        _grant.getAuthorizationUrl(_redirect, scopes: scopes, state: state);
    if (redditAuthUri == null) {
      // TODO(bkonyi) throw meaningful exception.
      assert(false);
    }
    // getAuthorizationUrl returns a Uri which is missing the duration field, so
    // we need to add it here.
    final queryParameters = new Map.from(redditAuthUri.queryParameters);
    queryParameters[kDurationKey] = duration;
    redditAuthUri = redditAuthUri.replace(queryParameters: queryParameters);
    if (compactLogin) {
      String path = redditAuthUri.path;
      assert(path.endsWith('?'), 'The path should end with "authorize?"');
      path = path.substring(0, path.length - 1) + r'.compact?';
      redditAuthUri = redditAuthUri.replace(path: path);
    }
    return redditAuthUri;
  }

  /// Authorizes the current [Authenticator] instance using the code returned
  /// from Reddit after the user has authenticated.
  ///
  /// [code] is the value passed as a query parameter to `redirect`. This value
  /// must be parsed from the request made to `redirect` before being passed to
  /// this method.
  Future authorize(String code) async {
    if (code == null) {
      // code cannot be null.
      throw new DRAWAuthenticationError('Parameter code cannot be null.');
    }
    _client = await _grant.handleAuthorizationCode(code);
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future _authenticationFlow() async {
    throw new UnimplementedError(
        '_authenticationFlow is not used in WebAuthenticator.');
  }

  /// Request a new access token from the Reddit API. Throws a
  /// [DRAWAuthenticationError] if the [Authenticator] is not yet initialized.
  @override
  Future refresh() async {
    if (_client == null) {
      throw new DRAWAuthenticationError(
          'cannot refresh uninitialized Authenticator.');
    }
    _client = await _client.refreshCredentials();
  }
}
