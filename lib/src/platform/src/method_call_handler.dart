import 'package:flutter/services.dart';

import '../../authentication/authentication.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../platform.dart';
import 'ably_message.dart';

/// Handles method calls invoked from platform side to dart side
class AblyMethodCallHandler {
  /// creates instance with method channel and forwards calls respective
  /// instance methods: [onAuthCallback], [onRealtimeAuthCallback], etc
  AblyMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.authCallback:
          return onAuthCallback(call.arguments as AblyMessage);
        case PlatformMethod.realtimeAuthCallback:
          return onRealtimeAuthCallback(call.arguments as AblyMessage?);
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  /// handles auth callback for rest instances
  Future<Object> onAuthCallback(AblyMessage message) async {
    final tokenParams = message.message as TokenParams;
    final rest = restInstances[message.handle];
    if (rest == null) {
      throw AblyException('invalid message handle ${message.handle}');
    }
    final callbackResponse = await rest.options.authCallback!(tokenParams);
    Future.delayed(Duration.zero, rest.authUpdateComplete);
    return callbackResponse;
  }

  bool _realtimeAuthInProgress = false;

  /// handles auth callback for realtime instances
  Future<Object?> onRealtimeAuthCallback(AblyMessage? message) async {
    if (_realtimeAuthInProgress) {
      return null;
    }
    _realtimeAuthInProgress = true;
    final tokenParams = message!.message as TokenParams;
    final realtime = realtimeInstances[message.handle];
    if (realtime == null) {
      throw AblyException('invalid message handle ${message.handle}');
    }
    final callbackResponse = await realtime.options.authCallback!(tokenParams);
    Future.delayed(Duration.zero, realtime.authUpdateComplete);
    _realtimeAuthInProgress = false;
    return callbackResponse;
  }
}
