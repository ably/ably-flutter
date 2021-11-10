import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_method_call_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodCallManager manager;

  setUp(() {
    manager = MockMethodCallManager();
  });

  tearDown(() {
    manager.reset();
  });

  group('rest#channels#channel', () {
    test('publishes message without authCallback', () async {
      // setup
      final rest = Rest(key: 'TEST-KEY');
      final channel = rest.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data1');

      // verification
      expect(manager.publishedMessages.length, 1);
      final firstMessage = manager.publishedMessages.first;
      final messageData = firstMessage.message as Map<dynamic, dynamic>;
      expect(messageData[TxTransportKeys.channelName], 'test');
      expect(messageData[TxTransportKeys.messages], isA<List>());
      final messages =
          List<Message>.from(messageData[TxTransportKeys.messages] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data1');
    });

    test('publishes message with authCallback', () async {
      // setup
      final authCallback = expectAsync1((token) async => 'token', max: 2);

      final options = ClientOptions()
        ..authCallback = authCallback
        ..authUrl = 'hasAuthCallback';
      final rest = Rest(options: options, key: 'TEST-KEY');

      final channel = rest.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data2');

      // verification
      expect(manager.publishedMessages.length, 1);
      final firstMessage = manager.publishedMessages.first;
      final messageData = firstMessage.message as Map<dynamic, dynamic>;
      expect(messageData[TxTransportKeys.channelName], 'test');
      expect(messageData[TxTransportKeys.messages], isA<List>());
      final messages =
          List<Message>.from(messageData[TxTransportKeys.messages] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data2');
    });

    test('publishes message with authCallback timing out', () async {
      // setup
      final tooMuchDelay =
          Timeouts.retryOperationOnAuthFailure + const Duration(seconds: 2);
      var authCallbackCounter = 0;

      Future<Object> timingOutOnceThenSucceedsAuthCallback(TokenParams token) {
        if (authCallbackCounter == 0) {
          authCallbackCounter++;
          throw TimeoutException('Timed out');
        }
        return Future.value('token');
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

          expect(manager.publishedMessages.length, 0);

          // Send another message after timeout with authCallback succeeding

          // setup
          // exercise
          final future3 = channel.publish(name: 'name', data: 'data3-3');

          // verification
          async.elapse(Duration.zero);
          await future3;

          expect(manager.publishedMessages.length, 1);

          final firstMessage =
              manager.publishedMessages.first.message as AblyMessage;
          final messageData = firstMessage.message as Map<dynamic, dynamic>;
          expect(messageData[TxTransportKeys.channelName], 'test');
          expect(messageData[TxTransportKeys.messages], isA<List>());
          final messages =
              List<Message>.from(messageData[TxTransportKeys.messages] as List);
          expect(messages[0].name, 'name');
          expect(messages[0].data, 'data3-2');
        }),
      );
    });

    test('publishes another message with authCallback', () async {
      // setup
      final authCallback = expectAsync1((token) async => 'token');

      final options = ClientOptions()
        ..authCallback = authCallback
        ..authUrl = 'hasAuthCallback';
      final rest = Rest(options: options, key: 'TEST-KEY');
      final channel = rest.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data4');
      await channel.publish(name: 'name', data: 'data5');

      // verification
      expect(manager.publishedMessages.length, 2);
      final message0 = manager.publishedMessages[0];
      final messageData0 = message0.message as Map<dynamic, dynamic>;
      expect(messageData0[TxTransportKeys.channelName], 'test');
      expect(messageData0[TxTransportKeys.messages], isA<List>());
      final messages =
          List<Message>.from(messageData0[TxTransportKeys.messages] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data4');

      final message1 = manager.publishedMessages[1];
      final messageData1 = message1.message as Map<dynamic, dynamic>;
      expect(messageData1[TxTransportKeys.channelName], 'test');
      expect(messageData1[TxTransportKeys.messages], isA<List>());
      final messages2 =
          List<Message>.from(messageData1[TxTransportKeys.messages] as List);
      expect(messages2[0].name, 'name');
      expect(messages2[0].data, 'data5');
    }, timeout: Timeout.none);
  });
}
