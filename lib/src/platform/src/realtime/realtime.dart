import 'dart:async';
import 'dart:collection';
import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// The Ably Realtime client library establishes and maintains a persistent
/// connection to Ably enabling low latency broadcasting and receiving of
/// messages and presence state.
///
/// Learn more at the [Realtime Client Library API documentation](https://ably.com/documentation/realtime).
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// A client that extends functionality of the [Rest] and provides
/// additional realtime-specific features.
/// END EDITED CANONICAL DOCSTRING
class Realtime extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// instantiates with [ClientOptions] and a String [key]
  ///
  /// creates client options from key if [key] is provided
  ///
  /// raises [AssertionError] if both [options] and [key] are null
  /// END LEGACY DOCSTRING
  ///

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Constructs a `Realtime` object using an Ably [options] object or
  /// the Ably API [key] or token string used to validate the client.
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// Create a realtime client from an API key without
  /// configuring other parameters
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Constructs a `Realtime` object using an Ably API [key] or token string
  /// used to validate the client.
  /// END CANONICAL DOCSTRING
  factory Realtime.fromKey(String key) =>
      Realtime(options: ClientOptions(key: key));

  @override
  Future<int?> createPlatformInstance() async {
    final handle =
        await invokeWithoutHandle<int>(PlatformMethod.createRealtime, {
      TxTransportKeys.options: options,
    });
    _realtimeInstances[handle] = this;

    if (io.Platform.isAndroid && options.autoConnect) {
      /// BEGIN LEGACY DOCSTRING
      // On Android, clientOptions.autoConnect is set to `false` to prevent
      // the authCallback being called before we get the realtime handle.
      // If this happens, we won't be able to identify which realtime client
      // the authCallback belongs to. Instead, on Android, we set autoConnect
      // to false, and call connect immediately once we get the handle.
      // This is also a specific case where it's required to pass the handle
      // value from external source
      /// END LEGACY DOCSTRING
      await invoke<void>(
        PlatformMethod.connectRealtime,
        null,
        handle,
      );
    }
    return handle;
  }

  /// BEGIN LEGACY DOCSTRING
  // The _connection instance keeps a reference to this platform object.
  /// END LEGACY DOCSTRING
  late final Connection _connection;

  /// BEGIN LEGACY DOCSTRING
  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [Connection] object.
  /// END EDITED CANONICAL DOCSTRING
  Connection get connection => _connection;

  /// BEGIN LEGACY DOCSTRING
  /// a custom auth object to perform authentication related operations
  /// based on the [options]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC5
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An [Auth] object.
  /// END EDITED CANONICAL DOCSTRING
  // Auth? auth;

  /// BEGIN LEGACY DOCSTRING
  /// [ClientOptions] indicating authentication and other settings for this
  /// instance to interact with ably service
  /// END LEGACY DOCSTRING
  late ClientOptions options;

  /// BEGIN LEGACY DOCSTRING
  /// a push object interacting with Push API
  /// viz., subscribing for push notifications, etc
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [Push] object.
  /// END EDITED CANONICAL DOCSTRING
  late Push push;

  late RealtimeChannels _channels;

  /// BEGIN LEGACY DOCSTRING
  /// Provides access to the underlying [RealtimeChannels]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [Channels] object.
  /// END EDITED CANONICAL DOCSTRING
  RealtimeChannels get channels => _channels;

  /// BEGIN LEGACY DOCSTRING
  /// closes the [connection]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Calls [Connection.close] and causes the connection to close, entering the
  /// closing state. Once closed, the library will not attempt to re-establish
  /// the connection without an explicit call to [Connection.connect].
  /// END EDITED CANONICAL DOCSTRING
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  /// BEGIN LEGACY DOCSTRING
  /// connects to [connection]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Calls [Connection.connect] and causes the connection to open, entering the
  /// connecting state. Explicitly calling [Connection.connect] is unnecessary
  /// unless the [ClientOptions.autoConnect] property is disabled.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> connect() async => invoke<void>(PlatformMethod.connectRealtime);

  /// BEGIN LEGACY DOCSTRING
  /// creates and sends a raw request to ably service
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC19
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Makes a REST request to a provided [path] using a [method], such as `GET`,
  /// `POST`.
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
  /// END EDITED CANONICAL DOCSTRING
  // Future<HttpPaginatedResponse> request({
  //   required String method,
  //   required String path,
  //   Map<String, dynamic>? params,
  //   Object? body,
  //   Map<String, String>? headers,
  // }) {
  //   throw UnimplementedError();
  // }

  /// BEGIN LEGACY DOCSTRING
  /// gets stats based on params as a [PaginatedResult]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC6
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Queries the REST `/stats` API and retrieves your application's usage
  /// statistics. You must specify the [start] time from which stats are
  /// retrieved, specified as milliseconds since the Unix epoch, and the [end]
  /// time until stats are retrieved, specified as milliseconds since the Unix
  /// epoch.
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
  /// END EDITED CANONICAL DOCSTRING
  // Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
  //   throw UnimplementedError();
  // }

  /// BEGIN LEGACY DOCSTRING
  /// returns server time
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSC16
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves the [DateTime] from the Ably service. Clients that do not have
  /// access to a sufficiently well maintained time source and wish to issue
  /// Ably [TokenRequest]s with a more accurate timestamp should use the
  /// [AuthOptions.queryTime] property on a [ClientOptions] object instead of
  /// this method.
  ///
  /// END EDITED CANONICAL DOCSTRING
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.realtimeTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// BEGIN LEGACY DOCSTRING
  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH8
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves a [LocalDevice] object that represents the current state of the
  /// device as a target for push notifications.
  /// END EDITED CANONICAL DOCSTRING
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}

Map<int?, Realtime> _realtimeInstances = {};

/// BEGIN LEGACY DOCSTRING
/// Returns readonly copy of instances of all [Realtime] clients created.
/// END LEGACY DOCSTRING
Map<int?, Realtime> get realtimeInstances =>
    UnmodifiableMapView(_realtimeInstances);
