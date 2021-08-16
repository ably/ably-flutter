/// Static error codes used inside the SDK
class ErrorCodes {
  /// error code sent from platform in case if response from
  /// authCallback is not of valid type.
  /// When this is encountered, flutter side will re-try the
  /// method call after responding to authCallback method channel
  /// call triggered from platform side
  static const int authCallbackFailure = 80019;
}
