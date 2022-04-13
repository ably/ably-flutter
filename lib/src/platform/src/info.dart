import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Get android/iOS platform version
Future<String> platformVersion() async => Platform()
    .invokePlatformMethodNonNull<String>(PlatformMethod.getPlatformVersion);

/// Get ably library version
Future<String> version() async =>
    Platform().invokePlatformMethodNonNull<String>(PlatformMethod.getVersion);

/// Get version of Dart runtime
String dartVersion() => readSemverFromPlatformVersion(io.Platform.version);

/// Extracts semver value from platform version
/// value is split by space and first element is selected as semver value
String readSemverFromPlatformVersion(String platformVersion) =>
    platformVersion.split(' ').first;
