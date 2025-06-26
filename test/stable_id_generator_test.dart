import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StableIdGenerator', () {
    test('generated IDs are unique', () {
      final ids = <int>{};

      // Generate 1000 IDs and check that they are all unique
      for (var i = 0; i < 1000; i++) {
        final id = StableIdGenerator.generate();
        expect(ids.contains(id), isFalse);
        ids.add(id);
      }
    });
  });
}
