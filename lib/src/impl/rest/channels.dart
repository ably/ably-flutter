import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/paginated_result.dart';
import 'package:ably_flutter_plugin/src/impl/rest/rest.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';

import '../platform_object.dart';

class RestPlatformChannel extends PlatformObject implements spec.RestChannel {
  /// [Rest] instance
  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.Presence presence;

  RestPlatformChannel(this.ably, this.name, this.options);

  Rest get restPlatformObject => ably as Rest;

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => restPlatformObject.handle;

  @override
  Future<PaginatedResult<spec.Message>> history(
      [spec.RestHistoryParams params]) async {
    var message = await invoke<AblyMessage>(PlatformMethod.restHistory, {
      TxRestHistoryArguments.channelName: name,
      if (params != null) TxRestHistoryArguments.params: params
    });
    return PaginatedResult<Message>.fromAblyMessage(message);
  }

  final _publishQueue = Queue<_PublishQueueItem>();
  Completer<void> _authCallbackCompleter;

  @override
  Future<void> publish({String name, Object data}) async {
    final queueItem = _PublishQueueItem(Completer<void>(), name, data);
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
        final _map = <String, Object>{
          'channel': name,
          if (name != null) 'name': item.name,
          if (item.data != null) 'message': item.data,
        };

        await invoke(PlatformMethod.publish, _map);

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
                    .forEach((e) => e.completer.completeError(TimeoutException(
                        'Timed out', Timeouts.retryOperationOnAuthFailure))));
          } finally {
            _authCallbackCompleter = null;
          }
        } else {
          _publishQueue.where((e) => !e.completer.isCompleted).forEach((e) =>
              e.completer.completeError(spec.AblyException(
                  pe.code, pe.message, pe.details as ErrorInfo)));
        }
      }
    }
    _publishInternalRunning = false;
  }

  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
  }
}

class RestPlatformChannels extends spec.RestChannels<RestPlatformChannel> {
  RestPlatformChannels(Rest ably) : super(ably);

  @override
  RestPlatformChannel createChannel(String name, ChannelOptions options) =>
      RestPlatformChannel(ably, name, options);
}

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class _PublishQueueItem {
  final String name;
  final Object data;
  final Completer<void> completer;

  _PublishQueueItem(this.completer, this.name, this.data);
}
