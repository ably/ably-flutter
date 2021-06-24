import '../../generated/platformconstants.dart';
import '../../spec/spec.dart';
import '../message.dart';
import '../paginated_result.dart';
import '../platform_object.dart';
import 'channels.dart';
import 'rest.dart';

/// Plugin based implementation of [RestPresenceInterface]
class RestPresence extends PlatformObject implements RestPresenceInterface {
  final RestChannel _restChannel;

  /// instantiates with a channel
  RestPresence(this._restChannel);

  @override
  Future<int> createPlatformInstance() => (_restChannel.rest as Rest).handle;

  @override
  Future<PaginatedResult<PresenceMessage>> get([
    RestPresenceParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.restPresenceGet,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  @override
  Future<PaginatedResult<PresenceMessage>> history([
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.restPresenceHistory,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }
}
