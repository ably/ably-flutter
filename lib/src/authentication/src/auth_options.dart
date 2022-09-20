import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// A class providing configurable authentication options used when
/// authenticating or issuing tokens explicitly.
///
/// These options are used when invoking Auth#authorize, Auth#requestToken,
/// Auth#createTokenRequest and Auth#authorize.
///
/// https://docs.ably.com/client-lib-development-guide/features/#AO1
/// END LEGACY DOCSTRING
abstract class AuthOptions {
  /// BEGIN LEGACY DOCSTRING
  /// A function which is called when a new token is required.
  ///
  /// The role of the callback is to either generate a signed [TokenRequest]
  /// which may then be submitted automatically by the library to
  /// the Ably REST API requestToken; or to provide a valid token
  /// as a [TokenDetails] object.
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2b
  /// END LEGACY DOCSTRING
  AuthCallback? authCallback;

  /// BEGIN LEGACY DOCSTRING
  /// A URL that the library may use to obtain
  /// a token String (in plain text format),
  /// or a signed [TokenRequest] or [TokenDetails] (in JSON format).
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2c
  /// END LEGACY DOCSTRING
  String? authUrl;

  /// BEGIN LEGACY DOCSTRING
  /// HTTP Method used when a request is made using authURL
  ///
  /// defaults to 'GET', supports 'GET' and 'POST'
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2d
  /// END LEGACY DOCSTRING
  String? authMethod;

  /// BEGIN LEGACY DOCSTRING
  /// Full Ably key string, as obtained from dashboard,
  /// used when signing token requests locally
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2a
  /// END LEGACY DOCSTRING
  String? key;

  /// BEGIN LEGACY DOCSTRING
  /// An authentication token issued for this application
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2i
  /// END LEGACY DOCSTRING
  TokenDetails? tokenDetails;

  /// BEGIN LEGACY DOCSTRING
  /// Headers to be included in any request made to the [authUrl]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2e
  /// END LEGACY DOCSTRING
  Map<String, String>? authHeaders;

  /// BEGIN LEGACY DOCSTRING
  /// Additional params to be included in any request made to the [authUrl]
  ///
  /// As query params in the case of GET
  /// and as form-encoded in the body in the case of POST
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2f
  /// END LEGACY DOCSTRING
  Map<String, String>? authParams;

  /// BEGIN LEGACY DOCSTRING
  /// If true, the library will when issuing a token request query
  /// the Ably system for the current time instead of relying on a
  /// locally-available time of day.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2g
  /// END LEGACY DOCSTRING
  bool? queryTime;

  /// BEGIN LEGACY DOCSTRING
  /// Token Auth is used if useTokenAuth is set to true
  ///
  /// or if useTokenAuth is unspecified and any one of
  /// [authUrl], [authCallback], token, or [TokenDetails] is provided
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA4
  /// END LEGACY DOCSTRING
  bool? useTokenAuth;

// TODO(tiholic) missing token attribute here
//  see: https://docs.ably.com/client-lib-development-guide/features/#AO2h

  /// BEGIN LEGACY DOCSTRING
  /// Initializes an instance without any defaults
  /// END LEGACY DOCSTRING
  AuthOptions({
    this.authCallback,
    this.authHeaders,
    this.authMethod,
    this.authParams,
    this.authUrl,
    this.key,
    this.queryTime,
    this.tokenDetails,
    this.useTokenAuth,
  }) {
    if (key != null && !key!.contains(':')) {
      tokenDetails = TokenDetails(key);
      key = null;
    }
  }

  /// BEGIN LEGACY DOCSTRING
  /// Convenience constructor, to create an AuthOptions based
  /// on the key string obtained from the application dashboard.
  /// param [key]: the full key string as obtained from the dashboard
  /// END LEGACY DOCSTRING
  @Deprecated("Use AuthOptions constructor with named 'key' parameter instead")
  AuthOptions.fromKey(String key) {
    if (key.contains(':')) {
      this.key = key;
    } else {
      tokenDetails = TokenDetails(key);
    }
  }
}

/// BEGIN LEGACY DOCSTRING
/// Function-type alias implemented by a function that provides either tokens,
/// or signed token requests, in response to a request with given token params.
///
/// Java: io.ably.lib.rest.Auth.TokenCallback.getTokenRequest(TokenParams)
/// returns either a [String] token or [TokenDetails] or [TokenRequest]
/// END LEGACY DOCSTRING
typedef AuthCallback = Future<Object> Function(TokenParams params);
