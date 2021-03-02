// ignore_for_file: avoid_catching_errors
import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/data.dart';
import '../test_dispatcher.dart';

final logMessages = <List<String>>[];

ClientOptions getClientOptions(
  String appKey, [
  String clientId = 'someClientId',
]) =>
    ClientOptions.fromKey(appKey)
      ..environment = 'sandbox'
      ..clientId = clientId
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]);

Future<Map<String, dynamic>> testRealtimePresenceEnterUpdateLeave({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  dispatcher.reportLog('init start');
  final appKey = (await provision('sandbox-')).toString();

  final clientIds = [null, 'client-1', 'client-2'];
  final clientIDClashMatrix = <Map<String, dynamic>>[];
  for (final clientId in clientIds) {
    final presence = Realtime(options: getClientOptions(appKey, clientId))
        .channels
        .get('test')
        .presence;
    for (final clientId2 in clientIds) {
      final result = <String, dynamic>{
        'realtimeClientId': clientId,
        'presenceClientId': clientId2,
      };

      try {
        await presence.enter();
        result['enter'] = true;
      } on AssertionError {
        result['enter'] = false;
      } on Exception {
        result['enter'] = false;
      }

      try {
        await presence.enterClient(clientId2);
        result['enterClient'] = true;
      } on AssertionError {
        result['enterClient'] = false;
      } on Exception {
        result['enterClient'] = false;
      }

      try {
        await presence.update();
        result['update'] = true;
      } on AssertionError {
        result['update'] = false;
      } on Exception {
        result['update'] = false;
      }

      try {
        await presence.updateClient(clientId2);
        result['updateClient'] = true;
      } on AssertionError {
        result['updateClient'] = false;
      } on Exception {
        result['updateClient'] = false;
      }

      try {
        await presence.leave();
        result['leave'] = true;
      } on AssertionError {
        result['leave'] = false;
      } on Exception {
        result['leave'] = false;
      }

      try {
        await presence.leaveClient(clientId2);
        result['leaveClient'] = true;
      } on AssertionError {
        result['leaveClient'] = false;
      } on Exception {
        result['leaveClient'] = false;
      }
      clientIDClashMatrix.add(result);
    }
  }

  final actionMatrix = <Map<String, dynamic>>[];
  final realtimePresence =
      Realtime(options: getClientOptions(appKey, 'test-client'))
          .channels
          .get('test')
          .presence;
  for (final message in messagesToPublish) {
    final action = <String, dynamic>{'data': message};
    try {
      await realtimePresence.enter(message);
      action['enter'] = true;
    } on Exception {
      action['enter'] = false;
    }
    try {
      await realtimePresence.enterClient('test-client', message);
      action['enterClient'] = true;
    } on Exception {
      action['enterClient'] = false;
    }
    try {
      await realtimePresence.update(message);
      action['update'] = true;
    } on Exception {
      action['update'] = false;
    }
    try {
      await realtimePresence.updateClient('test-client', message);
      action['updateClient'] = true;
    } on Exception {
      action['updateClient'] = false;
    }
    try {
      await realtimePresence.leave(message);
      action['leave'] = true;
    } on Exception {
      action['leave'] = false;
    }
    try {
      await realtimePresence.leaveClient('test-client', message);
      action['leaveClient'] = true;
    } on Exception {
      action['leaveClient'] = false;
    }
    actionMatrix.add(action);
  }

  return {
    'clientIDClashMatrix': clientIDClashMatrix,
    'actionMatrix': actionMatrix,
    'log': logMessages,
  };
}
