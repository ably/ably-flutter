

/// Static timeouts used inside the SDK
class Timeouts {
  /// max time allowed for retrying an operation for auth failure
  ///  in case of usage of authCallback
  static const retryOperationOnAuthFailure = Duration(seconds: 30);

  /// max time dart side will wait for platform side to respond with a
  ///  platform handle
  static const acquireHandleTimeout = Duration(seconds: 5);

  /// max time dart side will wait for platform side to respond after
  ///  initializing an Ably instance on platform side
  static const initializeTimeout = Duration(seconds: 5);
}
