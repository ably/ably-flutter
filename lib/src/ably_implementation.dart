import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../ably.dart';

class AblyImplementation implements Ably {
  static int _currentId = 0;
  final int _id;
  final methodChannel;
  final List<PlatformObject> _platformObjects = [];

  factory AblyImplementation() {
    final int id = ++_currentId;
    _currentId = 666;

    print('Creating Ably # $id');

    /// Uses our custom message codec so that we can pass Ably types to the
    /// platform implementations.
    final methodChannel = MethodChannel('ably_test_flutter_oldskool_plugin', StandardMethodCodec(Codec()));

    return AblyImplementation._constructor(id, methodChannel);
  }

  AblyImplementation._constructor(this._id, this.methodChannel) {
    Isolate.spawn(_ticker, this);
  }

  static const _notCurrent = 'Ably Flutter Plugin instance has been superceeded and is no longer current.';

  @override
  Future<Realtime> createRealtime(final ClientOptions options) async {
    if (!_amCurrent) throw StateError(_notCurrent);

    // TODO options.authCallback
    // TODO options.logHandler
    final r = RealtimePlatformObject(await methodChannel.invokeMethod('createRealtimeWithOptions', options));
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<String> get platformVersion async => _amCurrent ? await methodChannel.invokeMethod('getPlatformVersion') : throw StateError(_notCurrent);

  @override
  Future<String> get version async => _amCurrent ? await methodChannel.invokeMethod('getVersion') : throw StateError(_notCurrent);

  bool get _amCurrent => _id == _currentId;

  void _dispose() async {
    final List<int> handles = [];
    for (final PlatformObject platformObject in _platformObjects) {
      handles.add(platformObject.handle);
    }
    _platformObjects.clear();

    await methodChannel.invokeMethod('dispose', handles);
  }

  static void _ticker(final AblyImplementation instance) async {
    do {
      // TODO assess how appropriate the arbitrary value of 250ms (4 Hz) is
      sleep(Duration(milliseconds: 250));
      if (!instance._amCurrent) {
        // This instance is no longer the latest.
        print('Disposing of superceeded Ably Flutter Plugin instance # ${instance._id} [$instance] (current is now $_currentId)');
        await instance._dispose();
      }
    } while (true);
  }
}

/// An object which has a live counterpart in the Platform client library SDK.
abstract class PlatformObject {
  final int handle;

  PlatformObject(this.handle);

  @override
  String toString() => 'Ably Platform Object $handle';

  static Future<int> dispose() async {

  }
}

class RealtimePlatformObject extends PlatformObject implements Realtime {
  RealtimePlatformObject(int handle) : super(handle);

  @override
  // TODO: implement channels
  Channels get channels => null;

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void connect() {
    // TODO: implement connect
  }

  @override
  // TODO: implement connection
  Connection get connection => null;
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
    } else {
      super.writeValue(buffer, value);
    }
  }
}
