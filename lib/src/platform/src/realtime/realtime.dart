import 'dart:async';
import 'dart:collection';
import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// The Ably Realtime client library establishes and maintains a persistent
/// connection to Ably enabling low latency broadcasting and receiving of
/// messages and presence state.
///
/// Learn more at the [Realtime Client Library API documentation](https://ably.com/documentation/realtime).
class Realtime extends PlatformObject {
  /// instantiates with [ClientOptions] and a String [key]
  ///
  /// creates client options from key if [key] is provided
  ///
  /// raises [AssertionError] if both [options] and [key] are null
  Realtime({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = options ?? ClientOptions(key: key!),
        super() {
    _connection = Connection(this);
    _channels = RealtimeChannels(this);
    push = Push(realtime: this);
  }

  /// Create a realtime client from an API key without configuring other parameters
  factory Realtime.fromKey(String key) =>
      Realtime(options: ClientOptions(key: key));

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeRaw<int>(
      PlatformMethod.createRealtime,
      AblyMessage(message: options),
    );
    _realtimeInstances[handle] = this;

    if (io.Platform.isAndroid && options.autoConnect) {
      // On Android, clientOptions.autoConnect is set to `false` to prevent
      // the authCallback being called before we get the realtime handle.
      // If this happens, we won't be able to identify which realtime client
      // the authCallback belongs to. Instead, on Android, we set autoConnect
      // to false, and call connect immediately once we get the handle.
      // This is also a specific case where it's required to use [invokeRaw]
      // because we need to pass message with handle outside of [PlatformObject]
      await invokeRaw(
        PlatformMethod.connectRealtime,
        AblyMessage.empty(handle: handle),
      );
    }
    return handle;
  }

  // The _connection instance keeps a reference to this platform object.
  late final Connection _connection;

  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  Connection get connection => _connection;

  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  // Auth? auth;

  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  late ClientOptions options;

  /// a push object interacting with Push API
  /// viz., subscribing for push notifications, etc
  late Push push;

  late RealtimeChannels _channels;

  /// Provides access to the underlying [RealtimeChannels]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  RealtimeChannels get channels => _channels;

  /// closes the [connection]
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  /// connects to [connection]
  Future<void> connect() async {
    await invoke(PlatformMethod.connectRealtime);
  }

  /// creates and sends a raw request to ably service
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC19
  // Future<HttpPaginatedResponse> request({
  //   required String method,
  //   required String path,
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
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.realtimeTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://ably.com/docs/client-lib-development-guide/features/#RSH8
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}

Map<int?, Realtime> _realtimeInstances = {};

/// Returns readonly copy of instances of all [Realtime] clients created.
Map<int?, Realtime> get realtimeInstances =>
    UnmodifiableMapView(_realtimeInstances);
