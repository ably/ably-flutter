import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// A named channel through with realtime client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via rest channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTL1
class RealtimeChannel extends PlatformObject {
  final Realtime realtime;

  final String name;

  late RealtimePresence _presence;

  /// https://docs.ably.com/client-lib-development-guide/features/#RTL9
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
  Future<int> createPlatformInstance() async => realtime.handle;

  /// returns channel history based on filters passed as [params]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10
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

  /// publishes messages onto the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL6
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

  /// will hold reason for failure of attaching to channel in such cases
  ErrorInfo? errorReason;

  /// modes of this channel as returned by Ably server
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
  List<ChannelMode>? modes;

  /// Subset of the params passed via [ClientOptions]
  /// that the server has recognised and validated
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4k
  Map<String, String>? params;

  // TODO(tihoic) RTL15 - experimental, ChannelProperties properties;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSH4
  /// (see IDL for more details)
  late PushChannel push;

  ChannelState state;

  /// Attaches the realtime client to this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4
  Future<void> attach() => invoke(PlatformMethod.attachRealtimeChannel, {
        TxTransportKeys.channelName: name,
      });

  /// Detaches the realtime client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL5
  Future<void> detach() => invoke(PlatformMethod.detachRealtimeChannel, {
        TxTransportKeys.channelName: name,
      });

  /// takes a [RealtimeChannelOptions]] object and sets or updates the
  /// stored channel options
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL16
  Future<void> setOptions(RealtimeChannelOptions options) =>
      invoke(PlatformMethod.setRealtimeChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });

  Stream<ChannelStateChange> on([ChannelEvent? channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        {TxTransportKeys.channelName: name},
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  /// subscribes for messages on this channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// Warning: the name/ names are not channel names, but message names.
  /// See [Message] for more information.
  ///
  /// Calling subscribe the first time on a channel will automatically attach
  /// that channel. If a channel is detached, subscribing again will not
  /// reattach the channel. Remember to call [RealtimeChannel.attach]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL7
  Stream<Message> subscribe({String? name, List<String>? names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, {
      TxTransportKeys.channelName: this.name,
    }).where((message) =>
        subscribedNames.isEmpty ||
        subscribedNames.any((n) => n == message.name));
  }
}
