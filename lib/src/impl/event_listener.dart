 import 'platform_object.dart';
 import '../spec/spec.dart' show ConnectionEvent, EventListener;
 import 'package:flutter/services.dart';


class ConnectionListenerPlatformObject extends PlatformObject implements EventListener<ConnectionEvent> {
  ConnectionListenerPlatformObject(int ablyHandle, MethodChannel methodChannel, int handle)
      : super(ablyHandle, methodChannel, handle);

  @override
  Future<void> off() async {
    await invoke(PlatformMethod.eventsOff);
  }

  @override
  Stream<ConnectionEvent> on([ConnectionEvent event]) async* {
    // Based on:
    // https://medium.com/flutter/flutter-platform-channels-ce7f540a104e#03ed
    // https://dart.dev/tutorials/language/streams#transform-function
    // TODO do we need to send a message to register first?
    final stream = EventChannel('com.ably/$handle').receiveBroadcastStream();
    await for (final event in stream) {
      yield event;
    }
  }

  @override
  Future<ConnectionEvent> once([ConnectionEvent event]) async {
    final result = await invoke(PlatformMethod.eventOnce, event);
    switch (result) {
      case 'initialized': return ConnectionEvent.initialized;
      case 'connecting': return ConnectionEvent.connecting;
      case 'connected': return ConnectionEvent.connected;
      case 'disconnected': return ConnectionEvent.disconnected;
      case 'suspended': return ConnectionEvent.suspended;
      case 'closing': return ConnectionEvent.closing;
      case 'closed': return ConnectionEvent.closed;
      case 'failed': return ConnectionEvent.failed;
      case 'update': return ConnectionEvent.update;
    }
    throw('Unhandled result "$result".');
  }
}