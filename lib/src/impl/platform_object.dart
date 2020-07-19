import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/platform.dart' as platform;
import 'package:flutter/services.dart';

import 'streams_channel.dart';


/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is held as a strong reference by the plugin
/// implementation.
abstract class PlatformObject {

  int _handle;

  PlatformObject(){
    this.handle;  //fetching asynchronous handle proactively...
  }

  @override
  String toString() => 'Ably Platform Object $_handle';

  Future<int> createPlatformInstance();

  bool _registering = false;
  Future<int> get handle async {
    // This handle can be required simultaneously or with less time difference
    // as a result of asynchronous invocations (from app code). There is
    // a very high probability that the handle is not acquired from
    // platform side yet, but another initiator is requesting the handle.
    // `_registering` serves as a flag to avoid another method call
    // to platform side. These initiators need to be served after platform
    // has responded with proper handle, so a short hold and re-check will
    // return the handle whenever it is available.
    // 10ms is set as delay duration based on the conversation here
    // https://github.com/ably/ably-flutter/pull/18#discussion_r450699980.
    //
    // If the total time exceeds 2 seconds, a TimeoutException is raised
    if(_registering){
      bool _registrationFailed = false;
      Future.delayed(Duration(seconds: 2), (){
        _registrationFailed = true;
      });
      while(true){
        await Future.delayed(Duration(milliseconds: 10));
        if(_registrationFailed){
          throw TimeoutException("Handle aquiring timed out");
        }
        if(_handle!=null){
          return _handle;
        }
      }
    }
    if(_handle == null) {
      _registering = true;
      _handle = await createPlatformInstance();
      _registering = false;
    }
    return _handle;
  }

  MethodChannel get methodChannel => platform.methodChannel;
  StreamsChannel get eventChannel => platform.streamsChannel;

  static Future<int> dispose() async {
    //TODO implement or convert to abstract!
    return null;
  }

  /// invoke platform method channel without AblyMessage encapsulation
  Future<T> invokeRaw<T>(final String method, [final dynamic arguments]) async {
    return await platform.invoke<T>(method, arguments);
  }

  /// invoke platform method channel with AblyMessage encapsulation
  Future<T> invoke<T>(final String method, [final dynamic argument]) async {
    int _handle = await handle;
    final message = (null != argument)
      ? AblyMessage(AblyMessage(argument, handle: _handle))
      : AblyMessage(_handle);
    return await invokeRaw<T>(method, message);
  }

  Future<Stream<dynamic>> _listen(final String eventName, [final dynamic payload]) async {
    return eventChannel.receiveBroadcastStream(
      AblyMessage(AblyEventMessage(eventName, payload), handle: await handle)
    );
  }

  /// Listen for events
  Stream<dynamic> listen(final String method, [final dynamic payload]){
    StreamController<dynamic> controller = StreamController<dynamic>();
    _listen(method, payload).then(controller.addStream);
    return controller.stream;
  }

}
