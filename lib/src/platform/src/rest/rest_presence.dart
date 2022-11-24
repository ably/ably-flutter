import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables the retrieval of the current and historic presence set for a
/// channel.
class RestPresence extends PlatformObject {
  final RestChannel _restChannel;

  /// @nodoc
  /// instantiates with a channel
  RestPresence(this._restChannel);

  /// @nodoc
  @override
  Future<int> createPlatformInstance() => _restChannel.rest.handle;

  /// Retrieves the current members present on the channel and the metadata for
  /// each member, such as their [PresenceAction] and ID, based on provided
  /// [params].
  ///
  /// Returns a [PaginatedResult] object, containing an
  /// array of [PresenceMessage] objects.
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

  /// Retrieves a [PaginatedResult] object, containing an
  /// array of historical [PresenceMessage] objects for
  /// the channel, based on provided [params].
  ///
  /// If the channel is configured to persist messages, then
  /// presence messages can be retrieved from history for up to 72 hours in the
  /// past. If not, presence messages can only be retrieved from history for up
  /// to two minutes in the past.
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
