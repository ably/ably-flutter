import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/rest/channels.dart';
import 'package:ably_flutter_plugin/src/method_call_handler.dart';
import 'package:ably_flutter_plugin/src/platform.dart' as platform;
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

void main() {
  final methodChannel = platform.methodChannel;

  TestWidgetsFlutterBinding.ensureInitialized();

  // Used to generate unique handle ids
  var handleCounter;

  // Keep created channel instances associated with its handle.
  final channels = <int, AblyMessage>{};

  var publishedMessages = <AblyMessage>[];

  setUp(() {
    channels.clear();
    publishedMessages.clear();
    handleCounter = 0;
    var isAuthenticated = false;

    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case PlatformMethod.registerAbly:
          return true;

        case PlatformMethod.createRestWithOptions:
        case PlatformMethod.createRealtimeWithOptions:
          final handle = ++handleCounter;
          channels[handle] = methodCall.arguments as AblyMessage;
          return handle;

        case PlatformMethod.publish:
          final message = methodCall.arguments as AblyMessage;
          final handle = (message.message as AblyMessage).handle;
          final ablyChannel = channels[handle];
          final clientOptions = ablyChannel.message as ClientOptions;

          // `authUrl` is used to indicate the presense of an authCallback,
          // because function references (in `authCallback`) get dropped by the
          // PlatformChannel.
          if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
            await AblyMethodCallHandler(methodChannel).onAuthCallback(
                AblyMessage(TokenParams(timestamp: DateTime.now()),
                    handle: handle));
            isAuthenticated = true;
            throw PlatformException(
                code: RestPlatformChannel
                    .clientConfiguredAuthenticationProviderRequestFailed);
          }

          publishedMessages.add(message);
          return null;

        default:
          return throw 'Unexpected channel method call: ${methodCall.method}'
              ' args: ${methodCall.arguments}';
      }
    });
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
  });

  test('publish message without authCallback', () async {
    // setup
    final rest = Rest(key: 'TEST-KEY');
    final channel = await rest.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data1');

    // verification
    expect(publishedMessages.length, 1);
    final firstMessage = publishedMessages.first.message as AblyMessage;
    final messageData = firstMessage.message as Map<dynamic, dynamic>;
    expect(messageData['channel'], 'test');
    expect(messageData['name'], 'name');
    expect(messageData['message'], 'data1');
  });

  test('publish message with authCallback', () async {
    // setup
    final authCallback = expectAsync1((token) async {}, max: 2);

    final options = ClientOptions()
      ..authCallback = authCallback
      ..authUrl = 'hasAuthCallback';
    final rest = Rest(options: options, key: 'TEST-KEY');

    final channel = rest.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data2');

    // verification

    expect(publishedMessages.length, 1);
    final firstMessage = publishedMessages.first.message as AblyMessage;
    final messageData = firstMessage.message as Map<dynamic, dynamic>;
    expect(messageData['channel'], 'test');
    expect(messageData['name'], 'name');
    expect(messageData['message'], 'data2');
  });

  test('publish message with authCallback timing out', () async {
    // setup
    final tooMuchDelay =
        RestPlatformChannel.defaultPublishTimout + Duration(seconds: 2);
    var authCallbackCounter = 0;

    Future timingOutOnceThenSucceedsAuthCallback(TokenParams token) {
      if (authCallbackCounter == 0) {
        authCallbackCounter++;
        throw TimeoutException('Timed out');
      }
      return Future.value();
    }

    unawaited(
      fakeAsync((async) async {
        final options = ClientOptions()
          ..authCallback = timingOutOnceThenSucceedsAuthCallback
          ..authUrl = 'hasAuthCallback';
        final rest = Rest(options: options, key: 'TEST-KEY');
        final channel = rest.channels.get('test');

        // exercise
        final future1 = channel.publish(name: 'name', data: 'data3-1');
        final future2 = channel.publish(name: 'name', data: 'data3-2');

        // verification
        expect(future1, throwsA(isA<AblyException>()));
        expect(future2, throwsA(isA<AblyException>()));

        async.elapse(tooMuchDelay);

        expect(publishedMessages.length, 0);

        // Send another message after timeout with authCallback succeeding

        // setup
        // exercise
        final future3 = channel.publish(name: 'name', data: 'data3-3');

        // verification
        async.elapse(Duration.zero);
        await future3;

        expect(publishedMessages.length, 1);

        final firstMessage = publishedMessages.first.message as AblyMessage;
        final messageData = firstMessage.message as Map<dynamic, dynamic>;
        expect(messageData['channel'], 'test');
        expect(messageData['name'], 'name');
        expect(messageData['message'], 'data3-2');
      }),
    );
  });

  test('publish 2 message with authCallback', () async {
    // setup
    final authCallback = expectAsync1((token) async {});

    final options = ClientOptions()
      ..authCallback = authCallback
      ..authUrl = 'hasAuthCallback';
    final rest = Rest(options: options, key: 'TEST-KEY');
    final channel = rest.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data4');
    await channel.publish(name: 'name', data: 'data5');

    // verification
    expect(publishedMessages.length, 2);
    final message0 = publishedMessages[0].message as AblyMessage;
    final messageData0 = message0.message as Map<dynamic, dynamic>;
    expect(messageData0['channel'], 'test');
    expect(messageData0['name'], 'name');
    expect(messageData0['message'], 'data4');

    final message1 = publishedMessages[1].message as AblyMessage;
    final messageData1 = message1.message as Map<dynamic, dynamic>;
    expect(messageData1['channel'], 'test');
    expect(messageData1['name'], 'name');
    expect(messageData1['message'], 'data5');

    // });
  }, timeout: Timeout.none);
}
