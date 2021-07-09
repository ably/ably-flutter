import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_method_call_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodCallManager manager;
  late RestChannels channels;

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
      final channel2WithSyntacticSugar = channels['channel-2'];
      expect(channel2WithSyntacticSugar, channel2);

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

    group('#release', () {
      test(
          '(RSN4a) Takes one argument, the channel name,'
          ' and releases the corresponding channel entity', () {
        channels..get('channel-1')..get('channel-2');
        expect(channels.length, 2);
        channels.release('channel-1');
        expect(channels.length, 1);
        expect(channels.exists('channel-1'), false);
      });

      test(
          '(RSN4b) Calling release() with a channel name'
          ' that does not correspond to an extant channel'
          ' entity must return without error', () {
        channels..get('channel-1')..get('channel-2');
        expect(channels.length, 2);
        channels.release('channel-3');
        expect(channels.length, 2);
        expect(channels.exists('channel-1'), true);
        expect(channels.exists('channel-2'), true);
      });
    });
  });
}
