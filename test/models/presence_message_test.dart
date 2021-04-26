import 'package:ably_flutter/ably_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('PresenceMessage', () {
    const messageId = 'message-id';
    const action = PresenceAction.present;
    const clientId = 'client-id';
    const connectionId = 'connection-id';
    const data = {
      'a': 'b',
      'c': [1, 2, 3]
    };
    const encoding = 'msgpack';
    const extras = {
      'a': 'b',
      'c': [1, 2, 3]
    };
    final timestamp = DateTime.now();
    group('Behaves like a model', () {
      final presenceMessage = PresenceMessage(
        id: messageId,
        action: action,
        clientId: clientId,
        connectionId: connectionId,
        data: data,
        encoding: encoding,
        extras: extras,
        timestamp: timestamp,
      );
      test('Retrieves id', () {
        expect(presenceMessage.id, messageId);
      });
      test('Retrieves action', () {
        expect(presenceMessage.action, action);
      });
      test('Retrieves clientId', () {
        expect(presenceMessage.clientId, clientId);
      });
      test('Retrieves connectionId', () {
        expect(presenceMessage.connectionId, connectionId);
      });
      test('Retrieves data', () {
        expect(presenceMessage.data, data);
      });
      test('Retrieves encoding', () {
        expect(presenceMessage.encoding, encoding);
      });
      test('Retrieves extras', () {
        expect(presenceMessage.extras, extras);
      });
      test('Retrieves timestamp', () {
        expect(presenceMessage.timestamp, timestamp);
      });

      test('#== is true and hashes match when attributes are same', () {
        final presenceMessage2 = PresenceMessage(
          id: messageId,
          action: action,
          clientId: clientId,
          connectionId: connectionId,
          data: data,
          encoding: encoding,
          extras: extras,
          timestamp: timestamp,
        );
        expect(presenceMessage == presenceMessage2, true);
        expect(presenceMessage.hashCode == presenceMessage2.hashCode, true);
      });

      test("#== is false and hashes don't match when attributes are not same",
          () {
        final presenceMessage2 = PresenceMessage(
          id: '123',
          action: action,
          clientId: clientId,
          connectionId: connectionId,
          data: data,
          encoding: encoding,
          extras: extras,
          timestamp: timestamp,
        );
        expect(presenceMessage == presenceMessage2, false);
        expect(presenceMessage.hashCode == presenceMessage2.hashCode, false);
      });

      test("#== is false and hashes don't match for different classes", () {
        final object = Object();
        expect(presenceMessage == object, false);
        expect(presenceMessage.hashCode == object.hashCode, false);
      });
    });

    group('memberKey attribute', () {
      test('is connectionId:clientId', () {
        final presenceMessage =
            PresenceMessage(clientId: clientId, connectionId: connectionId);
        expect(presenceMessage.memberKey, '$connectionId:$clientId');
      });
      test('is unique with the same client id across multiple connections', () {
        final presenceMessage =
            PresenceMessage(clientId: clientId, connectionId: connectionId);
        final presenceMessage2 =
            PresenceMessage(clientId: clientId, connectionId: 'different');
        expect(presenceMessage.memberKey == presenceMessage2.memberKey, false);
      });
      test('is unique with a single connection and different client_ids', () {
        final presenceMessage =
            PresenceMessage(clientId: clientId, connectionId: connectionId);
        final presenceMessage2 =
            PresenceMessage(clientId: 'different', connectionId: connectionId);
        expect(presenceMessage.memberKey == presenceMessage2.memberKey, false);
      });
    });

    group('fromEncoded', () {
      test('returns a presence message object', () {
        final presenceMessage = PresenceMessage.fromEncoded({
          'id': messageId,
          'action': 'present',
          'clientId': clientId,
          'connectionId': connectionId,
          'data': data,
          'encoding': encoding,
          'extras': extras,
          'timestamp': timestamp.millisecondsSinceEpoch
        });
        expect(presenceMessage.id, messageId);
        expect(presenceMessage.action, action);
        expect(presenceMessage.clientId, clientId);
        expect(presenceMessage.connectionId, connectionId);
        expect(presenceMessage.data, data);
        expect(presenceMessage.encoding, encoding);
        expect(presenceMessage.extras, extras);
        expect(
          presenceMessage.timestamp,
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
        );
      });
    });

    group('fromEncodedArray', () {
      test('returns a list of presence message objects', () {
        final presenceMessages = PresenceMessage.fromEncodedArray([
          {
            'id': messageId,
            'action': 'present',
            'clientId': clientId,
            'connectionId': connectionId,
            'data': data,
            'encoding': encoding,
            'extras': extras,
            'timestamp': timestamp.millisecondsSinceEpoch,
          }
        ]);
        final presenceMessage = presenceMessages[0];
        expect(presenceMessage.id, messageId);
        expect(presenceMessage.action, action);
        expect(presenceMessage.clientId, clientId);
        expect(presenceMessage.connectionId, connectionId);
        expect(presenceMessage.data, data);
        expect(presenceMessage.encoding, encoding);
        expect(presenceMessage.extras, extras);
        expect(
          presenceMessage.timestamp,
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
        );
      });
    });
  });
}
