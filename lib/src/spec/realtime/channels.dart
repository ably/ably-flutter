import '../common.dart';
import '../enums.dart';
import '../message.dart';
import '../push/channels.dart';
import '../rest/ably_base.dart';
import '../rest/channels.dart';
import 'presence.dart';

abstract class RealtimeChannel
    extends EventEmitter<ChannelEvent, ChannelStateChange> {
  RealtimeChannel(
    this.ably,
    this.name,
    this.options,
  );

  AblyBase ably;

  final String name; //Not in IDL
  final ChannelOptions options; //Not in IDL

  ErrorInfo errorReason;
  ChannelState state;
  RealtimePresence presence;

//  ChannelProperties properties;
  PushChannel push;
  List<ChannelMode> modes;
  Map<String, String> params;

  Future<void> attach();

  Future<void> detach();

  Future<PaginatedResultInterface<Message>> history([
    RealtimeHistoryParams params,
  ]);

  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  });

  Stream<Message> subscribe({
    String name,
    List<String> names,
  });

  void setOptions(ChannelOptions options);
}

abstract class RealtimeChannels<T extends RealtimeChannel> extends Channels<T> {
  RealtimeChannels(AblyBase ably) : super(ably);
}
