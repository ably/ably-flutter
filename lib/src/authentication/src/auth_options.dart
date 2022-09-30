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

/// BEGIN EDITED CANONICAL DOCSTRING
/// Passes authentication-specific properties in authentication requests to
/// Ably. Properties set using `AuthOptions` are used instead of the default
/// values set when the client library is instantiated, as opposed to being
/// merged with them.
/// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Called when a new token is required. The role of the callback is to obtain
  /// a fresh token, one of: an Ably Token string (in plain text format);
  /// a signed [TokenRequest]; a [TokenDetails] (in JSON format); an
  /// [Ably JWT](https://ably.com/docs/core-features/authentication#ably-jwt).
  /// See the [authentication documentation](https://ably.com/docs/realtime/authentication)
  /// for details of the Ably [TokenRequest] format and associated API calls.
  /// END EDITED CANONICAL DOCSTRING
  AuthCallback? authCallback;

  /// BEGIN LEGACY DOCSTRING
  /// A URL that the library may use to obtain
  /// a token String (in plain text format),
  /// or a signed [TokenRequest] or [TokenDetails] (in JSON format).
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2c
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A URL that the library may use to obtain a token string (in plain text
  /// format), or a signed [TokenRequest] or [TokenDetails] (in JSON format)
  /// from.
  /// END EDITED CANONICAL DOCSTRING
  String? authUrl;

  /// BEGIN LEGACY DOCSTRING
  /// HTTP Method used when a request is made using authURL
  ///
  /// defaults to 'GET', supports 'GET' and 'POST'
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2d
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The HTTP verb to use for any request made to the `authUrl`, either `GET`
  /// or `POST`.
  /// END EDITED CANONICAL DOCSTRING
  String? authMethod;

  /// BEGIN LEGACY DOCSTRING
  /// Full Ably key string, as obtained from dashboard,
  /// used when signing token requests locally
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2a
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The full API key string, as obtained from the [Ably dashboard](https://ably.com/dashboard).
  /// Use this option if you wish to use Basic authentication, or wish to be
  /// able to issue Ably Tokens without needing to defer to a separate entity to
  /// sign Ably [TokenRequest]s. Read more about [Basic authentication](https://ably.com/docs/core-features/authentication#basic-authentication).
  /// END EDITED CANONICAL DOCSTRING
  String? key;

  /// BEGIN LEGACY DOCSTRING
  /// An authentication token issued for this application
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2i
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An authenticated [TokenDetails] object (most commonly obtained from an
  /// Ably Token Request response). This option is mostly useful for testing:
  /// since tokens are short-lived, in production you almost always want to use
  /// an authentication method that enables the client library to renew the
  /// token automatically when the previous one expires, such as `authUrl` or
  /// `authCallback`. Use this option if you wish to use Token authentication.
  /// Read more about [Token authentication](https://ably.com/docs/core-features/authentication#token-authentication).
  /// END EDITED CANONICAL DOCSTRING
  TokenDetails? tokenDetails;

  /// BEGIN LEGACY DOCSTRING
  /// Headers to be included in any request made to the [authUrl]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2e
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A set of key-value pair headers to be added to any request made to the
  /// `authUrl`. Useful when an application requires these to be added to
  /// validate the request or implement the response. If the `authHeaders`
  /// object contains an `authorization` key, then `withCredentials` is set on
  /// the XHR request.
  /// END EDITED CANONICAL DOCSTRING
  Map<String, String>? authHeaders;

  /// BEGIN LEGACY DOCSTRING
  /// Additional params to be included in any request made to the [authUrl]
  ///
  /// As query params in the case of GET
  /// and as form-encoded in the body in the case of POST
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2f
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A set of key-value pair params to be added to any request made to the
  /// `authUrl`. When the `authMethod` is `GET`, query params are added to the
  /// URL, whereas when `authMethod` is `POST`, the params are sent as URL
  /// encoded form data. Useful when an application requires these to be added
  /// to validate the request or implement the response.
  /// END EDITED CANONICAL DOCSTRING
  Map<String, String>? authParams;

  /// BEGIN LEGACY DOCSTRING
  /// If true, the library will when issuing a token request query
  /// the Ably system for the current time instead of relying on a
  /// locally-available time of day.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#AO2g
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether the library queries the Ably servers for the current time when
  /// issuing [TokenRequest]s instead of relying on a locally-available time of
  /// day. Knowing the time accurately is needed to
  /// create valid signed Ably [TokenRequests], so this
  /// option is useful for library instances on auth servers where for some
  /// reason the server clock cannot be kept synchronized through normal means,
  /// such as an [NTP daemon](https://en.wikipedia.org/wiki/Ntpd). The server is
  /// queried for the current time once per client library instance (which
  /// stores the offset from the local clock), so if using this option you
  /// should avoid instancing a new version of the library for each request.
  /// The default is `false`.
  /// END EDITED CANONICAL DOCSTRING
  bool? queryTime;

  /// BEGIN LEGACY DOCSTRING
  /// Token Auth is used if useTokenAuth is set to true
  ///
  /// or if useTokenAuth is unspecified and any one of
  /// [authUrl], [authCallback], token, or [TokenDetails] is provided
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// When `true`, forces token authentication to be used by the library. If a
  /// `clientId` is not specified in the [ClientOptions] or
  /// [TokenParams], then the Ably Token issued is [anonymous](https://ably.com/docs/core-features/authentication#identified-clients).
  /// END EDITED CANONICAL DOCSTRING
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
