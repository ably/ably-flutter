import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef MethodCallHandler = Future<dynamic> Function(MethodCall);

class MockMethodCallManager {
  int handleCounter = 0;
  bool isAuthenticated = false;
  final channels = <int, AblyMessage?>{};
  final publishedMessages = <AblyMessage>[];

  MockMethodCallManager() {
    final channel =
        MethodChannel('io.ably.flutter.plugin', StandardMethodCodec(Codec()));
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
    Platform(methodChannel: channel);
  }

  void reset() {
    channels.clear();
    publishedMessages.clear();
    handleCounter = 0;
    final channel =
        MethodChannel('io.ably.flutter.plugin', StandardMethodCodec(Codec()));
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
    Platform(methodChannel: channel);
  }

  Future<dynamic> handler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case PlatformMethod.resetAblyClients:
        return true;

      case PlatformMethod.createRest:
      case PlatformMethod.createRealtime:
        final handle = ++handleCounter;
        channels[handle] = methodCall.arguments as AblyMessage?;
        return handle;

      case PlatformMethod.publish:
        final message = methodCall.arguments as AblyMessage;
        final handle = (message.message as AblyMessage).handle;
        final ablyChannel = channels[handle!]!;
        final clientOptions = ablyChannel.message as ClientOptions;

        // `authUrl` is used to indicate the presence of an authCallback,
        // because function references (in `authCallback`) get dropped by the
        // PlatformChannel.
        if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
          final channel = MethodChannel(
              'io.ably.flutter.plugin', StandardMethodCodec(Codec()));
          await AblyMethodCallHandler(channel).onAuthCallback(
            AblyMessage(
              TokenParams(timestamp: DateTime.now()),
              handle: handle,
            ),
          );
          isAuthenticated = true;
        }
        publishedMessages.add(message);
        return null;

      case PlatformMethod.publishRealtimeChannelMessage:
        final message = methodCall.arguments as AblyMessage;
        final handle = (message.message as AblyMessage).handle;
        final ablyChannel = channels[handle!]!;
        final clientOptions = ablyChannel.message as ClientOptions;

        // `authUrl` is used to indicate the presence of an authCallback,
        // because function references (in `authCallback`) get dropped by the
        // PlatformChannel.
        if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
          final channel = MethodChannel(
              'io.ably.flutter.plugin', StandardMethodCodec(Codec()));
          await AblyMethodCallHandler(channel).onRealtimeAuthCallback(
            AblyMessage(TokenParams(timestamp: DateTime.now()), handle: handle),
          );
          isAuthenticated = true;
        }

        publishedMessages.add(message);
        return null;

      case PlatformMethod.releaseRestChannel:
      case PlatformMethod.releaseRealtimeChannel:
        return null;

      default:
        return throw Exception('Unexpected method call: ${methodCall.method}'
            ' args: ${methodCall.arguments}');
    }
  }
}
