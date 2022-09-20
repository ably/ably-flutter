import 'dart:io' as io show Platform;

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Get android/iOS platform version
/// END LEGACY DOCSTRING
Future<String> platformVersion() async => Platform()
    .invokePlatformMethodNonNull<String>(PlatformMethod.getPlatformVersion);

/// BEGIN LEGACY DOCSTRING
/// Get ably library version
/// END LEGACY DOCSTRING
Future<String> version() async =>
    Platform().invokePlatformMethodNonNull<String>(PlatformMethod.getVersion);

/// BEGIN LEGACY DOCSTRING
/// Get version of Dart runtime
/// END LEGACY DOCSTRING
String dartVersion() => readSemverFromPlatformVersion(io.Platform.version);

/// BEGIN LEGACY DOCSTRING
/// Extracts semver value from platform version
/// value is split by space and first element is selected as semver value
/// END LEGACY DOCSTRING
String readSemverFromPlatformVersion(String platformVersion) =>
    platformVersion.split(' ').first;
