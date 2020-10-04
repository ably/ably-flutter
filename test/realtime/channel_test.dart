import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
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
  int handleCounter;

  // Keep created channel instances associated with its handle.
  final channels = <int, AblyMessage>{};

  var publishedMessages = <AblyMessage>[];

  setUp(() {
    channels.clear();
    publishedMessages.clear();
    handleCounter = 0;
    var isAuthenticated = false;

    methodChannel.setMockMethodCallHandler((methodCall) async {

      switch (methodCall.method) {
        case PlatformMethod.registerAbly:
          return true;

        case PlatformMethod.createRealtimeWithOptions:
          final handle = ++handleCounter;
          channels[handle] = methodCall.arguments as AblyMessage;
          return handle;

        case PlatformMethod.publishRealtimeChannelMessage:
          final message = methodCall.arguments as AblyMessage;
          final handle = (message.message as AblyMessage).handle;
          final ablyChannel = channels[handle];
          final clientOptions = ablyChannel.message as ClientOptions;

          // `authUrl` is used to indicate the presence of an authCallback,
          // because function references (in `authCallback`) get dropped by the
          // PlatformChannel.
          if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
            await AblyMethodCallHandler(methodChannel).onRealtimeAuthCallback(
              AblyMessage(TokenParams(timestamp: DateTime.now()),
                handle: handle));
            isAuthenticated = true;
            throw PlatformException(
              code: ErrorCodes.authCallbackFailure.toString());
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

  test('publish realtime message without authCallback', () async {
    // setup
    final realtime = Realtime(key: 'TEST-KEY');
    final channel = realtime.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data1');
    await channel.publish(message: Message(name: 'name', data: 'data'));
    await channel.publish(messages: [Message(name: 'name', data: 'data')]);

    // verification
    expect(publishedMessages.length, 3);
    final firstMessage = publishedMessages.first.message as AblyMessage;
    final messageData = firstMessage.message as Map<dynamic, dynamic>;
    print('messageData $messageData');
    expect(messageData['channel'], 'test');
    expect(messageData['name'], 'name');
    expect(messageData['data'], 'data1');
  });

  test('publish message with authCallback', () async {
    // setup
    final authCallback = expectAsync1((token) async {}, max: 2);

    final options = ClientOptions()
      ..authCallback = authCallback
      ..authUrl = 'hasAuthCallback';
    final realtime = Realtime(options: options, key: 'TEST-KEY');

    final channel = realtime.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data2');

    // verification

    expect(publishedMessages.length, 1);
    final firstMessage = publishedMessages.first.message as AblyMessage;
    final messageData = firstMessage.message as Map<dynamic, dynamic>;
    expect(messageData['channel'], 'test');
    expect(messageData['name'], 'name');
    expect(messageData['data'], 'data2');
  });

  test('publish realtime message with authCallback timing out', () async {
    // setup
    final tooMuchDelay =
      Timeouts.retryOperationOnAuthFailure + Duration(seconds: 2);
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
        final realtime = Realtime(options: options, key: 'TEST-KEY');
        final channel = realtime.channels.get('test');

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
        expect(messageData['data'], 'data3-2');
      }),
    );
  });

  test('publish 2 realtime messages with authCallback', () async {
    // setup
    final authCallback = expectAsync1((token) async {});

    final options = ClientOptions()
      ..authCallback = authCallback
      ..authUrl = 'hasAuthCallback';
    final realtime = Realtime(options: options, key: 'TEST-KEY');
    final channel = realtime.channels.get('test');

    // exercise
    await channel.publish(name: 'name', data: 'data4');
    await channel.publish(name: 'name', data: 'data5');

    // verification
    expect(publishedMessages.length, 2);
    final message0 = publishedMessages[0].message as AblyMessage;
    final messageData0 = message0.message as Map<dynamic, dynamic>;
    expect(messageData0['channel'], 'test');
    expect(messageData0['name'], 'name');
    expect(messageData0['data'], 'data4');

    final message1 = publishedMessages[1].message as AblyMessage;
    final messageData1 = message1.message as Map<dynamic, dynamic>;
    expect(messageData1['channel'], 'test');
    expect(messageData1['name'], 'name');
    expect(messageData1['data'], 'data5');

    // });
  }, timeout: Timeout.none);
}
