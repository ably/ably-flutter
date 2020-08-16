import 'dart:async';
import 'dart:collection';
import 'package:pedantic/pedantic.dart';
import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/rest/rest.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';

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

  Rest get restPlatformObject => this.ably as Rest;

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => await restPlatformObject.handle;

  @override
  Future<spec.PaginatedResult<spec.Message>> history(
      [spec.RestHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  final _publishQueue = Queue<_PublishQueueItem>();
  Completer<void> _authCallBackCompleter;

  static const defaultPublishTimout = Duration(seconds: 30);

  @override
  Future<void> publish({String name, Object data}) async {
    final queueItem = _PublishQueueItem(Completer<void>(), name, data);
    _publishQueue.add(queueItem);
    unawaited(_publishInternal());
    return queueItem.completer.future.timeout(defaultPublishTimout,
        onTimeout: () {
      queueItem.completer.complete();
      throw TimeoutException('Timed out', defaultPublishTimout);
    });
  }

  Future<void> _publishInternal() async {
    if (_authCallBackCompleter != null) {
      return;
    }
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
        // completed Completer ;-) would cause an exception.
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      } on PlatformException catch (pe) {
        if (pe.code == '80019') {
          _authCallBackCompleter = Completer<void>();
          await _authCallBackCompleter.future.timeout(defaultPublishTimout,
              onTimeout: () => _publishQueue
                      .where((e) => !e.completer.isCompleted)
                      .forEach((e) {
                    e.completer.completeError(
                        TimeoutException('Timed out', defaultPublishTimout));
                  }));
          _authCallBackCompleter = null;
        } else {
          _publishQueue.remove(item);
          if (!item.completer.isCompleted) {
            item.completer.completeError(
                spec.AblyException(pe.code, pe.message, pe.details));
          }
        }
      }
    }
  }

  void authUpdateComplete() {
    _authCallBackCompleter.complete();
  }
}

class RestPlatformChannels extends spec.RestChannels<RestPlatformChannel> {
  RestPlatformChannels(Rest ably) : super(ably);

  @override
  RestPlatformChannel createChannel(name, options) {
    return RestPlatformChannel(this.ably, name, options);
  }
}

class _PublishQueueItem {
  final String name;
  final Object data;
  final Completer<void> completer;

  _PublishQueueItem(this.completer, this.name, this.data);
}
