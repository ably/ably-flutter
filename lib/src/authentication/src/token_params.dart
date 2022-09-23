import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A class providing parameters of a token request.
///
/// Parameters for a token request
///
/// [Auth.authorize], [Auth.requestToken] and [Auth.createTokenRequest]
/// accept an instance of TokenParams as a parameter
///
/// https://docs.ably.com/client-lib-development-guide/features/#TK1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Defines the properties of an Ably Token.
/// END CANONICAL DOCSTRING
@immutable
class TokenParams {
  /// BEGIN LEGACY DOCSTRING
  /// Capability of the token.
  ///
  /// If the token request is successful, the capability of the
  /// returned token will be the intersection of this [capability]
  /// with the capability of the issuing key.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The capabilities associated with this Ably Token. The capabilities value
  /// is a JSON-encoded representation of the resource paths and associated
  /// operations. Read more about capabilities in the
  /// [capabilities docs](https://ably.com/docs/core-features/authentication/#capabilities-explained).
  /// END CANONICAL DOCSTRING
  final String? capability;

  /// BEGIN LEGACY DOCSTRING
  /// A clientId to associate with this token.
  ///
  /// The generated token may be used to authenticate as this clientId.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2c
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes. The clientId can be any non-empty string, except it
  /// cannot contain a *. This option is primarily intended to be used in
  /// situations where the library is instantiated with a key. Note that a
  /// clientId may also be implicit in a token used to instantiate the library.
  /// An error is raised if a clientId specified here conflicts with the
  /// clientId implicit in the token. Find out more about
  /// [identified clients](https://ably.com/docs/core-features/authentication#identified-clients).
  /// END CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// An opaque nonce string of at least 16 characters to ensure uniqueness.
  ///
  /// Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  /// END LEGACY DOCSTRING
  final String? nonce;

  /// BEGIN LEGACY DOCSTRING
  /// The timestamp (in millis since the epoch) of this request.
  ///
  ///	Timestamps, in conjunction with the nonce, are used to prevent
  ///	token requests from being replayed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2d
  /// END LEGACY DOCSTRING
  final DateTime? timestamp;

  /// BEGIN LEGACY DOCSTRING
  /// Requested time to live for the token.
  ///
  /// If the token request is successful, the TTL of the returned
  /// token will be less than or equal to this value depending on
  /// application settings and the attributes of the issuing key.
  ///
  /// 0 means Ably will set it to the default value
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TK2a
  /// END LEGACY DOCSTRING
  final int? ttl;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates a [TokenParams] with provided values
  /// END LEGACY DOCSTRING
  const TokenParams({
    this.capability,
    this.clientId,
    this.nonce,
    this.timestamp,
    this.ttl,
  });

  /// BEGIN LEGACY DOCSTRING
  /// converts to a map of objects
  /// END LEGACY DOCSTRING
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
