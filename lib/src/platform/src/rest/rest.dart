import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

Map<int?, Rest> _restInstances = {};

/// BEGIN LEGACY DOCSTRING
/// Returns readonly copy of instances of all [Rest] clients created.
/// END LEGACY DOCSTRING
Map<int?, Rest> get restInstances => UnmodifiableMapView(_restInstances);

/// BEGIN LEGACY DOCSTRING
/// END LEGACY DOCSTRING
/// A simple stateless API to interact directly with Ably’s REST API
///
/// Learn more at the [REST Client Library API documentation](https://ably.com/documentation/rest).
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// A client that offers a simple stateless API to interact directly with Ably's
/// REST API.
/// END CANONICAL DOCSTRING
class Rest extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// Pass a [ClientOptions] to configure the rest client.
  /// END LEGACY DOCSTRING
  Rest({required this.options}) : super() {
    channels = RestChannels(this);
    push = Push(rest: this);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Create a rest client from an API key without configuring other parameters
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Constructs a RestClient object using an Ably API key or token string.
  ///
  /// [keyOrTokenStr] - The Ably API key or token string used to validate the
  /// client.
  /// END CANONICAL DOCSTRING
  factory Rest.fromKey(String key) => Rest(options: ClientOptions(key: key));

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeWithoutHandle<int>(PlatformMethod.createRest, {
      TxTransportKeys.options: options,
    });
    _restInstances[handle] = this;
    return handle;
  }

  /// BEGIN LEGACY DOCSTRING
  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  // Auth? auth;
  /// END LEGACY DOCSTRING

  /// BEGIN LEGACY DOCSTRING
  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  /// END LEGACY DOCSTRING

  late ClientOptions options;

  /// BEGIN LEGACY DOCSTRING
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
  /// END LEGACY DOCSTRING

  /// BEGIN LEGACY DOCSTRING
  /// gets stats based on params as a [PaginatedResult]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC6
  // Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
  //   throw UnimplementedError();
  // }
  /// END LEGACY DOCSTRING

  /// BEGIN LEGACY DOCSTRING
  /// returns server time
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC16
  /// END LEGACY DOCSTRING
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.restTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// BEGIN LEGACY DOCSTRING
  /// a push object interacting with Push API, such as
  /// subscribing for push notifications by clientId.
  /// END LEGACY DOCSTRING
  late Push push;

  /// BEGIN LEGACY DOCSTRING
  /// collection of [RestChannel] instances
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSN1
  /// END LEGACY DOCSTRING
  late RestChannels channels;

  /// BEGIN LEGACY DOCSTRING
  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH8
  /// END LEGACY DOCSTRING
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
