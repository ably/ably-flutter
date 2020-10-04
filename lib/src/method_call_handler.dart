import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:ably_flutter_plugin/src/generated/platformconstants.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';

class AblyMethodCallHandler {
  AblyMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.authCallback:
          return onAuthCallback(call.arguments as AblyMessage);
        case PlatformMethod.realtimeAuthCallback:
          return onRealtimeAuthCallback(call.arguments as AblyMessage);
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  Future<Object> onAuthCallback(AblyMessage message) async {
    var tokenParams = message.message as ably.TokenParams;
    var rest = ably.restInstances[message.handle];
    final callbackResponse = await rest.options.authCallback(tokenParams);
    Future.delayed(Duration.zero, rest.authUpdateComplete);
    return callbackResponse;
  }

  bool _realtimeAuthInProgress = false;

  Future<Object> onRealtimeAuthCallback(AblyMessage message) async {
    if (_realtimeAuthInProgress) {
      return null;
    }
    _realtimeAuthInProgress = true;
    var tokenParams = message.message as ably.TokenParams;
    var realtime = ably.realtimeInstances[message.handle];
    Object callbackResponse = await realtime.options.authCallback(tokenParams);
    Future.delayed(Duration.zero, realtime.authUpdateComplete);
    _realtimeAuthInProgress = false;
    return callbackResponse;
  }
}
