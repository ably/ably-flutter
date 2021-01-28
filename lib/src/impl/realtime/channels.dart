import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';

import '../../../ably_flutter.dart';
import '../../spec/push/channels.dart';
import '../message.dart';
import '../platform_object.dart';
import 'presence.dart';
import 'realtime.dart';

/// Plugin based implementation of Realtime channel
class RealtimeChannel extends PlatformObject
    implements RealtimeChannelInterface {
  @override
  RealtimeInterface realtime;

  @override
  String name;

  @override
  ChannelOptions options;

  RealtimePresence _presence;

  @override
  RealtimePresence get presence => _presence;

  /// instantiates with [Rest], [name] and [ChannelOptions]
  ///
  /// sets default [state] to [ChannelState.initialized] and start listening
  /// for updates to the channel [state]/
  RealtimeChannel(this.realtime, this.name, this.options) : super() {
    _presence = RealtimePresence(this);
    state = ChannelState.initialized;
    on().listen((event) => state = event.current);
  }

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime
  /// instance and send message to channel
  @override
  Future<int> createPlatformInstance() async => (realtime as Realtime).handle;

  @override
  Future<PaginatedResult<Message>> history([
    RealtimeHistoryParams params,
  ]) async {
    final message = await invoke<AblyMessage>(PlatformMethod.realtimeHistory, {
      TxTransportKeys.channelName: name,
      if (params != null) TxTransportKeys.params: params
    });
    return PaginatedResult<Message>.fromAblyMessage(message);
  }

  Map<String, dynamic> __payload;

  Map<String, dynamic> get _payload => __payload ??= {
        'channel': name,
        if (options != null) 'options': options,
      };

  final _publishQueue = Queue<_PublishQueueItem>();
  Completer<void> _authCallbackCompleter;

  @override
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  }) async {
    messages ??= [
      if (message == null) Message(name: name, data: data) else message
    ];
    final queueItem = _PublishQueueItem(Completer<void>(), messages);
    _publishQueue.add(queueItem);
    unawaited(_publishInternal());
    return queueItem.completer.future;
  }

  bool _publishInternalRunning = false;

  Future<void> _publishInternal() async {
    if (_publishInternalRunning) {
      return;
    }
    _publishInternalRunning = true;

    while (_publishQueue.isNotEmpty) {
      final item = _publishQueue.first;
      // This is the only place where failed items are removed from the queue.
      // In all other places (timeout exceptions) only the Completer is
      // completed with an error but left in the queue.  Other attempts became a
      // bit unwieldy.
      if (item.completer.isCompleted) {
        _publishQueue.remove(item);
        continue;
      }

      try {
        await invoke(PlatformMethod.publishRealtimeChannelMessage, {
          ..._payload,
          'messages': item.messages,
        });

        _publishQueue.remove(item);

        // The Completer could have timed out in the meantime and completing a
        // completed Completer would cause an exception, so we check first.
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      } on PlatformException catch (pe) {
        if (pe.code == ErrorCodes.authCallbackFailure.toString()) {
          if (_authCallbackCompleter != null) {
            return;
          }
          _authCallbackCompleter = Completer<void>();
          try {
            await _authCallbackCompleter.future.timeout(
                Timeouts.retryOperationOnAuthFailure,
                onTimeout: () => _publishQueue
                    .where((e) => !e.completer.isCompleted)
                    .forEach((e) => e.completer.completeError(
                          TimeoutException(
                            'Timed out',
                            Timeouts.retryOperationOnAuthFailure,
                          ),
                        )));
          } finally {
            _authCallbackCompleter = null;
          }
        } else {
          _publishQueue
              .where((e) => !e.completer.isCompleted)
              .forEach((e) => e.completer.completeError(AblyException(
                    pe.code,
                    pe.message,
                    pe.details as ErrorInfo,
                  )));
        }
      } on Exception {
        // removing item from queue and rethrowing exception
        _publishQueue.remove(item);
        rethrow;
      }
    }
    _publishInternalRunning = false;
  }

  /// @internal
  /// required due to the complications involved in the way ably-java expects
  /// authCallback to be performed synchronously, while method channel call from
  /// platform side to dart side is asynchronous
  ///
  /// discussion: https://github.com/ably/ably-flutter/issues/31
  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
  }

  @override
  ErrorInfo errorReason;

  @override
  List<ChannelMode> modes;

  @override
  Map<String, String> params;

  @override
  PushChannel push;

  @override
  ChannelState state;

  @override
  Future<void> attach() async {
    try {
      await invoke(PlatformMethod.attachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw AblyException(pe.code, pe.message, pe.details as ErrorInfo);
    }
  }

  @override
  Future<void> detach() async {
    try {
      await invoke(PlatformMethod.detachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw AblyException(pe.code, pe.message, pe.details as ErrorInfo);
    }
  }

  @override
  Future<void> setOptions(ChannelOptions options) async {
    throw UnimplementedError();
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        _payload,
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  @override
  Stream<Message> subscribe({String name, List<String> names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, _payload)
        .where((message) =>
            subscribedNames.isEmpty ||
            subscribedNames.any((n) => n == message.name));
  }
}

/// A collection of realtime channel objects
///
/// https://docs.ably.io/client-lib-development-guide/features/#RTS1
class RealtimePlatformChannels extends RealtimeChannels<RealtimeChannel> {
  /// instantiates with the ably [Realtime] instance
  RealtimePlatformChannels(Realtime realtime) : super(realtime);

  @override
  RealtimeChannel createChannel(String name, ChannelOptions options) =>
      RealtimeChannel(realtime, name, options);
}

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class _PublishQueueItem {
  List<Message> messages;
  final Completer<void> completer;

  _PublishQueueItem(this.completer, this.messages);
}
