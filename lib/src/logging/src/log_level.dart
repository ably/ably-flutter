import 'package:ably_flutter/ably_flutter.dart';

/// Log levels - control verbosity of log messages
///
/// Can be used for [ClientOptions.logLevel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO3b
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
