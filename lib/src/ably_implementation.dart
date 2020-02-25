import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../ably.dart';

/// A method with a corresponding handler in platform code.
enum Method {
  getPlatformVersion,
  getVersion,
  register,
  createRealtimeWithOptions,
  connectRealtime,

  /// Create an event listener. Called against a platform object (e.g. Realtime) with
  /// the argument being the type of indirect platform object against which the
  /// listener is to be created (e.g. Connection).
  createListener,

  eventsOff,
  eventsOn,
  eventOnce,
}

extension on Method {
  String toName() {
    // https://stackoverflow.com/a/59308734/392847
    return this.toString().split('.').last;
  }
}

class AblyImplementation implements Ably {
  final MethodChannel methodChannel;
  final List<PlatformObject> _platformObjects = [];
  int _handle;

  factory AblyImplementation() {
    print('Creating Ably');

    /// Uses our custom message codec so that we can pass Ably types to the
    /// platform implementations.
    final methodChannel = MethodChannel('ably_test_flutter_oldskool_plugin', StandardMethodCodec(Codec()));
    return AblyImplementation._constructor(methodChannel);
  }

  AblyImplementation._constructor(this.methodChannel);

  Future<int> _register() async => (null != _handle) ? _handle : _handle = await methodChannel.invokeMethod(Method.register.toName());

  @override
  Future<Realtime> createRealtime(final ClientOptions options) async {
    // TODO options.authCallback
    // TODO options.logHandler
    final handle = await _register();
    final message = AblyMessage(handle, options);
    final r = RealtimePlatformObject(handle, methodChannel, await methodChannel.invokeMethod(Method.createRealtimeWithOptions.toName(), message));
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<String> get platformVersion async => await methodChannel.invokeMethod(Method.getPlatformVersion.toName());

  @override
  Future<String> get version async => await methodChannel.invokeMethod(Method.getVersion.toName());
}

/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is held as a strong reference by the plugin
/// implementation.
abstract class PlatformObject {
  final int _ablyHandle;
  final MethodChannel _methodChannel;
  final int _handle;

  PlatformObject(this._ablyHandle, this._methodChannel, this._handle);

  @override
  String toString() => 'Ably Platform Object $_handle';

  static Future<int> dispose() async {

  }

  /// Call a method.
  Future<dynamic> invoke(final Method method, [final dynamic argument]) async {
    final message = (null != argument)
      ? AblyMessage(_ablyHandle, AblyMessage(_handle, argument))
      : AblyMessage(_ablyHandle, _handle);
    return await _methodChannel.invokeMethod(method.toName(), message);
  }
}

class RealtimePlatformObject extends PlatformObject implements Realtime {
  // The _connection instance keeps a reference to this platform object.
  // Ideally _connection would be final, but that would need 'late final' which is coming.
  // https://stackoverflow.com/questions/59449666/initialize-a-final-variable-with-this-in-dart#comment105082936_59450231
  ConnectionIndirectPlatformObject _connection;

  RealtimePlatformObject(int ablyHandle, MethodChannel methodChannel, int handle)
  : super(ablyHandle, methodChannel, handle) {
    _connection = ConnectionIndirectPlatformObject(this);
  }

  @override
  // TODO: implement channels
  Channels get channels => null;

  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<void> connect() async {
    await invoke(Method.connectRealtime);
  }

  @override
  Connection get connection => _connection;
}

class AblyMessage {
  final int registrationHandle;
  final dynamic message;

  AblyMessage(this.registrationHandle, this.message);
}

/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is only ever accessed by the plugin implementation
/// by reading a property on another platform object on demand.
abstract class IndirectPlatformObject {
  // Ideally the constant value for connection would be grouped or typed more strongly.
  // Possible approaches, albeit impossible (for now) with dart...
  // 1) Dart enums are not as feature rich as other languages:
  //    https://github.com/dart-lang/language/issues/158
  // 2) The concept of 'type branding' might help but that's also not yet a thing:
  //    https://github.com/dart-lang/sdk/issues/2626#issuecomment-464638272
  static final int connection = 1;

  final PlatformObject _provider;
  final int _type;

  IndirectPlatformObject(this._provider, this._type);
}

class ConnectionListenerPlatformObject extends PlatformObject implements EventListener<ConnectionEvent> {
  ConnectionListenerPlatformObject(int ablyHandle, MethodChannel methodChannel, int handle)
  : super(ablyHandle, methodChannel, handle);

  @override
  Future<void> off() async {
    await invoke(Method.eventsOff);
  }

  @override
  Stream<ConnectionEvent> on([ConnectionEvent event]) async* {
    // Based on:
    // https://medium.com/flutter/flutter-platform-channels-ce7f540a104e#03ed
    // https://dart.dev/tutorials/language/streams#transform-function
    // TODO do we need to send a message to register first?
    final stream = EventChannel('com.ably/$_handle').receiveBroadcastStream();
    await for (final event in stream) {
      yield event;
    }
  }

  @override
  Future<ConnectionEvent> once([ConnectionEvent event]) async {
    final result = await invoke(Method.eventOnce, event);
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

class ConnectionIndirectPlatformObject extends IndirectPlatformObject implements Connection {
  ConnectionIndirectPlatformObject(PlatformObject provider) : super(provider, IndirectPlatformObject.connection);

  @override
  Future<EventListener<ConnectionEvent>> createListener() async {
    final handle = await _provider.invoke(Method.createListener, _type);
    return ConnectionListenerPlatformObject(_provider._ablyHandle, _provider._methodChannel, handle);
  }

  @override
  Future<void> off() async {
    await _provider.invoke(Method.eventsOff, _type);
  }
}

class Codec extends StandardMessageCodec {
  // Custom type values must be over 127. At the time of writing the standard message
  // codec encodes them as an unsigned byte which means the maximum type value is 255.
  // If we get to the point of having more than that number of custom types (i.e. more
  // than 128 [255 - 127]) then we can either roll our own codec from scatch or,
  // perhaps easier, reserve custom type value 255 to indicate that it will be followed
  // by a subtype value - perhaps of a wider type.
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
  static const _valueClientOptions = 128;
  static const _valueAblyMessage = 129;

  @override
  void writeValue (final WriteBuffer buffer, final dynamic value) {
    if (value is ClientOptions) {
      buffer.putUint8(_valueClientOptions);
      final ClientOptions v = value;

      // AuthOptions (super class of ClientOptions)
      writeValue(buffer, v.authUrl);
      writeValue(buffer, v.authMethod);
      writeValue(buffer, v.key);
      writeValue(buffer, v.tokenDetails);
      writeValue(buffer, v.authHeaders);
      writeValue(buffer, v.authParams);
      writeValue(buffer, v.queryTime);
      writeValue(buffer, v.useAuthToken);

      // ClientOptions
      writeValue(buffer, v.clientId);
      writeValue(buffer, v.logLevel);
      writeValue(buffer, v.tls);
      writeValue(buffer, v.restHost);
      writeValue(buffer, v.realtimeHost);
      writeValue(buffer, v.port);
      writeValue(buffer, v.tlsPort);
      writeValue(buffer, v.autoConnect);
      writeValue(buffer, v.useBinaryProtocol);
      writeValue(buffer, v.queueMessages);
      writeValue(buffer, v.echoMessages);
      writeValue(buffer, v.recover);
      writeValue(buffer, v.proxy);
      writeValue(buffer, v.environment);
      writeValue(buffer, v.idempotentRestPublishing);
      writeValue(buffer, v.httpOpenTimeout);
      writeValue(buffer, v.httpRequestTimeout);
      writeValue(buffer, v.httpMaxRetryCount);
      writeValue(buffer, v.realtimeRequestTimeout);
      writeValue(buffer, v.fallbackHosts);
      writeValue(buffer, v.fallbackHostsUseDefault);
      writeValue(buffer, v.fallbackRetryTimeout);
      writeValue(buffer, v.defaultTokenParams);
      writeValue(buffer, v.channelRetryTimeout);
      writeValue(buffer, v.transportParams);
      writeValue(buffer, v.asyncHttpThreadpoolSize);
      writeValue(buffer, v.pushFullWait);
    } else if (value is AblyMessage) {
      buffer.putUint8(_valueAblyMessage);
      final AblyMessage v = value;
      writeValue(buffer, v.registrationHandle);
      writeValue(buffer, v.message);
    } else {
      super.writeValue(buffer, value);
    }
  }
}
