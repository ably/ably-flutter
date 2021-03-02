import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodCallManager manager;
  RestPlatformChannels channels;

  setUp(() {
    manager = MockMethodCallManager();
    final rest = Rest(key: 'TEST-KEY');
    channels = rest.channels;
  });

  tearDown(() {
    manager.reset();
  });

  group('rest#channels', () {
    test('creates channel with #get', () {
      final channel = channels.get('channel-1');
      expect(channel.name, 'channel-1');
      expect(channel.options, isNull);
    });

    test('checks if channel exist with #exists', () {
      var hasChannel = channels.exists('channel-2');
      expect(hasChannel, false);

      final channel = channels.get('channel-2');
      expect(channel.name, 'channel-2');

      hasChannel = channels.exists('channel-2');
      expect(hasChannel, true);
    });

    test('creates/returns channel with list accessor #[]', () {
      final channel2 = channels.get('channel-2');
      final chanel2WithSyntacticSugar = channels['channel-2'];
      expect(chanel2WithSyntacticSugar, channel2);

      final channel3 = channels['channel-3'];
      expect(channel3.name, 'channel-3');
    });

    test('iterates over created channels', () {
      channels
        ..get('channel-1')
        ..get('channel-2')
        ..get('channel-3')
        ..get('channel-33');

      expect(
        channels.map((e) => e.name).toList(),
        orderedEquals(const [
          'channel-1',
          'channel-2',
          'channel-3',
          'channel-33',
        ]),
      );

      expect(
        channels.where((e) => e.name.endsWith('3')).map((e) => e.name).toList(),
        orderedEquals(const [
          'channel-3',
          'channel-33',
        ]),
      );
    });

    test('allows querying length', () {
      channels..get('channel-1')..get('channel-2');

      expect(channels.length, 2);

      channels..get('channel-3')..get('channel-33');

      expect(channels.length, 4);
    });
  });

  group('rest#channels#channel', () {
    test('Allows only non-null String input for name', () {
      expect(() => channels.get(null), throwsA(isA<AssertionError>()));
    });
  });
}
