import 'package:flutter/foundation.dart';

/// BEGIN LEGACY DOCSTRING
/// spec: https://docs.ably.com/client-lib-development-guide/features/#TE1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains the properties of a request for a token to Ably. Tokens are
/// generated using [requestToken]{@link Auth#requestToken}.
/// END CANONICAL DOCSTRING
@immutable
class TokenRequest {
  /// BEGIN LEGACY DOCSTRING
  /// [keyName] is the first part of Ably API Key.
  ///
  /// provided keyName will be used to authorize requests made to Ably.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  ///
  /// More details about Ably API Key:
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA11
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The name of the key against which this request is made. The key name is
  /// public, whereas the key secret is private.
  /// END CANONICAL DOCSTRING
  final String? keyName;

  /// BEGIN LEGACY DOCSTRING
  /// An opaque nonce string of at least 16 characters to ensure
  ///	uniqueness of this request. Any subsequent request using the
  ///	same nonce will be rejected.
  ///
  /// spec:
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// https://docs.ably.com/client-lib-development-guide/features/#TE5
  /// END LEGACY DOCSTRING
  final String? nonce;

  /// BEGIN LEGACY DOCSTRING
  /// The "Message Authentication Code" for this request.
  ///
  /// See the Ably Authentication documentation for more details.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// END LEGACY DOCSTRING
  final String? mac;

  /// BEGIN LEGACY DOCSTRING
  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Capability of the requested Ably Token. If the Ably TokenRequest is
  /// successful, the capability of the returned Ably Token will be the
  /// intersection of this capability with the capability of the issuing key.
  /// The capabilities value is a JSON-encoded representation of the resource
  /// paths and associated operations. Read more about capabilities in the
  /// [capabilities docs](https://ably.com/docs/realtime/authentication).
  /// END CANONICAL DOCSTRING
  final String? capability;

  /// BEGIN LEGACY DOCSTRING
  ///  Client ID assigned to the tokenRequest.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The client ID to associate with the requested Ably Token. When provided,
  /// the Ably Token may only be used to perform operations on behalf of that
  /// client ID.
  /// END CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// timestamp long – The timestamp (in milliseconds since the epoch)
  /// of this request. Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE5
  /// END LEGACY DOCSTRING
  final DateTime? timestamp;

  /// BEGIN LEGACY DOCSTRING
  /// ttl attribute represents time to live (expiry)
  /// of this token in milliseconds
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE4
  /// END LEGACY DOCSTRING
  final int? ttl;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates a [TokenRequest] with provided values
  /// END LEGACY DOCSTRING
  const TokenRequest({
    this.capability,
    this.clientId,
    this.keyName,
    this.mac,
    this.nonce,
    this.timestamp,
    this.ttl,
  });

  /// BEGIN LEGACY DOCSTRING
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE7
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A static factory method to create a TokenRequest object from a
  /// deserialized TokenRequest-like object or a JSON stringified TokenRequest
  /// object. This method is provided to minimize bugs as a result of differing
  /// types by platform for fields such as timestamp or ttl. For example, in
  /// Ruby ttl in the TokenRequest object is exposed in seconds as that is
  /// idiomatic for the language, yet when serialized to JSON using to_json it
  /// is automatically converted to the Ably standard which is milliseconds.
  /// By using the fromJson() method when constructing a TokenRequest object,
  /// Ably ensures that all fields are consistently serialized and deserialized
  /// across platforms.
  ///
  /// [String | JsonObject] - A deserialized TokenRequest-like object or a JSON
  /// stringified TokenRequest object to create a TokenRequest.
  ///
  /// [TokenRequest] - An Ably token request object.
  /// END CANONICAL DOCSTRING
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
