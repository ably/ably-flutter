class LogLevel{
  static const int none = 99;
  static const int verbose = 2;
  static const int debug = 3;
  static const int info = 4;
  static const int warn = 5;
  static const int error = 6;
}

class ErrorCodes {
  /// error code sent from platform in case if response from
  /// authCallback is not of valid type.
  /// When this is encountered, flutter side will re-try the
  /// method call after responding to authCallback method channel
  /// call triggered from platform side
  static const int authCallbackFailure = 80019;
}
