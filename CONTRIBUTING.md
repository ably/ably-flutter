# Contributing to Ably Flutter

## Development Flow

### Getting Started

The code in this repository has been constructed to be
[built as a Flutter Plugin](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
It is not yet constructed as a federated plugin but this is in our backlog as
[issue 118](https://github.com/ably/ably-flutter/issues/118).

After checking out this repository, run the following command:

    flutter pub get

You may also find it insightful to run the following command, as it can reveal issues with your development environment:

    flutter doctor


### Code generation

To generate Obj-C and Java classes for components shared between Flutter SDK and platform SDKs, open [bin](bin) directory and execute [codegen.dart](bin/codegen.dart):

```bash
cd bin
dart codegen.dart
```

### Hot restart

When performing `hot restart`, it's required to also reset the platform clients by calling:

```dart
await methodChannel.invokeMethod(PlatformMethod.resetAblyClients);
```

This is not required when `hot reload` or `app restart` is performed.

### Debugging

To debug both platform and Dart code simultaneously:

#### Android

1. Launch the Flutter app on Android Emulator from CLI, Android Studio or VS Code
2. Open `android` directory in Android Studio
3. From Android Studio select "Run" -> "Attach debugger to Android Process" and select the running app

#### iOS

1. Launch the Flutter app on iOS Simulator from CLI, Android Studio or VS Code
2. Open `ios` directory in XCode
3. From XCode select "Debug" -> "Attach to process" and select the running process

After the app is launched, it can be re-launched from XCode/Android Studio with debugger already attached. This may be useful to debug startup issues.

### Testing changes in platform libraries

After making changes to `ably-java` or `ably-cocoa`, you can test changes without releasing those dependencies to users. To do this, you need a local copy of the repo with the changes you want to test.

To test `ably-cocoa` changes, in `Podfile`, below `target 'Runner' do`, add:

```ruby
    pod 'Ably', :path => 'local/path/to/ably-cocoa'
```

To test `ably-java` changes, see [Using ably-java / ably-android locally in other projects](https://github.com/ably/ably-java/blob/main/CONTRIBUTING.md#using-ably-java--ably-android-locally-in-other-projects).

### Writing documentation

As features are developed, ensure documentation (both in the public API interface) and in relevant markdown files are updated. When referencing images in markdown files, using a local path such as `images/android.png`, for example `![An android device running on API level 30](images/android.png)` will result in the image missing on pub.dev README preview. Therefore, we currently reference images through the github.com URL path (`https://github.com/ably/ably-flutter/raw/`), for example to reference `images/android.png`, we would use `![An android device running on API level 30](https://github.com/ably/ably-flutter/raw/main/images/android.png)`. [A suggestion](https://github.com/dart-lang/pub-dev/issues/5068) has been made to automatically replace this relative image path to the github URL path.

### Helpful Resources

- Flutter
[plug-in package development](https://flutter.dev/developing-packages/),
being a specialized package that includes platform-specific implementation code for Android and/or iOS.
- Flutter
[documentation](https://flutter.dev/docs), offering tutorials,
samples, guidance on mobile development, and a full API reference.

### Generating platform constants

Some files in the project are generated to maintain sync between
 platform constants on both native and dart side.
  Generated file paths are configured as values in `bin/codegen.dart` for `toGenerate` Map

[Read about generation of platform specific constant files](bin/README.md)

### Implementing new codec types

1. Add new type along with value in `_types` list at [bin/codegen_context.dart](bin/codegen_context.dart)
2. Add an object definition  with object name and its properties to `objects` list at [bin/codegen_context.dart](bin/codegen_context.dart)
 This will create `Tx<ObjectName>` under which all properties are accessible.

Generate platform constants and continue

3. update `getCodecType` in [Codec.dart](lib/src/platform/src/codec.dart) so new codec type is returned based on runtime type
4. update `codecPair` in [Codec.dart](lib/src/platform/src/codec.dart)  so new encoder/decoder is assigned for new type
5. update `writeValue` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new codec type is obtained from runtime type
6. update `codecMap` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new encoder/decoder is assigned for new type
7. add new codec encoder method in [ios.Classes.codec.AblyFlutterWriter](ios/Classes/codec/AblyFlutterWriter.m)
 and update `getType` and `getEncoder` so that new codec encoder is called
8. add new codec encoder method in [ios.classes.codec.AblyFlutterReader](ios/Classes/codec/AblyFlutterReader.m)
 and update `getDecoder` so that new codec decoder is called

### Implementing new platform methods

1. Add new method name in `_platformMethods` list at [bin/codegen_context.dart](bin/codegen_context.dart)

Generate platform constants and use wherever required

### Static plugin code analyzer

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
Downloading...
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

## Release Process

Releases should always be made through a release pull request (PR), which needs to bump the version number and add to the [change log](CHANGELOG.md).
For an example of a previous release PR, see [#89](https://github.com/ably/ably-flutter/pull/89).

The release process must include the following steps:

1. Ensure that all work intended for this release has landed to `main`
2. Create a release branch named like `release/1.2.3`
3. Add a commit to bump the version number
   - Update the version in `pubspec.yaml`
   - Update the version of ably-flutter used in the example app and test integration app `podfile.lock` files:
   - Run `pod install` in `example/ios` and `test_integration/ios`, or run `pod install --project-directory=example/ios` and `pod install --project-directory=test_integration/ios`
   - Commit this
4. Add a commit to update the change log.
    - Autogenerate the changelog contents by running `github_changelog_generator -u ably -p ably-flutter --since-tag v1.2.2 --output delta.md` and manually copying the relevant contents from `delta.md` into `CHANGELOG.md`
    - Make sure to replace `HEAD` in the autogenerated URL's with the version tag you will create (e.g. `v1.2.3`).
5. Check that everything is looking sensible to the Flutter tools without publishing by running: `flutter pub publish --dry-run`
6. Push the release branch to GitHub
7. Open a PR for the release against the release branch you just pushed
8. Gain approval(s) for the release PR from maintainer(s)
9. Land the release PR to `main`
10. Execute `flutter pub publish` from the root of this repository
11. Create a tag named like `v1.2.3`, using `git tag v1.2.3`
12. Push the newly created tag to GitHub: `git push origin v1.2.3`
13. Create a release on GitHub following the [previous releases]((https://github.com/ably/ably-flutter/releases)) as examples.

We tend to use [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator) to collate the information required for a change log update.
Your mileage may vary, but it seems the most reliable method to invoke the generator is something like:
`github_changelog_generator -u ably -p ably-flutter --since-tag v1.2.0 --output delta.md`
and then manually merge the delta contents in to the main change log (where `v1.2.0` in this case is the tag for the previous release).
