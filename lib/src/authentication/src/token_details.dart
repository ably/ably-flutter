import 'package:flutter/material.dart';

/// Response to a `requestToken` request
///
/// https://docs.ably.com/client-lib-development-guide/features/#TD1
@immutable
class TokenDetails {
  /// https://docs.ably.com/client-lib-development-guide/features/#TD2
  final String? token;

  /// Token expiry time in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD3
  final int? expires;

  /// the time the token was issued in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD4
  final int? issued;

  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD5
  final String? capability;

  /// Client ID assigned to the token.
  ///
  /// If [clientId] is not set (i.e. null), then the token is prohibited
  /// from assuming a clientId in any operations, however if clientId
  /// is a wildcard string '*', then the token is permitted to assume
  /// any clientId. Any other string value for clientId implies that the
  /// clientId is both enforced and assumed for all operations for this token
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD6
  final String? clientId;

  /// instantiates a [TokenDetails] with provided values
  const TokenDetails(
    this.token, {
    this.capability,
    this.clientId,
    this.expires,
    this.issued,
  });

  /// Creates an instance from the map
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD7
  TokenDetails.fromMap(Map<String, dynamic> map)
      : capability = map['capability'] as String?,
        clientId = map['clientId'] as String?,
        expires = map['expires'] as int?,
        issued = map['issued'] as int?,
        token = map['token'] as String?;
}
