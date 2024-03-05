// ignore_for_file: avoid_catching_errors
import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';

final logMessages = <List<String?>>[];

ClientOptions getClientOptions(
  String appKey, [
  String? clientId = 'someClientId',
]) =>
    ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: clientId,
      logLevel: LogLevel.error,
    );

Future<Map<String, dynamic>> testRealtimePresenceEnterUpdateLeave({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

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

      if (clientId2 == null) {
        result['enterClient'] = false;
      } else {
        try {
          await presence.enterClient(clientId2);
          result['enterClient'] = true;
        } on Exception {
          result['enterClient'] = false;
        }
      }

      try {
        await presence.update();
        result['update'] = true;
      } on AssertionError {
        result['update'] = false;
      } on Exception {
        result['update'] = false;
      }

      if (clientId2 == null) {
        result['updateClient'] = false;
      } else {
        try {
          await presence.updateClient(clientId2);
          result['updateClient'] = true;
        } on Exception {
          result['updateClient'] = false;
        }
      }

      try {
        await presence.leave();
        result['leave'] = true;
      } on AssertionError {
        result['leave'] = false;
      } on Exception {
        result['leave'] = false;
      }

      if (clientId2 == null) {
        result['leaveClient'] = false;
      } else {
        try {
          await presence.leaveClient(clientId2);
          result['leaveClient'] = true;
        } on Exception {
          result['leaveClient'] = false;
        }
      }
      clientIDClashMatrix.add(result);
    }
  }

  // Interact with different types of data.
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
