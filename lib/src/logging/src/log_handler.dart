import 'package:ably_flutter/ably_flutter.dart';

/// Custom handler to handle SDK log messages
///
/// For discussion about removing this component see
/// https://github.com/ably/ably-flutter/issues/238
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO3c
@Deprecated(
  'All usages of this type are marked as deprecated '
  'so it will be removed in future releases',
)
typedef LogHandler = void Function({
  String? msg,
  AblyException? exception,
});
