import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter/foundation.dart';

/// Contains the properties of a request for a token to Ably. Tokens are
/// generated using [Auth.requestToken].
@immutable
class TokenRequest {
  /// The name of the key against which this request is made.
  ///
  /// The key name is public, whereas the key secret is private.
  final String? keyName;

  /// A cryptographically secure random string of at least 16 characters, used
  /// to ensure the `TokenRequest` cannot be reused.
  final String? nonce;

  /// The Message Authentication Code for this request.
  final String? mac;

  /// Capability of the requested Ably Token. If the Ably `TokenRequest` is
  /// successful, the capability of the returned Ably Token will be the
  /// intersection of this capability with the capability of the issuing key.
  ///
  /// The capabilities value is a JSON-encoded representation of the resource
  /// paths and associated operations. Read more about capabilities in the
  /// [capabilities docs](https://ably.com/docs/realtime/authentication).
  final String? capability;

  /// The client ID to associate with the requested Ably Token.
  ///
  /// When provided, the Ably Token may only be used to perform operations on
  /// behalf of that client ID.
  final String? clientId;

  /// The [DateTime] of this request.
  final DateTime? timestamp;

  /// Requested time to live for the Ably Token in milliseconds.
  ///
  /// If the Ably `TokenRequest` is successful, the TTL of the returned Ably
  /// Token is less than or equal to this value, depending on application
  /// settings and the attributes of the issuing key.
  final int? ttl;

  /// @nodoc
  /// instantiates a [TokenRequest] with provided values
  const TokenRequest({
    this.capability,
    this.clientId,
    this.keyName,
    this.mac,
    this.nonce,
    this.timestamp,
    this.ttl,
  });

  /// A static factory method to create a [TokenRequest] object from a
  /// deserialized `TokenRequest`-like object or a JSON stringified
  /// `TokenRequest` object.
  ///
  /// This method is provided to minimize bugs as a result of differing
  /// types by platform for fields such as `timestamp` or `ttl`. For example, in
  /// Ruby `ttl` in the `TokenRequest` object is exposed in seconds as that is
  /// idiomatic for the language, yet when serialized to JSON using `to_json` it
  /// is automatically converted to the Ably standard which is milliseconds.
  /// By using the `fromMap()` method when constructing a `TokenRequest` object,
  /// Ably ensures that all fields are consistently serialized and deserialized
  /// across platforms.
  TokenRequest.fromMap(Map<String, dynamic> map)
      : capability = map['capability'] as String?,
        clientId = map['clientId'] as String?,
        mac = map['mac'] as String?,
        nonce = map['nonce'] as String?,
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        ttl = map['ttl'] as int?,
        keyName = map['keyName'] as String?;
}
