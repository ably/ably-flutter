

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

<<<<<<< HEAD
/// See [Auth] for more information.
class RestAuth extends Auth {
  final Rest _rest;

  /// Constructor for RestAuth
  RestAuth(this._rest);

  @override
  Future<TokenDetails?> authorize(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invoke<TokenDetails>(PlatformMethod.restAuthAuthorize, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<String?> get clientId async =>
      _rest.invoke<String>(PlatformMethod.restAuthGetClientId);

  @override
  Future<TokenRequest?> createTokenRequest(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invoke<TokenRequest>(PlatformMethod.restAuthCreateTokenRequest, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<TokenDetails?> requestToken(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invoke<TokenDetails>(PlatformMethod.restAuthRequestToken, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });
}
=======
class RestAuth extends Auth{

  final Rest rest;
  RestAuth(this.rest);

  @override
  Future<TokenDetails?> authorize({AuthOptions? authOptions, TokenParams?
  tokenParams}) => rest.invoke<TokenDetails>(PlatformMethod
        .restAuthAuthorize, {
      TxTransportKeys.options: authOptions,
      TxTransportKeys.params: tokenParams
    });

  @override
  Future<String?> get clientId async => await rest.invoke<String>(PlatformMethod
      .restAuthGetClientId);

  @override
  Future<TokenRequest?> createTokenRequest({AuthOptions? authOptions,
    TokenParams? tokenParams}) => rest.invoke<TokenRequest>(PlatformMethod
        .restAuthCreateTokenRequest, {
      TxTransportKeys.options: authOptions,
      TxTransportKeys.params: tokenParams
    });

  @override
  Future<TokenDetails?> requestToken({AuthOptions? authOptions, TokenParams?
  tokenParams}) => rest.invoke<TokenDetails>(PlatformMethod
        .restAuthRequestToken, {
      TxTransportKeys.options: authOptions,
      TxTransportKeys.params: tokenParams
    });
}
>>>>>>> parent of 179e43f0 (Code style and formatting changes)
