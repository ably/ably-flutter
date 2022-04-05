import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
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
      final rest = Rest.fromKey('TEST-KEY');
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

      final options = ClientOptions(
        authCallback: authCallback,
        authUrl: 'hasAuthCallback',
      );
      final rest = Rest(options: options);

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

    test('publishes message with authCallback', () async {
      // setup
      final options = ClientOptions(
        authCallback: (tokenParams) => Future.value('token'),
        authUrl: 'hasAuthCallback',
      );
      final rest = Rest(options: options);
      final channel = rest.channels.get('test');

      // exercise
      final future1 = channel.publish(name: 'name', data: 'data3-1');
      final future2 = channel.publish(name: 'name', data: 'data3-2');

      await Future.wait([future1, future2]);

      expect(manager.publishedMessages.length, 2);
      final future3 = channel.publish(name: 'name', data: 'data3-3');
      await future3;
      expect(manager.publishedMessages.length, 3);

      // setup
      // exercise

      // verification
      await future3;

      final firstMessage = manager.publishedMessages.first;
      final messageData = firstMessage.message as Map<dynamic, dynamic>;
      expect(messageData[TxTransportKeys.channelName], 'test');
      expect(messageData[TxTransportKeys.messages], isA<List>());
      final messages =
          List<Message>.from(messageData[TxTransportKeys.messages] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data3-1');
    });

    test('publishes another message with authCallback', () async {
      // setup
      final authCallback = expectAsync1((token) async => 'token');

      final options = ClientOptions(
        authCallback: authCallback,
        authUrl: 'hasAuthCallback',
      );
      final rest = Rest(options: options);
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
