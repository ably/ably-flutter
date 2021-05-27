import '../../ably_flutter.dart';

/// Log levels - control verbosity of log messages
///
/// Can be used for [ClientOptions.logLevel]
///
/// https://docs.ably.io/client-lib-development-guide/features/#TO3b
///
/// TODO(tiholic) convert [LogLevel] to enum and update encoder to pass
///  right numeric values to platform methods
class LogLevel {
  /// No logging
  static const int none = 99;

  /// Verbose logs
  static const int verbose = 2;

  /// debug logs
  static const int debug = 3;

  /// info logs
  static const int info = 4;

  /// warning logs
  static const int warn = 5;

  /// error logs
  static const int error = 6;
}

/// Static error codes used inside the SDK
class ErrorCodes {
  /// error code sent from platform in case if response from
  /// authCallback is not of valid type.
  /// When this is encountered, flutter side will re-try the
  /// method call after responding to authCallback method channel
  /// call triggered from platform side
  static const int authCallbackFailure = 80019;
}

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
