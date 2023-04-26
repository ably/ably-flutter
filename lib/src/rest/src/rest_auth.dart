import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// See [Auth] for more information.
class RestAuth extends Auth {
  final Rest _rest;

  /// Constructor for RestAuth
  RestAuth(this._rest);

  @override
  Future<TokenDetails> authorize(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invokeRequest<TokenDetails>(PlatformMethod.restAuthAuthorize, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<String?> get clientId async =>
      _rest.invoke<String>(PlatformMethod.restAuthGetClientId);

  @override
  Future<TokenRequest> createTokenRequest(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invokeRequest<TokenRequest>(
          PlatformMethod.restAuthCreateTokenRequest, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<TokenDetails> requestToken(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      _rest.invokeRequest<TokenDetails>(PlatformMethod.restAuthRequestToken, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });
}
