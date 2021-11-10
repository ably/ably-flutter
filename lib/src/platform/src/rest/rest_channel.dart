import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL1
class RestChannel extends PlatformObject {
  /// reference to Rest client
  Rest rest;

  /// Channel to receive push notifications on
  PushChannel push;

  /// name of the channel
  String name;

  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL3
  late RestPresence _presence;

  /// instantiates with [Rest], [name] and [RestChannelOptions]
  RestChannel(this.rest, this.push, this.name) {
    _presence = RestPresence(this);
  }

  RestPresence get presence => _presence;

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => rest.handle;

  /// fetch message history on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2
  Future<PaginatedResult<Message>> history([
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.restHistory,
      {
        TxTransportKeys.channelName: name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<Message>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  final _publishQueue = Queue<PublishQueueItem>();
  Completer<void>? _authCallbackCompleter;

  /// publish messages on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL1
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
        final _map = <String, Object>{
          TxTransportKeys.channelName: name,
          TxTransportKeys.messages: item.messages,
        };

        await invoke(PlatformMethod.publish, _map);

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
                      )),
            );
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

  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL7
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
