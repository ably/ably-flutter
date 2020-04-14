import 'platform_object.dart';
import '../spec/spec.dart' show Connection, ConnectionEvent, EventListener, ErrorInfo, ConnectionState;
import 'event_listener.dart';


class ConnectionIndirectPlatformObject extends IndirectPlatformObject implements Connection {
  ConnectionIndirectPlatformObject(PlatformObject provider) : super(provider, IndirectPlatformObject.connection);

  @override
  Future<EventListener<ConnectionEvent>> createListener() async {
    final handle = await provider.invoke(PlatformMethod.createListener, type);
    return ConnectionListenerPlatformObject(provider.ablyHandle, provider.methodChannel, handle);
  }

  @override
  Future<void> off() async {
    await provider.invoke(PlatformMethod.eventsOff, type);
  }

  @override
  ErrorInfo errorReason;

  @override
  String id;

  @override
  String key;

  @override
  String recoveryKey;

  @override
  int serial;

  @override
  ConnectionState state;

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void connect() {
    // TODO: implement connect
  }

  @override
  Future<int> ping() {
    // TODO: implement ping
    return null;
  }
}