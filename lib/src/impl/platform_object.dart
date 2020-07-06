import 'dart:async';

import 'package:ably_flutter_plugin/src/interface.dart';
import 'package:ably_flutter_plugin/src/ably_implementation.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';


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
    // to platform side. These initiators need to be server after platform
    // has responded with proper handle, so a short hold and re-check will
    // return the handle whenever it is available.
    // 250ms is arbitrarily set as delay duration considering that is a fairly
    // reasonable timeout for platform to respond.
    if(_registering){
      await Future.delayed(Duration(milliseconds: 250));
      return await this.handle;
    }
    if(_handle == null) {
      _registering = true;
      _handle = await createPlatformInstance();
      _registering = false;
    }
    return _handle;
  }

  AblyImplementation get _ablyPlugin => (Ably as AblyImplementation);
  MethodChannel get methodChannel => _ablyPlugin.methodChannel;
  StreamsChannel get eventChannel => _ablyPlugin.streamsChannel;

  static Future<int> dispose() async {
    //TODO implement or convert to abstract!
    return null;
  }

  /// Call a method.
  Future<dynamic> invoke(final String method, [final dynamic argument]) async {
    int _handle = await handle;
    final message = (null != argument)
      ? AblyMessage(AblyMessage(argument, handle: _handle))
      : AblyMessage(_handle);
    return await Ably.invoke(method, message);
  }

  Future<Stream<dynamic>> _listen(final String method) async {
    return eventChannel.receiveBroadcastStream(
      AblyMessage(AblyMessage(method, handle: await handle))
    );
  }

  /// Listen for events
  Stream<dynamic> listen(final String method){
    StreamController<dynamic> controller = StreamController<dynamic>();
    _listen(method).then(controller.addStream);
    return controller.stream;
  }

}
