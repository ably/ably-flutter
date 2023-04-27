import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:ably_flutter/src/rest/src/rest_auth.dart';

Map<int?, Rest> _restInstances = {};

/// @nodoc
/// Returns readonly copy of instances of all [Rest] clients created.
Map<int?, Rest> get restInstances => UnmodifiableMapView(_restInstances);

/// A client that offers a simple stateless API to interact directly with Ably's
/// REST API.
class Rest extends PlatformObject {
  /// Construct a `Rest` object using an Ably [options] object.
  Rest({required this.options}) : super() {
    channels = RestChannels(this);
    push = Push(rest: this);
    auth = RestAuth(this);
  }

  /// Constructs a `Rest` object using an Ably API [key] or token string
  /// that's used to validate the cliet.
  factory Rest.fromKey(String key) => Rest(options: ClientOptions(key: key));

  /// @nodoc
  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeWithoutHandle<int>(PlatformMethod.createRest, {
      TxTransportKeys.options: options,
    });
    _restInstances[handle] = this;
    return handle;
  }

  /// An [Auth] object.
  late Auth auth;

  /// An object that contains additional client-specific properties
  late ClientOptions options;

  /// Retrieves the time from the Ably service as milliseconds since the Unix
  /// epoch.
  ///
  /// Clients that do not have access to a sufficiently well maintained
  /// time source and wish to issue Ably [TokenRequest]s with a more accurate
  /// timestamp should use the [AuthOptions.queryTime] property on a
  /// [ClientOptions] object instead of this method.
  Future<DateTime> time() async {
    final time = await invokeRequest<int>(PlatformMethod.restTime);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// A [Push] object.
  late Push push;

  /// A [Channels] object.
  late RestChannels channels;

  /// Retrieves a [LocalDevice] object that represents the
  /// current state of the device as a target for push notifications.
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
