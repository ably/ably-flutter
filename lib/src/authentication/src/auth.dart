import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// [Auth] object provides a way to create [TokenRequest] objects
/// with [createTokenRequest] method or create Ably Tokens with
/// [requestToken] method.
///
/// https://www.ably.com/documentation/core-features/authentication#auth-object
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Creates Ably [TokenRequest]{@link TokenRequest} objects and obtains Ably
/// Tokens from Ably to subsequently issue to less trusted clients.
/// END CANONICAL DOCSTRING
abstract class Auth {
  /// BEGIN LEGACY DOCSTRING
  /// The clientId for this library instance
  ///
  /// see:
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA12
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA7b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes. The clientId can be any non-empty string, except it
  /// cannot contain a *. This option is primarily intended to be used in
  /// situations where the library is instantiated with a key. Note that a
  /// clientId may also be implicit in a token used to instantiate the library.
  /// An error is raised if a clientId specified here conflicts with the
  /// clientId implicit in the token. Find out more about
  /// [identified clients](https://ably.com/docs/core-features/authentication#identified-clients).
  /// END CANONICAL DOCSTRING
  String get clientId;

  /// BEGIN LEGACY DOCSTRING
  /// Instructs the library to create a token immediately and ensures
  /// Token Auth is used for all future requests
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA10
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Instructs the library to get a new token immediately. When using the
  /// realtime client, it upgrades the current realtime connection to use the
  /// new token, or if not connected, initiates a connection to Ably, once the
  /// new token has been obtained. Also stores any
  /// [TokenParams]{@link TokenParams} and [AuthOptions]{@link AuthOptions}
  /// passed in as the new defaults, to be used for all subsequent implicit or
  /// explicit token requests. Any [TokenParams]{@link TokenParams} and
  /// [AuthOptions]{@link AuthOptions} objects passed in entirely replace, as
  /// opposed to being merged with, the current client library saved values.
  ///
  /// [TokenParams] - A [TokenParams]{@link TokenParams} object.
  /// [AuthOptions] - An [AuthOptions]{@link AuthOptions} object.
  ///
  /// [TokenDetails] - A [TokenDetails]{@link TokenDetails} object.
  /// END CANONICAL DOCSTRING
  Future<TokenDetails> authorize({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });

  /// BEGIN LEGACY DOCSTRING
  /// Returns a signed TokenRequest object that can be used to obtain
  /// a token from Ably.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA9
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Creates and signs an Ably [TokenRequest]{@link TokenRequest} based on the
  /// specified (or if none specified, the client library stored)
  /// [TokenParams]{@link TokenParams} and [AuthOptions]{@link AuthOptions}.
  /// Note this can only be used when the API key value is available locally.
  /// Otherwise, the Ably [TokenRequest]{@link TokenRequest} must be obtained
  /// from the key owner. Use this to generate an Ably
  /// [TokenRequest]{@link TokenRequest} in order to implement an Ably Token
  /// request callback for use by other clients. Both
  /// [TokenParams]{@link TokenParams} and [AuthOptions]{@link AuthOptions}
  /// are optional. When omitted or null, the default token parameters and
  /// authentication options for the client library are used, as specified in
  /// the [ClientOptions]{@link ClientOptions} when the client library was
  /// instantiated, or later updated with an explicit authorize request. Values
  /// passed in are used instead of, rather than being merged with, the default
  /// values. To understand why an Ably [TokenRequest]{@link TokenRequest} may
  /// be issued to clients in favor of a token, see
  /// [Token Authentication explained](https://ably.com/docs/core-features/authentication/#token-authentication).
  ///
  /// [TokenParams] - A [TokenParams]{@link TokenParams} object.
  /// [AuthOptions] - An [AuthOptions]{@link AuthOptions} object.
  ///
  /// [TokenRequest] - 	A [TokenRequest]{@link TokenRequest} object.
  /// END CANONICAL DOCSTRING
  Future<TokenRequest> createTokenRequest({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });

  /// BEGIN LEGACY DOCSTRING
  /// Implicitly creates a TokenRequest if required and requests a token
  /// from Ably if required. Returns a [TokenDetails] object.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA8
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Calls the requestToken REST API endpoint to obtain an Ably Token according
  /// to the specified [TokenParams]{@link TokenParams} and
  /// [AuthOptions]{@link AuthOptions}. Both [TokenParams]{@link TokenParams}
  /// and [AuthOptions]{@link AuthOptions} are optional. When omitted or null,
  /// the default token parameters and authentication options for the client
  /// library are used, as specified in the [ClientOptions]{@link ClientOptions}
  /// when the client library was instantiated, or later updated with an
  /// explicit authorize request. Values passed in are used instead of, rather
  /// than being merged with, the default values. To understand why an Ably
  /// [TokenRequest]{@link TokenRequest} may be issued to clients in favor of a
  /// token, see [Token Authentication explained](https://ably.com/docs/core-features/authentication/#token-authentication).
  ///
  /// [TokenParams] - A [TokenParams]{@link TokenParams} object.
  /// [AuthOptions] - An [AuthOptions]{@link AuthOptions} object.
  ///
  /// [TokenDetails] - 	A [TokenDetails]{@link TokenDetails} object.
  /// END CANONICAL DOCSTRING
  Future<TokenDetails> requestToken({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });
}
