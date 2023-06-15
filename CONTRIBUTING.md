# Contributing to Ably Flutter

## Development Flow

The code in this repository has been constructed to be
[built as a Flutter Plugin](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin). In this repository the main branch contains the latest development version of the Ably SDK. All development (bug fixing, feature implementation, etc.) is done against the main branch, which you should branch from whenever you'd like to make modifications. Here's the steps to follow when contributing to this repository.

- Fork it
- Install and update dependencies (`flutter pub get`)
- Create your feature branch from `main`
- Run static analysis on your changes and make sure there are no issues (`flutter analyze`)
- Commit your changes
- Ensure you have added suitable tests and the test suite is passing
- Push to the branch
- Create a new Pull Request

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

### Generating platform constants

Some files in the project are generated to maintain sync between platform constants on both native and dart side. Generated file paths are configured as values in `bin/codegen.dart`. To generate Obj-C and Java classes for components shared between Flutter SDK and platform SDKs, open [bin](bin) directory and execute [codegen.dart](bin/codegen.dart):

```bash
cd bin
dart codegen.dart
```

[Read more about generation of platform specific constant files](bin/README.md)

### Implementing new codec types

1. Add new type along with value in `_types` list at [bin/codegen_context.dart](bin/codegen_context.dart)
2. Add an object definition  with object name and its properties to `objects` list at [bin/codegen_context.dart](bin/codegen_context.dart)
 This will create `Tx<ObjectName>` under which all properties are accessible.
3. Generate platform constants
4. Update `getCodecType` in [Codec.dart](lib/src/platform/src/codec.dart) so new codec type is returned based on runtime type
5. Update `codecPair` in [Codec.dart](lib/src/platform/src/codec.dart)  so new encoder/decoder is assigned for new type
6. Update `writeValue` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new codec type is obtained from runtime type
7. Update `codecMap` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new encoder/decoder is assigned for new type
8. Add new codec encoder method in [ios.Classes.codec.AblyFlutterWriter](ios/Classes/codec/AblyFlutterWriter.m)
 and update `getType` and `getEncoder` so that new codec encoder is called
9. Add new codec encoder method in [ios.classes.codec.AblyFlutterReader](ios/Classes/codec/AblyFlutterReader.m)
 and update `getDecoder` so that new codec decoder is called

### Implementing new platform methods

1. Add new method name in `_platformMethods` list at [bin/codegen_context.dart](bin/codegen_context.dart)
2. Generate platform constants
3. Add new method in [android.src.main.java.io.ably.flutter.plugin.AblyMethodCallHandler.java](android/src/main/java/io/ably/flutter/plugin/AblyMethodCallHandler.java)
 and update `_map` so that new method name is assigned to a method call
4. Add new method in [ios.classes.AblyFlutter](ios/Classes/AblyFlutter.m)
 and update `initWithChannel` so that new method name is assigned to a method call

## Running Tests

### Unit tests

Unit tests are located in [test](test/) directory and built on top of `flutter_test` package. The complete test suite can be executed with this command:

```bash
flutter test
```

### Integration tests

Integration tests are located in [test_integration](test_integration/) directory and use `flutter_test` and `flutter_driver` packages. Integration tests have to be executed on virtual machine or real device, and a dedicated test app is provided to track the test progress. To run the test app and all tests, execute:

```bash
cd test_integration
flutter drive --target lib/main.dart
```

## Building Platform-Specific Documentation

### Generating package documentation

`Ably-flutter` uses [dartdoc](https://pub.dev/packages/dartdoc) to generate package documentation. To build the docset, execute:

```bash
dart doc
```

in the root directory of `ably-flutter`. The docs are also generated in [docs](.github/workflows/docs.yml) GitHub Workflow.

### Markdown files structure

Documentation stored in repository should follow the schema defined in [Ably Templates](https://github.com/ably/ably-common/tree/main/templates). As features are developed, ensure documentation (both in the public API interface) and in relevant markdown files are updated.

### Including images in markdown files

When referencing images in markdown files, using a local path such as `images/android.png`, for example `![An android device running on API level 30](images/android.png)` will result in the image missing on pub.dev README preview. Therefore, we currently reference images through the github.com URL path (`https://github.com/ably/ably-flutter/raw/`), for example to reference `images/android.png`, we would use `![An android device running on API level 30](https://github.com/ably/ably-flutter/raw/main/images/android.png)`. [A suggestion](https://github.com/dart-lang/pub-dev/issues/5068) has been made to automatically replace this relative image path to the github URL path.

## Release Process

Releases should always be made through a release pull request (PR), which needs to bump the version number and add to the [change log](CHANGELOG.md).
For an example of a previous release PR, see [#89](https://github.com/ably/ably-flutter/pull/89).

The release process must include the following steps:

1. Ensure that all work intended for this release has landed to `main`
2. Create a release branch named like `release/1.2.3`
3. Add a commit to bump the version number
   - Update the version in `pubspec.yaml`
   - Update the version in the 'Installation' section of `README.md`
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
