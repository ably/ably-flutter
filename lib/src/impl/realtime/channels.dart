import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';

import '../../../ably_flutter_plugin.dart';
import '../../spec/push/channels.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'realtime.dart';

class RealtimePlatformChannel extends PlatformObject
    implements spec.RealtimeChannel {
  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.RealtimePresence presence;

  RealtimePlatformChannel(this.ably, this.name, this.options) : super() {
    state = spec.ChannelState.initialized;
    on().listen((ChannelStateChange event) {
      state = event.current;
    });
  }

  Realtime get realtimePlatformObject => ably as Realtime;

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async =>
      await realtimePlatformObject.handle;

  @override
  Future<spec.PaginatedResult<spec.Message>> history(
      [spec.RealtimeHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  Map<String, dynamic> __payload;

  Map<String, dynamic> get _payload => __payload ??= {
        'channel': name,
        if (options != null) 'options': options
      };

  final _publishQueue = Queue<_RealtimePublishQueueItem>();
  Completer<void> _authCallbackCompleter;

  @override
  Future<void> publish({
    spec.Message message,
    List<spec.Message> messages,
    String name,
    dynamic data,
  }) async {
    if (messages == null) {
      if (message != null) {
        messages = [message];
      } else {
        messages ??= [
          spec.Message(
            name: name,
            data: data
          )
        ];
      }
    }
    final queueItem = _RealtimePublishQueueItem(
        Completer<void>(), message, messages);
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
                    .forEach((e) => e.completer.completeError(TimeoutException(
                        'Timed out', Timeouts.retryOperationOnAuthFailure))));
          } finally {
            _authCallbackCompleter = null;
          }
        } else {
          _publishQueue.where((e) => !e.completer.isCompleted).forEach((e) =>
              e.completer.completeError(
                  spec.AblyException(pe.code, pe.message, pe.details)));
        }
      }
    }
    _publishInternalRunning = false;
  }

  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
  }

  @override
  spec.ErrorInfo errorReason;

  @override
  List<spec.ChannelMode> modes;

  @override
  Map<String, String> params;

  @override
  PushChannel push;

  @override
  spec.ChannelState state;

  @override
  Future<void> attach() async {
    try {
      await invoke(PlatformMethod.attachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> detach() async {
    try {
      await invoke(PlatformMethod.detachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> setOptions(spec.ChannelOptions options) async {
    throw AblyException(null, 'Realtime chanel options are not supported yet.');
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent channelEvent]) {
    return listen(PlatformMethod.onRealtimeChannelStateChanged, _payload)
        .map((stateChange) => stateChange as ChannelStateChange)
        .where((stateChange) =>
            channelEvent == null || stateChange.event == channelEvent);
  }

  @override
  Stream<spec.Message> subscribe({String name, List<String> names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen(PlatformMethod.onRealtimeChannelMessage, _payload)
        .map((message) => message as spec.Message)
        .where((message) =>
            subscribedNames.isEmpty ||
            subscribedNames.any((n) => n == message.name));
  }
}

class RealtimePlatformChannels
    extends spec.RealtimeChannels<RealtimePlatformChannel> {
  RealtimePlatformChannels(Realtime ably) : super(ably);

  @override
  RealtimePlatformChannel createChannel(name, options) {
    return RealtimePlatformChannel(ably, name, options);
  }
}

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class _RealtimePublishQueueItem {
  spec.Message message;
  List<spec.Message> messages;
  final Completer<void> completer;

  _RealtimePublishQueueItem(
      this.completer, this.message, this.messages);
}
