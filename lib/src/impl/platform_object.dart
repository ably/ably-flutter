import 'package:ably_flutter_plugin/src/ably_implementation.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';


/// A method with a corresponding handler in platform code.
enum PlatformMethod {
  getPlatformVersion,
  getVersion,
  register,

  /// Rest
  createRestWithOptions,
  publish,

  /// Realtime
  createRealtimeWithOptions,
  connectRealtime,
  closeRealtime,

  /// Create an event listener. Called against a platform object (e.g. Realtime) with
  /// the argument being the type of indirect platform object against which the
  /// listener is to be created (e.g. Connection).
  createListener,

  eventsOff,
  eventsOn,
  eventOnce,
}

///Extension to extract string name from PlatformMethod
extension on PlatformMethod {

  /// ref: https://stackoverflow.com/a/59308734/392847
  String toName() => this.toString().split('.').last;

}


/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is held as a strong reference by the plugin
/// implementation.
abstract class PlatformObject {
  final int _ablyHandle;
  final AblyImplementation _ablyPlugin;
  final int _handle;


  PlatformObject(this._ablyHandle, this._ablyPlugin, this._handle);

  @override
  String toString() => 'Ably Platform Object $_handle';

  get handle => _handle;
  get ablyHandle => _ablyHandle;
  MethodChannel get methodChannel => _ablyPlugin.methodChannel;
  StreamsChannel get eventChannel => _ablyPlugin.streamsChannel;

  static Future<int> dispose() async {
    //TODO implement or convert to abstract!
    return null;
  }

  /// Call a method.
  Future<dynamic> invoke(final PlatformMethod method, [final dynamic argument]) async {
    final message = (null != argument)
        ? AblyMessage(_ablyHandle, AblyMessage(_handle, argument))
        : AblyMessage(_ablyHandle, _handle);
    return await methodChannel.invokeMethod(method.toName(), message);
  }

  Stream<dynamic> listen(final String eventName){
    return eventChannel.receiveBroadcastStream(AblyMessage(_ablyHandle, AblyMessage(_handle, eventName)));
  }

}
