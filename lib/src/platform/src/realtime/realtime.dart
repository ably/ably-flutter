import 'dart:async';
import 'dart:collection';
import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// A client that extends functionality of the [Rest] and provides
/// additional realtime-specific features.
class Realtime extends PlatformObject {
  /// Constructs a `Realtime` object using an Ably [options] object or
  /// the Ably API [key] or token string used to validate the client.
  Realtime({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = options ?? ClientOptions(key: key),
        super() {
    _connection = Connection(this);
    _channels = RealtimeChannels(this);
    push = Push(realtime: this);
  }

  /// Constructs a `Realtime` object using an Ably API [key] or token string
  /// used to validate the client.
  factory Realtime.fromKey(String key) =>
      Realtime(options: ClientOptions(key: key));

  ///@nodoc
  @override
  Future<int?> createPlatformInstance() async {
    final handle =
        await invokeWithoutHandle<int>(PlatformMethod.createRealtime, {
      TxTransportKeys.options: options,
    });
    _realtimeInstances[handle] = this;

    if (io.Platform.isAndroid && options.autoConnect) {
      // On Android, clientOptions.autoConnect is set to `false` to prevent
      // the authCallback being called before we get the realtime handle.
      // If this happens, we won't be able to identify which realtime client
      // the authCallback belongs to. Instead, on Android, we set autoConnect
      // to false, and call connect immediately once we get the handle.
      // This is also a specific case where it's required to pass the handle
      // value from external source
      await invoke<void>(
        PlatformMethod.connectRealtime,
        null,
        handle,
      );
    }
    return handle;
  }

  // The _connection instance keeps a reference to this platform object.
  late final Connection _connection;

  /// A [Connection] object.
  Connection get connection => _connection;

  /// An [Auth] object.
  // Auth? auth;

  /// @nodoc
  /// A [ClientOptions] object used to configure the client connection to Ably.
  late ClientOptions options;

  /// A [Push] object.
  late Push push;

  late RealtimeChannels _channels;

  /// A [Channels] object.
  RealtimeChannels get channels => _channels;

  /// Calls [Connection.close] and causes the connection to close, entering the
  /// closing state.
  ///
  /// Once closed, the library will not attempt to re-establish the connection
  /// without an explicit call to [Connection.connect].
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  /// Calls [Connection.connect] and causes the connection to open, entering the
  /// connecting state.
  ///
  /// Explicitly calling [Connection.connect] is unnecessary unless the
  /// [ClientOptions.autoConnect] property is disabled.
  Future<void> connect() async => invoke<void>(PlatformMethod.connectRealtime);

  /// Makes a REST request to a provided [path] using a [method], such as `GET`,
  /// `POST`.
  ///
  /// [params] can be specified to include in the URL query of the
  /// request. The parameters depend on the endpoint being queried. See the
  /// [REST API reference](https://ably.com/docs/api/rest-api) for the available
  /// parameters of each endpoint.
  /// You can also provide the JSON [body] and additional [headers] to include
  /// in the request.
  /// Returns an [HttpPaginatedResponse] object returned by the HTTP
  /// request, containing an empty or JSON-encodable object.
  ///
  /// This is provided as a convenience for developers who wish to use REST API
  /// functionality that is either not documented or is not yet included in the
  /// public API, without having to directly handle features such as
  /// authentication, paging, fallback hosts, MsgPack and JSON support.
  // Future<HttpPaginatedResponse> request({
  //   required String method,
  //   required String path,
  //   Map<String, dynamic>? params,
  //   Object? body,
  //   Map<String, String>? headers,
  // }) {
  //   throw UnimplementedError();
  // }

  /// Queries the REST `/stats` API and retrieves your application's usage
  /// statistics.
  ///
  /// You must specify the [start] time from which stats are retrieved,
  /// specified as milliseconds since the Unix epoch, and the [end] time until
  /// stats are retrieved, specified as milliseconds since the Unix epoch.
  /// Set the [direction], which describes the order in which stats are returned
  /// in. Valid values are `backwards` which orders stats from most recent to
  /// oldest, or `forwards` which orders stats from oldest to most recent. The
  /// default is `backwards`.
  /// Provide [limit], which specifies upper limit on the number of
  /// stats returned (the default is 100, and the maximum is 1000).
  /// Set the [unit] as either a `minute`, `hour`, `day` or `month`. Based on
  /// the unit selected, the given start or end times are rounded down to the
  /// start of the relevant interval depending on the unit granularity of the
  /// query.
  /// Returns a [PaginatedResult] object containing an array of
  /// [Stats] objects.
  ///
  /// See the [Stats docs](https://ably.com/docs/general/statistics).
  // Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
  //   throw UnimplementedError();
  // }

  /// Retrieves the [DateTime] from the Ably service. Clients that do not have
  /// access to a sufficiently well maintained time source and wish to issue
  /// Ably [TokenRequest]s with a more accurate timestamp should use the
  /// [AuthOptions.queryTime] property on a [ClientOptions] object instead of
  /// this method.
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.realtimeTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// Retrieves a [LocalDevice] object that represents the current state of the
  /// device as a target for push notifications.
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}

Map<int?, Realtime> _realtimeInstances = {};

/// @nodoc
/// Returns readonly copy of instances of all [Realtime] clients created.
Map<int?, Realtime> get realtimeInstances =>
    UnmodifiableMapView(_realtimeInstances);
