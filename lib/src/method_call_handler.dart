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
        default:
          throw PlatformException(
            code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  Future<dynamic> onAuthCallback(AblyMessage message) async {
    ably.TokenParams tokenParams = message.message as ably.TokenParams;
    ably.Rest rest = ably.restInstances[message.handle];
    final callbackResponse = await rest.options.authCallback(tokenParams);
    Future.delayed(Duration.zero, () {
      rest.channels.all.forEach((c) => c.authUpdateComplete());
    });
    return callbackResponse;
  }
}
