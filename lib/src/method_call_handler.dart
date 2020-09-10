import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:ably_flutter_plugin/src/generated/platformconstants.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';

class AblyMethodCallHandler {
  AblyMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.authCallback:
          return await onAuthCallback(call.arguments);
        case PlatformMethod.realtimeAuthCallback:
          return await onRealtimeAuthCallback(call.arguments);
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
    Future.delayed(Duration.zero, () => rest.authUpdateComplete());
    return callbackResponse;
  }

  bool realtimeAuthInProgress = false;

  Future<Object> onRealtimeAuthCallback(AblyMessage message) async {
    if (realtimeAuthInProgress) {
      return null;
    }
    realtimeAuthInProgress = true;
    var tokenParams = message.message as ably.TokenParams;
    var realtime = ably.realtimeInstances[message.handle];
    Object callbackResponse = await realtime.options.authCallback(tokenParams);
    Future.delayed(Duration.zero, () => realtime.authUpdateComplete());
    realtimeAuthInProgress = false;
    return callbackResponse;
  }
}
