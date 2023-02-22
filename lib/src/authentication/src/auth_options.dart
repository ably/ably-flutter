import 'package:ably_flutter/ably_flutter.dart';

/// Passes authentication-specific properties in authentication requests to
/// Ably.
///
/// Properties set using `AuthOptions` are used instead of the default
/// values set when the client library is instantiated, as opposed to being
/// merged with them.
class AuthOptions {
  /// Called when a new token is required.
  ///
  /// The role of the callback is to obtain a fresh token, one of: an Ably Token
  /// string (in plain text format); a signed [TokenRequest]; a [TokenDetails]
  /// (in JSON format); an [Ably JWT](https://ably.com/docs/core-features/authentication#ably-jwt).
  /// See the [authentication documentation](https://ably.com/docs/realtime/authentication)
  /// for details of the Ably [TokenRequest] format and associated API calls.
  AuthCallback? authCallback;

  /// A URL that the library may use to obtain a token string (in plain text
  /// format), or a signed [TokenRequest] or [TokenDetails] (in JSON format)
  /// from.
  String? authUrl;

  /// The HTTP verb to use for any request made to the `authUrl`, either `GET`
  /// or `POST`.
  String? authMethod;

  /// The full API key string, as obtained from the [Ably dashboard](https://ably.com/dashboard).
  ///
  /// Use this option if you wish to use Basic authentication, or wish to be
  /// able to issue Ably Tokens without needing to defer to a separate entity to
  /// sign Ably [TokenRequest]s. Read more about [Basic authentication](https://ably.com/docs/core-features/authentication#basic-authentication).
  String? key;

  /// An authenticated [TokenDetails] object (most commonly obtained from an
  /// Ably Token Request response).
  ///
  /// This option is mostly useful for testing: since tokens are short-lived, in
  /// production you almost always want to use an authentication method that
  /// enables the client library to renew the token automatically when the
  /// previous one expires, such as `authUrl` or `authCallback`. Use this option
  /// if you wish to use Token authentication. Read more about
  /// [Token authentication](https://ably.com/docs/core-features/authentication#token-authentication).
  TokenDetails? tokenDetails;

  /// A set of key-value pair headers to be added to any request made to the
  /// `authUrl`.
  ///
  /// Useful when an application requires these to be added to
  /// validate the request or implement the response. If the `authHeaders`
  /// object contains an `authorization` key, then `withCredentials` is set on
  /// the XHR request.
  Map<String, String>? authHeaders;

  /// A set of key-value pair params to be added to any request made to the
  /// `authUrl`.
  ///
  /// When the `authMethod` is `GET`, query params are added to the
  /// URL, whereas when `authMethod` is `POST`, the params are sent as URL
  /// encoded form data. Useful when an application requires these to be added
  /// to validate the request or implement the response.
  Map<String, String>? authParams;

  /// Whether the library queries the Ably servers for the current time when
  /// issuing [TokenRequest]s instead of relying on a locally-available time of
  /// day.
  ///
  /// Knowing the time accurately is needed to
  /// create valid signed Ably [TokenRequest]s, so this
  /// option is useful for library instances on auth servers where for some
  /// reason the server clock cannot be kept synchronized through normal means,
  /// such as an [NTP daemon](https://en.wikipedia.org/wiki/Ntpd). The server is
  /// queried for the current time once per client library instance (which
  /// stores the offset from the local clock), so if using this option you
  /// should avoid instancing a new version of the library for each request.
  /// The default is `false`.
  bool? queryTime;

  /// Whether library is forced to use token authentication.
  ///
  /// If a `clientId` is not specified in the [ClientOptions] or [TokenParams],
  /// then the Ably Token issued is [anonymous](https://ably.com/docs/core-features/authentication#identified-clients).
  bool? useTokenAuth;

// TODO(tiholic) missing token attribute here
//  see: https://docs.ably.com/client-lib-development-guide/features/#AO2h

  /// @nodoc
  /// Initializes an instance without any defaults
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

  /// @nodoc
  /// Convenience constructor used to create an AuthOptions object based
  /// on the key string obtained from the application dashboard.
  /// param [key] - the full key string as obtained from the dashboard
  @Deprecated("Use AuthOptions constructor with named 'key' parameter instead")
  AuthOptions.fromKey(String key) {
    if (key.contains(':')) {
      this.key = key;
    } else {
      tokenDetails = TokenDetails(key);
    }
  }
}

/// @nodoc
/// Function-type alias implemented by a function that provides either tokens,
/// or signed token requests, in response to a request with given token params.
///
/// Java: io.ably.lib.rest.Auth.TokenCallback.getTokenRequest(TokenParams)
/// returns either a [String] token or [TokenDetails] or [TokenRequest]
typedef AuthCallback = Future<Object> Function(TokenParams params);
