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

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves the current members present on the channel and the metadata for
  /// each member, such as their [PresenceAction]{@link PresenceAction} and ID.
  /// Returns a [PaginatedResult]{@link PaginatedResult} object, containing an
  /// array of [PresenceMessage]{@link PresenceMessage} objects.
  ///
  /// [limit] - An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  /// [clientId] - Filters the list of returned presence members by a specific
  /// client using its ID.
  /// [connectionId] - Filters the list of returned presence members by a
  /// specific connection using its ID.
  ///
  /// [PaginatedResult<PresenceMessage>] - 	A
  /// [PaginatedResult]{@link PaginatedResult} object containing an array of
  /// [PresenceMessage]{@link PresenceMessage} objects.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult]{@link PaginatedResult} object, containing an
  /// array of historical [PresenceMessage]{@link PresenceMessage} objects for
  /// the channel. If the channel is configured to persist messages, then
  /// presence messages can be retrieved from history for up to 72 hours in the
  /// past. If not, presence messages can only be retrieved from history for up
  /// to two minutes in the past.
  ///
  /// [start] - The time from which messages are retrieved, specified as
  /// milliseconds since the Unix epoch.
  /// [end] - The time until messages are retrieved, specified as milliseconds
  /// since the Unix epoch.
  /// [direction] - The order for which messages are returned in. Valid values
  /// are backwards which orders messages from most recent to oldest, or
  /// forwards which orders messages from oldest to most recent. The default is
  /// backwards.
  /// [limit] - An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  ///
  /// [PaginatedResult<PresenceMessage>] - 	A
  /// [PaginatedResult]{@link PaginatedResult} object containing an array of
  /// [PresenceMessage]{@link PresenceMessage} objects.
  /// END CANONICAL DOCSTRING
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
