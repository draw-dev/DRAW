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
  Authenticator(oauth2.AuthorizationCodeGrant grant, String userAgent)
      : _grant = grant,
        _userAgent = userAgent,
        _client = null;

  void authorize(String code) {
    // TODO(bkonyi) implement.
    throw new UnimplementedError();
  }

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
    String accessToken = credentials.accessToken;
    Map<String, String> revokeAccess = new Map<String, String>();
    revokeAccess[kTokenKey] = accessToken;
    revokeAccess[kTokenTypeHintKey] = 'access_token';

    // Retrieve the client ID and secret.
    String clientId = _grant.identifier;
    String clientSecret = _grant.secret;

    // TODO(bkonyi) handle cases where clientSecret isn't used.
    String userInfo = '$clientId:$clientSecret';

    Uri path = Uri
        .parse(r'https://www.reddit.com/api/v1/revoke_token')
        .replace(userInfo: userInfo);

    Map<String, String> headers = new Map<String, String>();
    headers[kUserAgentKey] = _userAgent;

    http.Client httpClient = new http.Client();

    // Request the token from the server.
    http.Response response = await httpClient.post(
        path.replace(userInfo: userInfo),
        headers: headers,
        body: revokeAccess);

    if (response.statusCode != 204) {
      // TODO(bkonyi) throw an error since we should always get a 204 response.
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

  // Request data from Reddit using our OAuth2 client.
  //
  // [type] can be one of `GET`, `POST`, and `PUT`. [path] represents the
  // request parameters. [body] is an optional parameter which contains the
  // body fields for a POST request.
  Future<Map> _request(String type, Uri path,
      [Map<String, String> body]) async {
    if (_client == null) {
      throw new DRAWAuthenticationError(
          'The authenticator does not have a valid token.');
    }
    if (!isValid) {
      refresh();
    }
    http.Request request = new http.Request(type, path);
    if (body != null) {
      request.bodyFields = body;
    }
    final http.StreamedResponse response = await _client.send(request);
    Map parsed = JSON.decode(await response.stream.bytesToString());
    if (parsed.containsKey(kErrorKey)) {
      _throwAuthenticationError(parsed);
    }
    return parsed;
  }

  // Requests the authentication token from Reddit based on parameters provided
  // in [accountInfo] and [_grant].
  Future _requestToken(Map<String, String> accountInfo) async {
    // Retrieve the client ID and secret.
    String clientId = _grant.identifier;
    String clientSecret = _grant.secret;

    // TODO(bkonyi) handle cases where clientSecret isn't used.
    String userInfo = '$clientId:$clientSecret';
    http.Client httpClient = new http.Client();
    DateTime start = new DateTime.now();

    Map<String, String> headers = new Map<String, String>();
    headers[kUserAgentKey] = _userAgent;

    // Request the token from the server.
    http.Response response = await httpClient.post(
        _grant.tokenEndpoint.replace(userInfo: userInfo),
        headers: headers,
        body: accountInfo);

    // Check for error response.
    Map responseMap = JSON.decode(response.body);
    if (responseMap.containsKey(kErrorKey)) {
      _throwAuthenticationError(responseMap);
    }

    // Create the Credentials object from the authentication token.
    oauth2.Credentials credentials = handleAccessTokenResponse(
        response, _grant.tokenEndpoint, start, ['*'], ',');

    // Generate the OAuth2 client that will be used to query Reddit servers.
    _client = new oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret, httpClient: httpClient);
  }

  void _throwAuthenticationError(Map response) {
    String statusCode = response[kErrorKey];
    String reason = response[kMessageKey];
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
  /// [revoke()] has been called, or the access token has expired.
  bool get isValid {
    return !(credentials?.isExpired ?? true);
  }

  oauth2.AuthorizationCodeGrant _grant;
  oauth2.Client _client;
  String _userAgent;
}

/// The [ScriptAuthenticator] class allows for the creation of an [Authenticator]
/// instance which is associated with a valid Reddit user account. This is to be
/// used with the 'Script' app type credentials. Refer to
/// https://github.com/reddit/reddit/wiki/OAuth2-App-Types for descriptions of
/// valid app types.
class ScriptAuthenticator extends Authenticator {
  static Future<ScriptAuthenticator> Create(oauth2.AuthorizationCodeGrant grant,
      String userAgent, String username, String password) async {
    ScriptAuthenticator authenticator =
        new ScriptAuthenticator._(grant, userAgent, username, password);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  ScriptAuthenticator._(oauth2.AuthorizationCodeGrant grant, String userAgent,
      String username, String password)
      : _username = username,
        _password = password,
        super(grant, userAgent);

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future _authenticationFlow() async {
    Map<String, String> accountInfo = new Map<String, String>();
    accountInfo[kUsernameKey] = _username;
    accountInfo[kPasswordKey] = _password;
    accountInfo[kGrantTypeKey] = 'password';
    accountInfo[kDurationKey] = 'permanent';
    await _requestToken(accountInfo);
  }

  String _username;
  String _password;
}

/// The [ReadOnlyAuthenticator] class allows for the creation of an [Authenticator]
/// instance which is not associated with any reddit account. As the name
/// implies, the [ReadOnlyAuthenticator] can only be used to make read-only
/// requests to the Reddit API that do not require access to a valid Reddit user
/// account. Refer to https://github.com/reddit/reddit/wiki/OAuth2-App-Types for
/// descriptions of valid app types.
class ReadOnlyAuthenticator extends Authenticator {
  static Future<ReadOnlyAuthenticator> Create(
      oauth2.AuthorizationCodeGrant grant, String userAgent) async {
    ReadOnlyAuthenticator authenticator =
        new ReadOnlyAuthenticator._(grant, userAgent);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  ReadOnlyAuthenticator._(oauth2.AuthorizationCodeGrant grant, String userAgent)
      : super(grant, userAgent);

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future _authenticationFlow() async {
    Map<String, String> accountInfo = new Map<String, String>();
    accountInfo[kGrantTypeKey] = 'client_credentials';
    await _requestToken(accountInfo);
  }
}
