import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

Map<int?, Rest> _restInstances = {};

/// Returns readonly copy of instances of all [Rest] clients created.
Map<int?, Rest> get restInstances => UnmodifiableMapView(_restInstances);

/// A simple stateless API to interact directly with Ably’s REST API
///
/// Learn more at the [REST Client Library API documentation](https://ably.com/documentation/rest).
class Rest extends PlatformObject {
  /// Pass a [ClientOptions] to configure the rest client.
  Rest({required this.options}) : super() {
    channels = RestChannels(this);
    push = Push(rest: this);
  }

  /// Create a rest client from an API key without configuring other parameters
  factory Rest.fromKey(String key) => Rest(options: ClientOptions.fromKey(key));

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeRaw<int>(
      PlatformMethod.createRest,
      AblyMessage(options),
    );
    _restInstances[handle] = this;
    return handle;
  }

  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  // Auth? auth;

  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  late ClientOptions options;

  /// creates and sends a raw request to ably service
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC19
  // Future<HttpPaginatedResponse> request({
  //   String? method,
  //   String? path,
  //   Map<String, dynamic>? params,
  //   Object? body,
  //   Map<String, String>? headers,
  // }) {
  //   throw UnimplementedError();
  // }

  /// gets stats based on params as a [PaginatedResult]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC6
  // Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
  //   throw UnimplementedError();
  // }

  /// returns server time
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC16
  // Future<DateTime> time() {
  //   throw UnimplementedError();
  // }

  /// a push object interacting with Push API, such as
  /// subscribing for push notifications by clientId.
  late Push push;

  /// collection of [RestChannel] instances
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSN1
  late RestChannels channels;

  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH8
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
