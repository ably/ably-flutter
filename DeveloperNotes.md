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
[the pod spec](ios/ably_flutter.podspec) to add a dependency, then it may be necessary to force that build up stream with:

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

## dartdoc

### Tool Installation

With just the Flutter tools installed, the following is observed:

```
ably-flutter % which dartdoc
dartdoc not found

?1 ably-flutter % which flutter
/Users/quintinwillison/flutter/bin/flutter
```

The `dartdoc` tool can be activated via the `flutter` command like this:

```
ably-flutter % flutter pub global activate dartdoc
Resolving dependencies...
+ _fe_analyzer_shared 14.0.0 (18.0.0 available)
+ analyzer 0.41.2 (1.2.0 available)
+ args 1.6.0 (2.0.0 available)
+ async 2.4.2 (2.5.0 available)
+ charcode 1.1.3 (1.2.0 available)
+ cli_util 0.2.0 (0.3.0 available)
+ collection 1.14.13 (1.15.0 available)
+ convert 2.1.1 (3.0.0 available)
+ crypto 2.1.5 (3.0.0 available)
+ csslib 0.16.2 (0.17.0 available)
+ dartdoc 0.39.0 (0.40.0 available)
+ file 5.2.1 (6.1.0 available)
+ glob 1.2.0 (2.0.0 available)
+ html 0.14.0+4 (0.15.0 available)
+ intl 0.16.1 (0.17.0 available)
+ js 0.6.2 (0.6.3 available)
+ logging 0.11.4 (1.0.0 available)
+ markdown 3.0.0 (4.0.0 available)
+ meta 1.2.4 (1.3.0 available)
+ mustache 1.1.1
+ node_interop 1.2.1
+ node_io 1.2.0
+ package_config 1.9.3 (2.0.0 available)
+ path 1.7.0 (1.8.0 available)
+ pedantic 1.9.2 (1.11.0 available)
+ pub_semver 1.4.4 (2.0.0 available)
+ source_span 1.7.0 (1.8.1 available)
+ string_scanner 1.0.5 (1.1.0 available)
+ term_glyph 1.1.0 (1.2.0 available)
+ typed_data 1.2.0 (1.3.0 available)
+ watcher 0.9.7+15 (1.0.0 available)
+ yaml 2.2.1 (3.1.0 available)
Downloading dartdoc 0.39.0...
Downloading mustache 1.1.1...
Downloading analyzer 0.41.2...
Downloading _fe_analyzer_shared 14.0.0...
Downloading markdown 3.0.0...
Downloading charcode 1.1.3...
Downloading node_io 1.2.0...
Downloading node_interop 1.2.1...
Downloading js 0.6.2...
Downloading path 1.7.0...
Downloading meta 1.2.4...
Downloading file 5.2.1...
Downloading typed_data 1.2.0...
Downloading string_scanner 1.0.5...
Downloading source_span 1.7.0...
Downloading term_glyph 1.1.0...
Downloading async 2.4.2...
Downloading html 0.14.0+4...
Downloading collection 1.14.13...
Precompiling executables...
Precompiled dartdoc:dartdoc.
Installed executable dartdoc.
Warning: Pub installs executables into $HOME/flutter/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"$HOME/flutter/.pub-cache/bin"

Activated dartdoc 0.39.0.
```

And, indeed, on inspecting my path I could confirm that it wasn't present:

```
ably-flutter % echo $PATH
/Users/quintinwillison/.asdf/shims:/Users/quintinwillison/.asdf/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/MacGPG2/bin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Apple/usr/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin
```

So I edited my configuration to add the `PATH` export suggested:

```
ably-flutter % vi ~/.zshrc
ably-flutter % source ~/.zshrc
ably-flutter % echo $PATH
/Users/quintinwillison/.asdf/shims:/Users/quintinwillison/.asdf/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/MacGPG2/bin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Apple/usr/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin:/Users/quintinwillison/flutter/.pub-cache/bin
```

And I was then able to find the `dartdoc` tool:

```
ably-flutter % which dartdoc
/Users/quintinwillison/flutter/.pub-cache/bin/dartdoc
```

And see that it had been installed globally in the Flutter context:

```
ably-flutter % flutter pub global list
dartdoc 0.39.0
```

### Generating Documentation

```
ably-flutter % dartdoc
Documenting ably_flutter...
Initialized dartdoc with 195 libraries in 180.4 seconds
Generating docs for library ably_flutter from package:ably_flutter/ably_flutter.dart...
Validating docs...
  warning: dartdoc generated a broken link to: DeveloperNotes.md, linked to from package-ably_flutter: file:///Users/quintinwillison/code/ably/ably-flutter
found 1 warning and 0 errors
Documented 1 public library in 5.6 seconds
Success! Docs generated into /Users/quintinwillison/code/ably/ably-flutter/doc/api
```
