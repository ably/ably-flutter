import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

class RealtimeAuth extends Auth {
  final Realtime realtime;

  RealtimeAuth(this.realtime);

  @override
  Future<TokenDetails?> authorize(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      realtime.invoke<TokenDetails>(PlatformMethod.realtimeAuthAuthorize, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<String?> get clientId async =>
      realtime.invoke<String>(PlatformMethod.realtimeAuthGetClientId);

  @override
  Future<TokenRequest?> createTokenRequest(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      realtime.invoke<TokenRequest>(
          PlatformMethod.realtimeAuthCreateTokenRequest, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });

  @override
  Future<TokenDetails?> requestToken(
          {AuthOptions? authOptions, TokenParams? tokenParams}) =>
      realtime.invoke<TokenDetails>(PlatformMethod.realtimeAuthRequestToken, {
        TxTransportKeys.options: authOptions,
        TxTransportKeys.params: tokenParams
      });
}
