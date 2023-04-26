import 'package:ably_flutter/ably_flutter.dart';

/// Creates Ably [TokenRequest] objects and obtains Ably Tokens from Ably to
/// subsequently issue to less trusted clients.
abstract class Auth {
  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes.
  ///
  /// The `clientId` can be any non-empty string, except it cannot contain a
  /// `*`. This option is primarily intended to be used in situations where the
  /// library is instantiated with a key. Note that a `clientId` may also be
  /// implicit in a token used to instantiate the library. An error is raised if
  /// a `clientId` specified here conflicts with the `clientId` implicit in the
  /// token. Find out more about [identified clients](https://ably.com/docs/core-features/authentication#identified-clients).
  Future<String?> get clientId;

  /// Instructs the library to get a new token immediately using [tokenParams]
  /// and [authOptions] parameters.
  ///
  /// When using the realtime client, it upgrades the current realtime
  /// connection to use the new token, or if not connected, initiates a
  /// connection to Ably, once the new token has been obtained. Also stores any
  /// [tokenParams] and [authOptions] passed in as the new defaults, to be used
  /// for all subsequent implicit or explicit token requests. Any [tokenParams]
  /// and [authOptions] objects passed in entirely replace, as opposed to being
  /// merged with, the current client library saved values. Returns a
  /// [TokenDetails] object.
  Future<TokenDetails> authorize({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });

  /// Creates, signs and returns an Ably [TokenRequest] based on the specified
  /// (or if none specified, the client library stored) [tokenParams] and
  /// [authOptions]. Note this can only be used when the API `key` value is
  /// available locally. Otherwise, the Ably [TokenRequest] must be obtained
  /// from the key owner.
  ///
  /// Use this to generate an Ably [TokenRequest] in order to implement an Ably
  /// Token request callback for use by other clients. Both [tokenParams] and
  /// [authOptions] are optional. When omitted or `null`, the default token
  /// parameters and authentication options for the client library are used, as
  /// specified in the [ClientOptions] when the client library was instantiated,
  /// or later updated with an explicit `authorize` request. Values passed in
  /// are used instead of, rather than being merged with, the default
  /// values. To understand why an Ably [TokenRequest] may be issued to clients
  /// in favor of a token, see [Token Authentication explained](https://ably.com/docs/core-features/authentication/#token-authentication).
  Future<TokenRequest> createTokenRequest({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });

  /// Calls the `requestToken` REST API endpoint to obtain an Ably Token
  /// according to the specified [tokenParams] and [authOptions]. Both
  /// [tokenParams] and [authOptions] are optional. Returns a [TokenDetails]
  /// object.
  ///
  /// When [tokenParams] or [authOptions] are omitted or `null`, the default
  /// token parameters and authentication options for the client
  /// library are used, as specified in the [ClientOptions] when the client
  /// library was instantiated, or later updated with an explicit `authorize`
  /// request. Values passed in are used instead of, rather than being merged
  /// with, the default values. To understand why an Ably [TokenRequest] may be
  /// issued to clients in favor of a token, see
  /// [Token Authentication explained](https://ably.com/docs/core-features/authentication/#token-authentication).
  Future<TokenDetails> requestToken({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });
}
