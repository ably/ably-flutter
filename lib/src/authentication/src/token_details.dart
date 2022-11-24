import 'package:meta/meta.dart';

/// Contains an Ably Token and its associated metadata.
@immutable
class TokenDetails {
  /// The [Ably Token](https://ably.com/docs/core-features/authentication#ably-tokens)
  /// itself.
  ///
  /// A typical Ably Token string appears with the form
  /// `xVLyHw.A-pwh7wicf3afTfgiw4k2Ku33kcnSA7z6y8FjuYpe3QaNRTEo4.`
  final String? token;

  /// The timestamp at which this token expires as milliseconds since the Unix
  /// epoch.
  final int? expires;

  /// The timestamp at which this token was issued as milliseconds since the
  /// Unix epoch.
  final int? issued;

  /// The capabilities associated with this Ably Token.
  ///
  /// The capabilities value
  /// is a JSON-encoded representation of the resource paths and associated
  /// operations. Read more about capabilities in the [capabilities docs](https://ably.com/docs/core-features/authentication/#capabilities-explained).
  final String? capability;

  /// The client ID, if any, bound to this Ably Token.
  ///
  /// If a client ID is included, then the Ably Token authenticates its bearer
  /// as that client ID, and the Ably Token may only be used to perform
  /// operations on behalf of that client ID. The client is then considered to
  /// be an [identified client](https://ably.com/docs/core-features/authentication#identified-clients).
  final String? clientId;

  /// @nodoc
  /// instantiates a [TokenDetails] with provided values
  const TokenDetails(
    this.token, {
    this.capability,
    this.clientId,
    this.expires,
    this.issued,
  });

  /// A static factory method to create a [TokenDetails] authentication
  /// token object from a deserialized `TokenDetails`-like object or a
  /// JSON stringified `TokenDetails` object.
  ///
  /// This method is provided to minimize bugs as a result of differing
  /// types by platform for fields such as `timestamp` or `ttl`. For example, in
  /// Ruby `ttl` in the `TokenDetails` object is exposed in seconds as that is
  /// idiomatic for the language, yet when serialized to JSON using `to_json` it
  /// is automatically converted to the Ably standard which is milliseconds. By
  /// using the `fromMap()` method when constructing a `TokenDetails` object,
  /// Ably ensures that all fields are consistently serialized and deserialized
  /// across platforms.
  TokenDetails.fromMap(Map<String, dynamic> map)
      : capability = map['capability'] as String?,
        clientId = map['clientId'] as String?,
        expires = map['expires'] as int?,
        issued = map['issued'] as int?,
        token = map['token'] as String?;
}
