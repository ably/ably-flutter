import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Defines the properties of an Ably Token.
@immutable
class TokenParams {
  /// The capabilities associated with this Ably Token.
  ///
  /// The capabilities value is a JSON-encoded representation of the resource
  /// paths and associated operations. Read more about capabilities in the
  /// [capabilities docs](https://ably.com/docs/core-features/authentication/#capabilities-explained).
  final String? capability;

  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes.
  ///
  /// The `clientId` can be any non-empty string, except it cannot contain a
  /// `*`. This option is primarily intended to be used in situations where the
  /// library is instantiated with a key. Note that a `clientId` may also be
  /// implicit in a token used to instantiate the library. An error is raised if
  /// a `clientId` specified here conflicts with the clientId implicit in the
  /// token. Find out more about [identified clients](https://ably.com/docs/core-features/authentication#identified-clients).
  final String? clientId;

  /// A cryptographically secure random string of at least 16 characters, used
  /// to ensure the [TokenRequest] cannot be reused.
  final String? nonce;

  /// The [DateTime] of this request.
  ///
  /// Timestamps, in conjunction with the `nonce`,  are used to prevent requests
  /// from being replayed. `timestamp` is a "one-time" value, and is valid in a
  /// request, but is not validly a member of any default token params such as
  /// `ClientOptions.defaultTokenParams`.
  final DateTime? timestamp;

  /// Requested time to live for the token in milliseconds.
  final int? ttl;

  /// @nodoc
  /// instantiates a [TokenParams] with provided values
  const TokenParams({
    this.capability,
    this.clientId,
    this.nonce,
    this.timestamp,
    this.ttl,
  });

  /// @nodoc
  /// converts to a map of objects
  Map<String, dynamic> toMap() {
    final jsonMap = <String, dynamic>{};
    if (capability != null) jsonMap['capability'] = capability;
    if (clientId != null) jsonMap['clientId'] = clientId;
    if (nonce != null) jsonMap['nonce'] = nonce;
    if (timestamp != null) {
      jsonMap['timestamp'] = timestamp?.millisecondsSinceEpoch.toString();
    }
    if (ttl != null) jsonMap['ttl'] = ttl.toString();
    return jsonMap;
  }
}
