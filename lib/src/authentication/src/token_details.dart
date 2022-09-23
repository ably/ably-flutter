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

  /// BEGIN CANONICAL DOCSTRING
  /// The timestamp at which this token expires as milliseconds since the Unix
  /// epoch.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// The capabilities associated with this Ably Token. The capabilities value
  /// is a JSON-encoded representation of the resource paths and associated
  /// operations. Read more about capabilities in the
  /// [capabilities docs](https://ably.com/docs/core-features/authentication/#capabilities-explained).
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// The client ID, if any, bound to this Ably Token. If a client ID is
  /// included, then the Ably Token authenticates its bearer as that client ID,
  /// and the Ably Token may only be used to perform operations on behalf of
  /// that client ID. The client is then considered to be an
  /// [identified client](https://ably.com/docs/core-features/authentication#identified-clients).
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// TD7	A static factory method to create a TokenDetails object from a
  /// deserialized TokenDetails-like object or a JSON stringified TokenDetails
  /// object. This method is provided to minimize bugs as a result of differing
  /// types by platform for fields such as timestamp or ttl. For example, in
  /// Ruby ttl in the TokenDetails object is exposed in seconds as that is
  /// idiomatic for the language, yet when serialized to JSON using to_json it
  /// is automatically converted to the Ably standard which is milliseconds. By
  /// using the fromJson() method when constructing a TokenDetails object, Ably
  /// ensures that all fields are consistently serialized and deserialized
  /// across platforms.
  ///
  /// [String | JsonObject] - A deserialized TokenDetails-like object or a JSON
  /// stringified TokenDetails object.
  ///
  /// [TokenDetails] - An Ably authentication token.
  /// END CANONICAL DOCSTRING
  TokenDetails.fromMap(Map<String, dynamic> map)
      : capability = map['capability'] as String?,
        clientId = map['clientId'] as String?,
        expires = map['expires'] as int?,
        issued = map['issued'] as int?,
        token = map['token'] as String?;
}
