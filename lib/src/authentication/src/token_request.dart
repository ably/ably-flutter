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
  final String? capability;

  /// BEGIN LEGACY DOCSTRING
  ///  Client ID assigned to the tokenRequest.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// END LEGACY DOCSTRING
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
