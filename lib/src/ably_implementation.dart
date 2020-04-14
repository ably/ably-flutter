import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably.dart';
import 'impl/platform_object.dart';
import 'impl/realtime.dart';
import 'impl/rest.dart';

extension on PlatformMethod {
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
    final methodChannel = MethodChannel('ably_flutter_plugin', StandardMethodCodec(Codec()));
    return AblyImplementation._constructor(methodChannel);
  }

  AblyImplementation._constructor(this.methodChannel);

  Future<int> _register() async => (null != _handle) ? _handle : _handle = await methodChannel.invokeMethod(PlatformMethod.register.toName());

  @override
  Future<Realtime> createRealtime(final ClientOptions options) async {
    // TODO options.authCallback
    // TODO options.logHandler
    final handle = await _register();
    final message = AblyMessage(handle, options);
    final r = RealtimePlatformObject(
        handle,
        methodChannel,
        await methodChannel.invokeMethod(
            PlatformMethod.createRealtimeWithOptions.toName(),
            message
        )
    );
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<Rest> createRest(final ClientOptions options) async {
    // TODO options.authCallback
    // TODO options.logHandler
    final handle = await _register();
    final message = AblyMessage(handle, options);
    final r = RestPlatformObject(
        handle,
        methodChannel,
        await methodChannel.invokeMethod(
            PlatformMethod.createRestWithOptions.toName(),
            message
        )
    );
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<String> get platformVersion async =>
      await methodChannel.invokeMethod(PlatformMethod.getPlatformVersion.toName());

  @override
  Future<String> get version async =>
      await methodChannel.invokeMethod(PlatformMethod.getVersion.toName());
}

class Codec extends StandardMessageCodec {
  // Custom type values must be over 127. At the time of writing the standard message
  // codec encodes them as an unsigned byte which means the maximum type value is 255.
  // If we get to the point of having more than that number of custom types (i.e. more
  // than 128 [255 - 127]) then we can either roll our own codec from scratch or,
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
      writeValue(buffer, v.useTokenAuth);

      // ClientOptions
      writeValue(buffer, v.clientId);
      writeValue(buffer, v.log.level);
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
