import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';


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
  final MethodChannel _methodChannel;
  final int _handle;


  PlatformObject(this._ablyHandle, this._methodChannel, this._handle);

  @override
  String toString() => 'Ably Platform Object $_handle';

  get handle => _handle;
  get ablyHandle => _ablyHandle;
  get methodChannel => _methodChannel;

  static Future<int> dispose() async {
    //TODO implement or convert to abstract!
    return null;
  }

  /// Call a method.
  Future<dynamic> invoke(final PlatformMethod method, [final dynamic argument]) async {
    final message = (null != argument)
        ? AblyMessage(_ablyHandle, AblyMessage(_handle, argument))
        : AblyMessage(_ablyHandle, _handle);
    return await _methodChannel.invokeMethod(method.toName(), message);
  }
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

  PlatformObject get provider => _provider;
  int get type => _type;

}
