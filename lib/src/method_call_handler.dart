import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:ably_flutter_plugin/src/generated/platformconstants.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/services.dart';


class AblyMethodCallHandler{

  AblyMethodCallHandler(MethodChannel channel){
    channel.setMethodCallHandler((call) async {
      switch(call.method){
        case PlatformMethod.authCallback:
          return await onAuthCallback(call.arguments);
      }
    });
  }

  onAuthCallback(AblyMessage message) async {
    ably.TokenParams tokenParams = message.message as ably.TokenParams;
    return await ably.restInstances[message.handle].options.authCallback(tokenParams);
  }

}
