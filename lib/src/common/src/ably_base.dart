import 'package:ably_flutter/ably_flutter.dart';

/// A base class for [Rest] and [Realtime]
abstract class AblyBase {
  /// takes [ClientOptions] or a [key] string to authenticate with ably
  AblyBase({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = (options == null) ? ClientOptions.fromKey(key!) : options;

  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  final ClientOptions options;

  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  Auth? auth;

  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH8
  Future<LocalDevice> device();

  /// a push object interacting with Push API
  /// viz., subscribing for push notifications, etc
  late Push push;

  /// gets stats based on params as a [PaginatedResult]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC6
  Future<PaginatedResult<Stats>> stats([
    Map<String, dynamic>? params,
  ]);

  /// creates and sends a raw request to ably service
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC19
  Future<HttpPaginatedResponse> request({
    required String method,
    required String path,
    Map<String, dynamic>? params,
    Object? body,
    Map<String, String>? headers,
  });

  /// returns server time
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC16
  Future<DateTime> time();
}
