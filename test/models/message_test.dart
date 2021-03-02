import 'package:ably_flutter/ably_flutter.dart';
import 'package:test/test.dart';

void main() {
  const messageId = 'message-id';
  const name = 'message-name';
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

  group('Message', () {
    group('Behaves like a model', () {
      final message = Message(
        id: messageId,
        name: name,
        clientId: clientId,
        connectionId: connectionId,
        data: data,
        encoding: encoding,
        extras: extras,
        timestamp: timestamp,
      );

      test('#id retrieves id', () {
        expect(message.id, messageId);
      });

      test('#name retrieves name', () {
        expect(message.name, name);
      });

      test('#clientId retrieves clientId', () {
        expect(message.clientId, clientId);
      });

      test('#connectionId retrieves connectionId', () {
        expect(message.connectionId, connectionId);
      });

      test('#data retrieves data', () {
        expect(message.data, data);
      });

      test('#encoding retrieves encoding', () {
        expect(message.encoding, encoding);
      });

      test('#extras retrieves extras', () {
        expect(message.extras, extras);
      });

      test('#timestamp retrieves timestamp', () {
        expect(message.timestamp, timestamp);
      });

      test('#== is true and hashes match when attributes are same', () {
        final message2 = Message(
          id: messageId,
          name: name,
          clientId: clientId,
          connectionId: connectionId,
          data: data,
          encoding: encoding,
          extras: extras,
          timestamp: timestamp,
        );
        expect(message == message2, true);
        expect(message.hashCode == message2.hashCode, true);
      });

      test("#== is false and hashes don't match when attributes are not same",
          () {
        final message2 = Message(
          id: messageId,
          name: 'other-name',
          clientId: clientId,
          connectionId: connectionId,
          data: data,
          encoding: encoding,
          extras: extras,
          timestamp: timestamp,
        );
        expect(message == message2, false);
        expect(message.hashCode == message2.hashCode, false);
      });

      test("#== is false and hashes don't match for different classes", () {
        final object = Object();
        expect(message == object, false);
        expect(message.hashCode == object.hashCode, false);
      });

      group('fromEncoded', () {
        test('returns a presence message object', () {
          final message = Message.fromEncoded({
            'id': messageId,
            'name': name,
            'clientId': clientId,
            'connectionId': connectionId,
            'data': data,
            'encoding': encoding,
            'extras': extras,
            'timestamp': timestamp.millisecondsSinceEpoch,
          });
          expect(message.id, messageId);
          expect(message.name, name);
          expect(message.clientId, clientId);
          expect(message.connectionId, connectionId);
          expect(message.data, data);
          expect(message.encoding, encoding);
          expect(message.extras, extras);
          expect(
            message.timestamp,
            DateTime.fromMillisecondsSinceEpoch(
              timestamp.millisecondsSinceEpoch,
            ),
          );
        });
      });

      group('fromEncodedArray', () {
        test('returns a list of presence message objects', () {
          final messages = Message.fromEncodedArray([
            {
              'id': messageId,
              'name': name,
              'clientId': clientId,
              'connectionId': connectionId,
              'data': data,
              'encoding': encoding,
              'extras': extras,
              'timestamp': timestamp.millisecondsSinceEpoch,
            }
          ]);
          final message = messages[0];
          expect(message.id, messageId);
          expect(message.name, name);
          expect(message.clientId, clientId);
          expect(message.connectionId, connectionId);
          expect(message.data, data);
          expect(message.encoding, encoding);
          expect(message.extras, extras);
          expect(
            message.timestamp,
            DateTime.fromMillisecondsSinceEpoch(
              timestamp.millisecondsSinceEpoch,
            ),
          );
        });
      });

      group('arguments with ', () {
        test('null name, extras, client_id and encoding are allowed', () {
          final message = Message();
          expect(message.name, null);
          expect(message.encoding, null);
          expect(message.clientId, null);
          expect(message.extras, null);
        });
        test('a map of extras is allowed', () {
          final message = Message(extras: const {'key': 'value'});
          expect(message.extras, const {'key': 'value'});
        });
        test('a list of extras is allowed', () {
          final message = Message(extras: const ['item1', 'item2']);
          expect(message.extras, orderedEquals(const ['item1', 'item2']));
        });
        test('a string for extras is not allowed', () {
          expect(
            () => Message(extras: 'extra'),
            throwsA(isA<AssertionError>()),
          );
        });
        test('an int for extras is not allowed', () {
          expect(
            () => Message(extras: 1),
            throwsA(isA<AssertionError>()),
          );
        });
        test('a bool for extras is not allowed', () {
          expect(
            () => Message(extras: true),
            throwsA(isA<AssertionError>()),
          );
        });
        test('any other Object for extras is not allowed', () {
          expect(
            () => Message(extras: Object()),
            throwsA(isA<AssertionError>()),
          );
        });
      });
    });
  });
}
