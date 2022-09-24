import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Presence object on a [RestChannel] helps to query Presence members
/// and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSP1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables the retrieval of the current and historic presence set for a
/// channel.
/// END CANONICAL DOCSTRING
class RestPresence extends PlatformObject {
  final RestChannel _restChannel;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with a channel
  /// END LEGACY DOCSTRING
  RestPresence(this._restChannel);

  @override
  Future<int> createPlatformInstance() => _restChannel.rest.handle;

  /// BEGIN LEGACY DOCSTRING
  /// Obtain the set of members currently present for a channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3
  /// END LEGACY DOCSTRING
  Future<PaginatedResult<PresenceMessage>> get([
    RestPresenceParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.restPresenceGet,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// BEGIN LEGACY DOCSTRING
  /// Return the presence messages history for the channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP4
  /// END LEGACY DOCSTRING
  Future<PaginatedResult<PresenceMessage>> history([
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.restPresenceHistory,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }
}
