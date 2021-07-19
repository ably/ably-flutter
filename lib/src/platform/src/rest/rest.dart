import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/src/push_notifications/src/local_device.dart';

import '../../../authentication/authentication.dart';
import '../../../common/common.dart';
import '../../../generated/platform_constants.dart';
import '../../../push_notifications/push_notifications.dart';
import '../../../rest/rest.dart';
import '../../../stats/stats.dart';
import '../../platform.dart';

Map<int?, Rest> _restInstances = {};
Map<int?, Rest>? _restInstancesUnmodifiableView;

/// Returns readonly copy of instances of all [Rest] clients created.
Map<int?, Rest> get restInstances =>
    _restInstancesUnmodifiableView ??= UnmodifiableMapView(_restInstances);

/// Ably's Rest client
class Rest extends PlatformObject implements RestInterface<RestChannels> {
  /// instantiates with [ClientOptions] and a String [key]
  ///
  /// creates client options from key if [key] is provided
  ///
  /// raises [AssertionError] if both [options] and [key] are null
  Rest({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = options ?? ClientOptions.fromKey(key!),
        super() {
    channels = RestChannels(this);
    push = PushNative(handle);
  }

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeRaw<int>(
      PlatformMethod.createRestWithOptions,
      AblyMessage(options),
    );
    _restInstances[handle] = this;
    return handle;
  }

  /// @internal
  /// required due to the complications involved in the way ably-java expects
  /// authCallback to be performed synchronously, while method channel call from
  /// platform side to dart side is asynchronous
  ///
  /// discussion: https://github.com/ably/ably-flutter/issues/31
  void authUpdateComplete() {
    for (final channel in channels) {
      channel.authUpdateComplete();
    }
  }

  @override
  Auth? auth;

  @override
  ClientOptions options;

  @override
  Future<HttpPaginatedResponse> request({
    String? method,
    String? path,
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
  Future<DateTime> time() {
    throw UnimplementedError();
  }

  @override
  late Push push;

  @override
  late RestChannels channels;

  @override
  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
