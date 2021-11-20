import 'package:ably_flutter/ably_flutter.dart';

/// Log levels - control verbosity of log messages
///
/// Can be used for [ClientOptions.logLevel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO3b
enum LogLevel { none, verbose, debug, info, warn, error }