import 'package:flutter/foundation.dart';

/// spec: https://docs.ably.com/client-lib-development-guide/features/#TE1
@immutable
class TokenRequest {
  /// [keyName] is the first part of Ably API Key.
  ///
  /// provided keyName will be used to authorize requests made to Ably.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  ///
  /// More details about Ably API Key:
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA11
  final String? keyName;

  /// An opaque nonce string of at least 16 characters to ensure
  ///	uniqueness of this request. Any subsequent request using the
  ///	same nonce will be rejected.
  ///
  /// spec:
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// https://docs.ably.com/client-lib-development-guide/features/#TE5
  final String? nonce;

  /// The "Message Authentication Code" for this request.
  ///
  /// See the Ably Authentication documentation for more details.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  final String? mac;

  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE3
  final String? capability;

  ///  Client ID assigned to the tokenRequest.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  final String? clientId;

  /// timestamp long – The timestamp (in milliseconds since the epoch)
  /// of this request. Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE5
  final DateTime? timestamp;

  /// ttl attribute represents time to live (expiry)
  /// of this token in milliseconds
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE4
  final int? ttl;

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

  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE7
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
