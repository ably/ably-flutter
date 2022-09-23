import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Response to a `requestToken` request
///
/// https://docs.ably.com/client-lib-development-guide/features/#TD1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains an Ably Token and its associated metadata.
/// END CANONICAL DOCSTRING
@immutable
class TokenDetails {
  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TD2
  /// END LEGACY DOCSTRING
  final String? token;

  /// BEGIN LEGACY DOCSTRING
  /// Token expiry time in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD3
  /// END LEGACY DOCSTRING
  final int? expires;

  /// BEGIN LEGACY DOCSTRING
  /// the time the token was issued in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD4
  /// END LEGACY DOCSTRING
  final int? issued;

  /// BEGIN LEGACY DOCSTRING
  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD5
  /// END LEGACY DOCSTRING
  final String? capability;

  /// BEGIN LEGACY DOCSTRING
  /// Client ID assigned to the token.
  ///
  /// If [clientId] is not set (i.e. null), then the token is prohibited
  /// from assuming a clientId in any operations, however if clientId
  /// is a wildcard string '*', then the token is permitted to assume
  /// any clientId. Any other string value for clientId implies that the
  /// clientId is both enforced and assumed for all operations for this token
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD6
  /// END LEGACY DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates a [TokenDetails] with provided values
  /// END LEGACY DOCSTRING
  const TokenDetails(
    this.token, {
    this.capability,
    this.clientId,
    this.expires,
    this.issued,
  });

  /// BEGIN LEGACY DOCSTRING
  /// Creates an instance from the map
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD7
  /// END LEGACY DOCSTRING
  TokenDetails.fromMap(Map<String, dynamic> map)
      : capability = map['capability'] as String?,
        clientId = map['clientId'] as String?,
        expires = map['expires'] as int?,
        issued = map['issued'] as int?,
        token = map['token'] as String?;
}
