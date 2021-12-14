import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

Map<int?, Realtime> _realtimeInstances = {};

/// Returns readonly copy of instances of all [Realtime] clients created.
Map<int?, Realtime> get realtimeInstances =>
    UnmodifiableMapView(_realtimeInstances);

/// Ably's Realtime client
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
        options = options ?? ClientOptions.fromKey(key!),
        super() {
    _connection = Connection(this);
    _channels = RealtimeChannels(this);
    push = PushNative(realtime: this);
  }

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeRaw<int>(
      PlatformMethod.createRealtime,
      AblyMessage(options),
    );
    _realtimeInstances[handle] = this;

    if (io.Platform.isAndroid && options.autoConnect) {
      // On Android, clientOptions.autoConnect is set to `false` to prevent
      // the authCallback being called before we get the realtime handle.
      // If this happens, we won't be able to identify which realtime client
      // the authCallback belongs to. Instead, on Android, we set autoConnect
      // to false, and call connect immediately once we get the handle.
      await invokeRaw(PlatformMethod.connectRealtime, handle);
    }
    return handle;
  }

  // The _connection instance keeps a reference to this platform object.
  late final Connection _connection;

  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  @override
  Connection get connection => _connection;

  @override
  Auth? auth;

  @override
  ClientOptions options;

  @override
  late Push push;

  late RealtimeChannels _channels;

  /// collection of [RealtimeChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  @override
  RealtimeChannels get channels => _channels;

  /// closes the [connection]
  @override
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  /// connects to [connection]
  @override
  Future<void> connect() async {
    await invoke(PlatformMethod.connectRealtime);
  }

  @override
  Future<HttpPaginatedResponse> request({
    required String method,
    required String path,
    Map<String, dynamic>? params,
    Object? body,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> time() async{
    final time = await invokeRequest<int>(PlatformMethod
        .realtimeTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  @override
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
