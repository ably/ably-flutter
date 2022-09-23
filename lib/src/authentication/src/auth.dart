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
  Future<TokenDetails> requestToken({
    AuthOptions? authOptions,
    TokenParams? tokenParams,
  });
}
