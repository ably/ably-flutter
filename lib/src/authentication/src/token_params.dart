import 'package:ably_flutter/ably_flutter.dart';

/// A class providing parameters of a token request.
///
/// Parameters for a token request
///
/// [Auth.authorize], [Auth.requestToken] and [Auth.createTokenRequest]
/// accept an instance of TokenParams as a parameter
///
/// https://docs.ably.com/client-lib-development-guide/features/#TK1
class TokenParams {
  /// Capability of the token.
  ///
  /// If the token request is successful, the capability of the
  /// returned token will be the intersection of this [capability]
  /// with the capability of the issuing key.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2b
  String? capability;

  /// A clientId to associate with this token.
  ///
  /// The generated token may be used to authenticate as this clientId.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2c
  String? clientId;

  /// An opaque nonce string of at least 16 characters to ensure uniqueness.
  ///
  /// Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  String? nonce;

  /// The timestamp (in millis since the epoch) of this request.
  ///
  ///	Timestamps, in conjunction with the nonce, are used to prevent
  ///	token requests from being replayed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  DateTime? timestamp;

  /// Requested time to live for the token.
  ///
  /// If the token request is successful, the TTL of the returned
  /// token will be less than or equal to this value depending on
  /// application settings and the attributes of the issuing key.
  ///
  /// 0 means Ably will set it to the default value
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2a
  int? ttl;

  /// instantiates a [TokenParams] with provided values
  TokenParams({
    this.capability,
    this.clientId,
    this.nonce,
    this.timestamp,
    this.ttl,
  });
}
