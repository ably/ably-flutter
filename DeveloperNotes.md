# Developer Notes

## Implementation Notes

### Interfaces

The `Realtime` 'interface' is an [abstract class](https://dart.dev/guides/language/language-tour#abstract-classes)
which seems to be the correct way to do this in Dart - every class has an
['implicit interface'](https://dart.dev/guides/language/language-tour#implicit-interfaces) and then you make the
class abstract to present it as a more traditional interface as understood by the perhaps a Java programmer.

### Exceptions and Errors

Dart libraries don't _extend_ the [Exception class](https://api.dart.dev/stable/2.4.0/dart-core/Exception-class.html),
they _implement_ its implicit interface.
(see [this comment](https://stackoverflow.com/questions/13579982/custom-exceptions-in-dart#comment18616624_13580222)).

For the moment it would not seem appropriate for our plugin to throw instances conforming to the implicit interface
of the [Error class](https://api.dart.dev/stable/2.4.0/dart-core/Error-class.html), as this is perhaps more
appropriate for programmer's failures on the Dart side of things. But time will tell.

## Platform Notes

### Android

The Android project does use [AndroidX](https://developer.android.com/jetpack/androidx), which appears to be the default specified when Flutter created the plugin project, however Flutter's Java API for plugins (e.g. [MethodChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.html)) appears to still use deprecated platform APIs like the [UiThread](https://developer.android.com/reference/android/support/annotation/UiThread) annotation.

### iOS

Once changes have been made to the platform code in the [ios folder](ios), especially if those changes involve changing
[the pod spec](ios/ably_flutter_plugin.podspec) to add a dependency, then it may be necessary to force that build up stream with:

1. Bump `s.version` in the pod spec
2. From [example/ios](example/ios) run `pod install`
3. Open [Runner.xcworkspace](example/ios/Runner.xcworkspace) in Xcode, clean and build

Otherwise, after making simple code changes to the platform code it will not get seen with a hot restart "R".
Therefore if there's a current emulation running then use "q" to quit it and then re-run the emulator - e.g. with this if you've
got both iOS and Android emulators open:

    flutter run -d all

## Helpful Resources

- Flutter
[plug-in package development](https://flutter.dev/developing-packages/),
being a specialized package that includes platform-specific implementation code for Android and/or iOS.
- Flutter
[documentation](https://flutter.dev/docs), offering tutorials, 
samples, guidance on mobile development, and a full API reference.


## Generating platform constants

Some files in the project are generated to maintain sync between
 platform constants on both native and dart side.
  Generated file paths are configured as values in `bin/codegen.dart` for `toGenerate` Map

[Read about generation of platform specific constant files](bin/README.md)

## Implementing new codec types

1. Add new type along with value in `_types` list at [bin/codegencontext.dart](bin/codegencontext.dart)
2. Add an object definition  with object name and its properties to `objects` list at [bin/codegencontext.dart](bin/codegencontext.dart)
 This will create `Tx<ObjectName>` under which all properties are accessible.
 
Generate platform constants and continue

3. update `getCodecType` in [lib.src.codec.Codec](lib/src/codec.dart) so new codec type is returned based on runtime type
4. update `codecPair` in [lib.src.codec.Codec](lib/src/codec.dart)  so new encoder/decoder is assigned for new type
5. update `writeValue` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new codec type is obtained from runtime type
6. update `codecMap` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new encoder/decoder is assigned for new type
7. add new codec encoder method in [ios.Classes.codec.AblyFlutterWriter](ios/Classes/codec/AblyFlutterWriter.m)
 and update `getType` and `getEncoder` so that new codec encoder is called
8. add new codec encoder method in [ios.classes.codec.AblyFlutterReader](ios/Classes/codec/AblyFlutterReader.m)
 and update `getDecoder` so that new codec decoder is called

## Implementing new platform methods

1. Add new method name in `_platformMethods` list at [bin/codegencontext.dart](bin/codegencontext.dart)

Generate platform constants and use wherever required

## Static plugin code analyzer

The new flutter analyzer does a great job at analyzing complete flutter package.

Running `flutter analyze` in project root will analyze dart files in complete project,
 i.e., plugin code and example code


Or, use the good old dart analyzer

```bash
dartanalyzer --fatal-warnings lib/**/*.dart

dartanalyzer --fatal-warnings example/lib/**/*.dart
```
