import 'package:ably_flutter/src/authentication/authentication.dart';

/// [Auth] object provides a way to create [TokenRequest] objects
/// with [createTokenRequest] method or create Ably Tokens with
/// [requestToken] method.
///
/// https://www.ably.com/documentation/core-features/authentication#auth-object
abstract class Auth {
  /// The clientId for this library instance
  ///
  /// see:
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA12
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA7b
  String get clientId;

  /// Instructs the library to create a token immediately and ensures
  /// Token Auth is used for all future requests
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA10
  Future<TokenDetails> authorize({
    TokenParams? tokenParams,
    AuthOptions? authOptions,
  });

  /// Returns a signed TokenRequest object that can be used to obtain
  /// a token from Ably.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA9
  Future<TokenRequest> createTokenRequest({
    TokenParams? tokenParams,
    AuthOptions? authOptions,
  });

  /// Implicitly creates a TokenRequest if required and requests a token
  /// from Ably if required. Returns a [TokenDetails] object.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA8
  Future<TokenDetails> requestToken({
    TokenParams? tokenParams,
    AuthOptions? authOptions,
  });
}
