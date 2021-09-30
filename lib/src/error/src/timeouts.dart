/// Static timeouts used inside the SDK
class Timeouts {
  /// max time allowed for retrying an operation for auth failure
  ///  in case of usage of authCallback
  static const retryOperationOnAuthFailure = Duration(seconds: 30);
}
