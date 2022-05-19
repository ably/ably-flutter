import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter_test/flutter_test.dart';

import '../test_constants.dart';

void main() {
  final semverRegexp = RegExp(TestConstants.semverRegexp);

  group('dartVersion', () {
    // Raw value of runtime version returned from [Platform]
    late String platformVersion;
    // Semver value read from platform version
    late String dartVersion;

    setUpAll(() {
      platformVersion = io.Platform.version;
      dartVersion = ably.dartVersion();
    });

    test('platform version is not empty', () {
      expect(platformVersion, isNotEmpty);
    });

    test('dart version is not empty', () {
      expect(dartVersion, isNotEmpty);
    });

    test('platform version starts with dart version', () {
      expect(platformVersion, startsWith(dartVersion));
    });

    test('dart version is a valid semver string', () {
      final hasMatch = semverRegexp.hasMatch(dartVersion);
      expect(hasMatch, equals(true));
    });
  });

  group('readSemverFromPlatformVersion', () {
    test('returns valid semver from platform version', () {
      const platformVersion =
          '2.16.2 (stable) (Tue Mar 22 13:15:13 2022 +0100) on "macos_x64"';
      final result = ably.readSemverFromPlatformVersion(platformVersion);
      expect(result, equals('2.16.2'));
    });

    test('returns valid semver from semver only string', () {
      const platformVersion = '2.16.2';
      final result = ably.readSemverFromPlatformVersion(platformVersion);
      expect(result, equals('2.16.2'));
    });

    test('returns empty semver from empty string', () {
      const platformVersion = '';
      final result = ably.readSemverFromPlatformVersion(platformVersion);
      expect(result, isEmpty);
    });
  });
}
