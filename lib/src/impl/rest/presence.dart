import '../../generated/platformconstants.dart';
import '../../spec/spec.dart';
import '../message.dart';
import '../paginated_result.dart';
import '../platform_object.dart';
import 'channels.dart';

class RestPresence extends PlatformObject implements RestPresenceBase {
  final RestPlatformChannel _restChannel;

  RestPresence(this._restChannel);

  @override
  Future<int> createPlatformInstance() =>
      _restChannel.restPlatformObject.handle;

  @override
  Future<PaginatedResult<PresenceMessage>> get([
    RestPresenceParams params,
  ]) async {
    final message = await invoke<AblyMessage>(
      PlatformMethod.restPresenceGet,
      {
        TxTransportKeys.channelName: _restChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(message);
  }

  @override
  Future<PaginatedResult<PresenceMessage>> history([
    RestHistoryParams params,
  ]) {
    throw UnimplementedError();
  }
}
