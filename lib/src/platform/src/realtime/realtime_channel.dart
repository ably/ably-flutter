import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../../common/src/backwards_compatibility.dart';
import '../../../error/error.dart';
import '../../../generated/platform_constants.dart';
import '../../../message/message.dart';
import '../../../push_notifications/push_notifications.dart';
import '../../../realtime/realtime.dart';
import '../../../realtime/src/realtime_channel_options.dart';
import '../../../realtime/src/realtime_channels_interface.dart';
import '../../platform.dart';
import '../../platform_internal.dart';

/// Plugin based implementation of Realtime channel
class RealtimeChannel extends PlatformObject
    implements RealtimeChannelInterface {
  @override
  final RealtimeInterface realtime;

  @override
  final String name;

  late RealtimePresence _presence;

  @override
  RealtimePresence get presence => _presence;

  /// instantiates with [Rest], [name] and [RealtimeChannelOptions]
  ///
  /// sets default [state] to [ChannelState.initialized] and start listening
  /// for updates to the channel [state]/
  RealtimeChannel(this.realtime, this.name)
      : state = ChannelState.initialized,
        super() {
    _presence = RealtimePresence(this);
    push = PushChannelNative(name, realtime: realtime);
    on().listen((event) => state = event.current);
  }

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime
  /// instance and send message to channel
  @override
  Future<int> createPlatformInstance() async => (realtime as Realtime).handle;

  @override
  Future<PaginatedResult<Message>> history([
    RealtimeHistoryParams? params,
  ]) async {
    final message =
        await invokeRequest<AblyMessage>(PlatformMethod.realtimeHistory, {
      TxTransportKeys.channelName: name,
      if (params != null) TxTransportKeys.params: params
    });
    return PaginatedResult<Message>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  final _publishQueue = Queue<PublishQueueItem>();
  Completer<void>? _authCallbackCompleter;

  @override
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  }) async {
    messages ??= [
      if (message == null) Message(name: name, data: data) else message
    ];
    final queueItem = PublishQueueItem(Completer<void>(), messages);
    _publishQueue.add(queueItem);
    unawaitedWorkaroundForDartPre214(_publishInternal());
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
          TxTransportKeys.channelName: name,
          TxTransportKeys.messages: item.messages,
        });

        _publishQueue.remove(item);

        // The Completer could have timed out in the meantime and completing a
        // completed Completer would cause an exception, so we check first.
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      } on AblyException catch (ae) {
        if (ae.code == ErrorCodes.authCallbackFailure.toString()) {
          if (_authCallbackCompleter != null) {
            return;
          }
          _authCallbackCompleter = Completer<void>();
          try {
            await _authCallbackCompleter!.future.timeout(
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
              .forEach((e) => e.completer.completeError(ae));
        }
      } on PlatformException catch (pe) {
        _publishQueue.where((e) => !e.completer.isCompleted).forEach((e) =>
            e.completer.completeError(AblyException.fromPlatformException(pe)));
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
  ErrorInfo? errorReason;

  @override
  List<ChannelMode>? modes;

  @override
  Map<String, String>? params;

  @override
  late PushChannel push;

  @override
  ChannelState state;

  @override
  Future<void> attach() => invoke(PlatformMethod.attachRealtimeChannel, {
        TxTransportKeys.channelName: name,
      });

  @override
  Future<void> detach() => invoke(PlatformMethod.detachRealtimeChannel, {
        TxTransportKeys.channelName: name,
      });

  @override
  Future<void> setOptions(RealtimeChannelOptions options) =>
      invoke(PlatformMethod.setRealtimeChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });

  @override
  Stream<ChannelStateChange> on([ChannelEvent? channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        {TxTransportKeys.channelName: name},
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  @override
  Stream<Message> subscribe({String? name, List<String>? names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, {
      TxTransportKeys.channelName: this.name,
    }).where((message) =>
        subscribedNames.isEmpty ||
        subscribedNames.any((n) => n == message.name));
  }
}

/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
class RealtimePlatformChannels
    extends RealtimeChannelsInterface<RealtimeChannel> {
  /// instantiates with the ably [Realtime] instance
  RealtimePlatformChannels(Realtime realtime) : super(realtime);

  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  @override
  void release(String name) {
    super.release(name);
    (realtime as Realtime).invoke(PlatformMethod.releaseRealtimeChannel, name);
  }
}
