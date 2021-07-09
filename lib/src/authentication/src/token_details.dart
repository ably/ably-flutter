/// Response to a `requestToken` request
///
/// https://docs.ably.com/client-lib-development-guide/features/#TD1
class TokenDetails {
  /// https://docs.ably.com/client-lib-development-guide/features/#TD2
  String? token;

  /// Token expiry time in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD3
  int? expires;

  /// the time the token was issued in milliseconds
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD4
  int? issued;

  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD5
  String? capability;

  /// Client ID assigned to the token.
  ///
  /// If [clientId] is not set (i.e. null), then the token is prohibited
  /// from assuming a clientId in any operations, however if clientId
  /// is a wildcard string '*', then the token is permitted to assume
  /// any clientId. Any other string value for clientId implies that the
  /// clientId is both enforced and assumed for all operations for this token
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD6
  String? clientId;

  /// instantiates a [TokenDetails] with provided values
  TokenDetails(
    this.token, {
    this.expires,
    this.issued,
    this.capability,
    this.clientId,
  });

  /// Creates an instance from the map
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TD7
  TokenDetails.fromMap(Map<String, dynamic> map) {
    token = map['token'] as String?;
    expires = map['expires'] as int?;
    issued = map['issued'] as int?;
    capability = map['capability'] as String?;
    clientId = map['clientId'] as String?;
  }
}
