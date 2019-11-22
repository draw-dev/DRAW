// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import "package:oauth2/src/handle_access_token_response.dart";

import 'package:draw/src/draw_config_context.dart';
import 'package:draw/src/exception_objector.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/logging.dart';

const String _kDeleteRequest = 'DELETE';
const String _kGetRequest = 'GET';
const String _kPostRequest = 'POST';
const String _kPutRequest = 'PUT';

const String _kAuthorizationKey = 'Authorization';
const String _kDurationKey = 'duration';
const String _kErrorKey = 'error';
const String _kGrantTypeKey = 'grant_type';
const String _kMessageKey = 'message';
const String _kPasswordKey = 'password';
const String _kTokenKey = 'token';
const String _kTokenTypeHintKey = 'token_type_hint';
const String _kUserAgentKey = 'user-agent';
const String _kUsernameKey = 'username';

final Logger _logger = Logger('Authenticator');

/// The [Authenticator] class provides an interface to interact with the Reddit API
/// using OAuth2. An [Authenticator] is responsible for keeping track of OAuth2
/// credentials, refreshing and revoking access tokens, and issuing HTTPS
/// requests using OAuth2 credentials.
abstract class Authenticator {
  oauth2.AuthorizationCodeGrant _grant;
  oauth2.Client _client;
  final DRAWConfigContext _config;

  Authenticator(DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant)
      : _config = config,
        _grant = grant,
        _client = null;

  Authenticator.restore(
      DRAWConfigContext config, oauth2.Credentials credentials)
      : _config = config,
        _client = oauth2.Client(credentials,
            identifier: config.clientId,
            secret: config.clientSecret,
            httpClient: http.Client());

  /// Not implemented for [Authenticator]s other than [WebAuthenticator].
  Future<void> authorize(String code) async {
    throw DRAWInternalError(
        "'authorize' is only implemented for 'WebAuthenticator'");
  }

  /// Not implemented for [Authenticator]s other than [WebAuthenticator].
  Uri url(List<String> scopes, String state,
      {String duration = 'permanent', bool compactLogin = false}) {
    throw DRAWInternalError("'url' is only implemented for 'WebAuthenticator'");
  }

  /// Request a new access token from the Reddit API. Throws a
  /// [DRAWAuthenticationError] if the [Authenticator] is not yet initialized.
  Future<void> refresh() async {
    if (_client == null) {
      throw DRAWAuthenticationError(
          'cannot refresh uninitialized Authenticator.');
    }
    await _authenticationFlow();
  }

  /// Revokes any outstanding tokens associated with the [Authenticator].
  Future<void> revoke() async {
    if (credentials == null) {
      return;
    }
    final tokens = List<Map>();
    final accessToken = {
      _kTokenKey: credentials.accessToken,
      _kTokenTypeHintKey: 'access_token',
    };
    tokens.add(accessToken);

    if (credentials.refreshToken != null) {
      final refreshToken = {
        _kTokenKey: credentials.refreshToken,
        _kTokenTypeHintKey: 'refresh_token',
      };
      tokens.add(refreshToken);
    }
    for (final token in tokens) {
      final revokeAccess = Map<String, String>();
      revokeAccess[_kTokenKey] = token[_kTokenKey];
      revokeAccess[_kTokenTypeHintKey] = token[_kTokenTypeHintKey];

      var path = Uri.parse(_config.revokeToken);

      // Retrieve the client ID and secret.
      final clientId = _config.clientId;
      final clientSecret = _config.clientSecret;

      if ((clientId != null) && (clientSecret != null)) {
        final userInfo = '$clientId:$clientSecret';
        path = path.replace(userInfo: userInfo);
      }
      final headers = Map<String, String>();
      headers[_kUserAgentKey] = _config.userAgent;

      final httpClient = http.Client();

      // Request the token from the server.
      final response =
          await httpClient.post(path, headers: headers, body: revokeAccess);

      if (response.statusCode != 204) {
        // We should always get a 204 response for this call.
        final parsed = json.decode(response.body);
        _throwAuthenticationError(parsed);
      }
    }
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate. All classes inheriting from
  /// [Authenticator] must implement this method.
  Future<void> _authenticationFlow();

  /// Make a simple `GET` request.
  ///
  /// [path] is the destination URI that the request will be made to.
  Future<dynamic> get(Uri path,
      {Map<String, String> params, bool followRedirects = false}) async {
    _logger.info('GET: $path params: ${DRAWLoggingUtils.jsonify(params)}');
    return _request(_kGetRequest, path,
        params: params, followRedirects: followRedirects);
  }

  /// Make a simple `POST` request.
  ///
  /// [path] is the destination URI and [body] contains the POST parameters
  /// that will be sent with the request.
  Future<dynamic> post(Uri path, Map<String, String> body,
      {Map<String, Uint8List> files, Map params}) async {
    _logger.info('POST: $path body: ${DRAWLoggingUtils.jsonify(body)}');
    return _request(_kPostRequest, path,
        body: body, files: files, params: params);
  }

  /// Make a simple `PUT` request.
  ///
  /// [path] is the destination URI and [body] contains the PUT parameters that
  /// will be sent with the request.
  Future<dynamic> put(Uri path, {Map<String, String> body}) async {
    _logger.info('PUT: $path body: ${DRAWLoggingUtils.jsonify(body)}');
    return _request(_kPutRequest, path, body: body);
  }

  /// Make a simple `DELETE` request.
  ///
  /// [path] is the destination URI and [body] contains the DELETE parameters
  /// that will be sent with the request.
  Future<dynamic> delete(Uri path, {Map<String, String> body}) async {
    _logger.info('DELETE: $path body: ${DRAWLoggingUtils.jsonify(body)}');
    return _request(_kDeleteRequest, path, body: body);
  }

  /// Request data from Reddit using our OAuth2 client.
  ///
  /// [type] can be one of `GET`, `POST`, and `PUT`. [path] represents the
  /// request parameters. [body] is an optional parameter which contains the
  /// body fields for a POST request.
  Future<dynamic> _request(String type, Uri path,
      {Map<String, String> body,
      Map<String, String> params,
      Map<String, Uint8List> files,
      bool followRedirects = false}) async {
    if (_client == null) {
      throw DRAWAuthenticationError(
          'The authenticator does not have a valid token.');
    }
    if (!isValid) {
      await refresh();
    }
    final finalPath = path.replace(queryParameters: params);
    final request = http.MultipartRequest(type, finalPath);

    // Some API requests initiate a redirect (i.e., random submission from a
    // subreddit) but the redirect doesn't forward the OAuth credentials
    // automatically. We disable redirects here and throw a DRAWRedirectResponse
    // so that we can handle the redirect manually on a case-by-case basis.
    request.followRedirects = followRedirects;

    if (body != null) {
      request.fields.addAll(body);
    }
    if (files != null) {
      request.files.addAll([
        for (final key in files.keys)
          http.MultipartFile.fromBytes(key, files[key], filename: 'filename')
      ]);
    }
    http.StreamedResponse responseStream;
    try {
      responseStream = await _client.send(request);
    } on oauth2.AuthorizationException catch (e) {
      throw DRAWAuthenticationError('$e');
    }
    if (responseStream.isRedirect) {
      var redirectStr = Uri.parse(responseStream.headers['location']).path;
      if (redirectStr.endsWith('.json')) {
        redirectStr = redirectStr.substring(0, redirectStr.length - 5);
      }
      throw DRAWRedirectResponse(redirectStr, responseStream);
    }
    final response = await responseStream.stream.bytesToString();
    if (response.isEmpty) return null;
    final parsed = json.decode(response);
    if ((parsed is Map) && responseStream.statusCode >= 400) {
      parseAndThrowError(responseStream.statusCode, parsed);
    }
    if ((parsed is Map) && parsed.containsKey(_kErrorKey)) {
      _throwAuthenticationError(parsed);
    }
    _logger.finest('RESPONSE: ${DRAWLoggingUtils.jsonify(parsed)}');
    return parsed;
  }

  /// Requests the authentication token from Reddit based on parameters provided
  /// in [accountInfo] and [_grant].
  Future<void> _requestToken(Map<String, String> accountInfo) async {
    // Retrieve the client ID and secret.
    final clientId = _grant.identifier;
    final clientSecret = _grant.secret;
    String userInfo;

    if ((clientId != null) && (clientSecret != null)) {
      userInfo = '$clientId:$clientSecret';
    }

    final httpClient = http.Client();
    final start = DateTime.now();
    final headers = Map<String, String>();
    headers[_kUserAgentKey] = _config.userAgent;

    // Request the token from the server.
    final response = await httpClient.post(
        _grant.tokenEndpoint.replace(userInfo: userInfo),
        headers: headers,
        body: accountInfo);

    // Check for error response.
    final responseMap = json.decode(response.body);
    if (responseMap.containsKey(_kErrorKey)) {
      _throwAuthenticationError(responseMap);
    }

    // Create the Credentials object from the authentication token.
    final credentials = handleAccessTokenResponse(
        response, _grant.tokenEndpoint, start, ['*'], ',');

    // Generate the OAuth2 client that will be used to query Reddit servers.
    _client = oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret, httpClient: httpClient);
  }

  void _throwAuthenticationError(Map response) {
    final statusCode = response[_kErrorKey];
    final reason = response[_kMessageKey];
    throw DRAWAuthenticationError(
        'Status Code: ${statusCode} Reason: ${reason}');
  }

  Future<void> _requestTokenUntrusted(Map<String, String> accountInfo) async {
    // Retrieve the client ID and secret.
    final clientId = _grant.identifier;

    final httpClient = http.Client();
    final start = DateTime.now();
    final headers = Map<String, String>();
    headers[_kUserAgentKey] = _config.userAgent;
    headers[_kAuthorizationKey] =
        'Basic ${base64Encode((clientId + ":").codeUnits)})';

    // Request the token from the server.
    final response = await httpClient.post(_grant.tokenEndpoint,
        headers: headers, body: accountInfo);

    // Check for error response.
    final responseMap = json.decode(response.body);
    if (responseMap.containsKey(_kErrorKey)) {
      _throwAuthenticationError(responseMap);
    }

    // Create the Credentials object from the authentication token.
    final credentials = handleAccessTokenResponse(
        response, _grant.tokenEndpoint, start, ['*'], ',');

    // Generate the OAuth2 client that will be used to query Reddit servers.
    _client = oauth2.Client(credentials,
        identifier: clientId, httpClient: httpClient);
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
  String get userAgent => _config.userAgent;

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
/// used with the 'Script' app type credentials. Refer to Reddit's
/// [documentation](https://github.com/reddit/reddit/wiki/OAuth2-App-Types)
/// for descriptions of valid app types.
class ScriptAuthenticator extends Authenticator {
  ScriptAuthenticator._(
      DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant)
      : super(config, grant);

  static Future<ScriptAuthenticator> create(
      DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant) async {
    final ScriptAuthenticator authenticator =
        ScriptAuthenticator._(config, grant);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future<void> _authenticationFlow() async {
    final accountInfo = Map<String, String>();
    accountInfo[_kUsernameKey] = _config.username;
    accountInfo[_kPasswordKey] = _config.password;
    accountInfo[_kGrantTypeKey] = 'password';
    accountInfo[_kDurationKey] = 'permanent';
    await _requestToken(accountInfo);
  }
}

/// The [ReadOnlyAuthenticator] class allows for the creation of an [Authenticator]
/// instance which is not associated with any reddit account. As the name
/// implies, the [ReadOnlyAuthenticator] can only be used to make read-only
/// requests to the Reddit API that do not require access to a valid Reddit user
/// account. Refer to Reddit's
/// [documentation](https://github.com/reddit/reddit/wiki/OAuth2-App-Types) for
/// descriptions of valid app types.
class ReadOnlyAuthenticator extends Authenticator {
  static const String _kDeviceIdKey = 'device_id';

  final bool _applicationOnlyOAuth;
  final String _deviceId;

  ReadOnlyAuthenticator._(
      DRAWConfigContext config,
      oauth2.AuthorizationCodeGrant grant,
      this._applicationOnlyOAuth,
      this._deviceId)
      : super(config, grant);

  static Future<ReadOnlyAuthenticator> create(
      DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant) async {
    final ReadOnlyAuthenticator authenticator =
        ReadOnlyAuthenticator._(config, grant, false, null);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  static Future<ReadOnlyAuthenticator> createUntrusted(DRAWConfigContext config,
      oauth2.AuthorizationCodeGrant grant, String deviceId) async {
    final ReadOnlyAuthenticator authenticator =
        ReadOnlyAuthenticator._(config, grant, true, deviceId);
    await authenticator._authenticationFlow();
    return authenticator;
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future<void> _authenticationFlow() async {
    final accountInfo = Map<String, String>();
    if (_applicationOnlyOAuth) {
      accountInfo[_kGrantTypeKey] =
          'https://oauth.reddit.com/grants/installed_client';
      accountInfo[_kDeviceIdKey] = _deviceId;
      await _requestTokenUntrusted(accountInfo);
    } else {
      accountInfo[_kGrantTypeKey] = 'client_credentials';
      await _requestToken(accountInfo);
    }
  }
}

/// The [WebAuthenticator] class allows for the creation of an [Authenticator]
/// that exposes functionality which allows for the user to authenticate through
/// a browser. The [url] method is used to generate the URL that the user uses
/// to authenticate on www.reddit.com, and the [authorize] method retrieves the
/// access token given the returned `code`. This is to be
/// used with the 'Web' app type credentials. Refer to Reddit's
/// [documentation](https://github.com/reddit/reddit/wiki/OAuth2-App-Types)
/// for descriptions of valid app types.
class WebAuthenticator extends Authenticator {
  final Uri _redirect;

  WebAuthenticator._(
      DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant)
      : _redirect = Uri.parse(config.redirectUrl),
        super(config, grant) {
    assert(_redirect != null);
  }

  WebAuthenticator._restore(DRAWConfigContext config, String credentialsJson)
      : _redirect =
            (config.redirectUrl != null) ? Uri.parse(config.redirectUrl) : null,
        super.restore(config, oauth2.Credentials.fromJson(credentialsJson));

  static WebAuthenticator create(
          DRAWConfigContext config, oauth2.AuthorizationCodeGrant grant) =>
      WebAuthenticator._(config, grant);

  static WebAuthenticator restore(
          DRAWConfigContext config, String credentialsJson) =>
      WebAuthenticator._restore(config, credentialsJson);

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
  @override
  Uri url(List<String> scopes, String state,
      {String duration = 'permanent', bool compactLogin = false}) {
    // TODO(bkonyi) do we want to add the [implicit] flag to the argument list?
    if (scopes == null) {
      // scopes cannot be null.
      throw DRAWAuthenticationError('Parameter scopes cannot be null.');
    }
    Uri redditAuthUri =
        _grant.getAuthorizationUrl(_redirect, scopes: scopes, state: state);
    if (redditAuthUri == null) {
      throw DRAWAuthenticationError('The Auth URL for Reddit must not be '
          'null');
    }
    // getAuthorizationUrl returns a Uri which is missing the duration field, so
    // we need to add it here.
    final queryParameters =
        Map<String, dynamic>.from(redditAuthUri.queryParameters);
    queryParameters[_kDurationKey] = duration;
    redditAuthUri = redditAuthUri.replace(queryParameters: queryParameters);
    if (compactLogin) {
      String path = redditAuthUri.path;
      path = path.substring(0, path.length) + r'.compact';
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
  @override
  Future<void> authorize(String code) async {
    if (code == null) {
      // code cannot be null.
      throw DRAWAuthenticationError('Parameter code cannot be null.');
    }
    _client = await _grant.handleAuthorizationCode(code);
  }

  /// Initiates the authorization flow. This method should populate a
  /// [Map<String,String>] with information needed for authentication, and then
  /// call [_requestToken] to authenticate.
  @override
  Future<void> _authenticationFlow() async {
    throw UnimplementedError(
        '_authenticationFlow is not used in WebAuthenticator.');
  }

  /// Request a new access token from the Reddit API. Throws a
  /// [DRAWAuthenticationError] if the [Authenticator] is not yet initialized.
  @override
  Future<void> refresh() async {
    if (_client == null) {
      throw DRAWAuthenticationError(
          'cannot refresh uninitialized Authenticator.');
    }
    _client = await _client.refreshCredentials();
  }
}
