import '../../error/src/ably_exception.dart';

/// Custom handler to handle SDK log messages
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO3c
typedef LogHandler = void Function({
  String? msg,
  AblyException? exception,
});
