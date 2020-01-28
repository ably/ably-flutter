# ably_test_flutter_oldskool_plugin_example

Demonstrates how to use the ably_test_flutter_oldskool_plugin plugin.

## Building for iOS

From this folder, use `flutter build ios`, which at the time of writing this produces the following:

    example % flutter build ios
    Building io.ably.flutter.ablyTestFlutterOldskoolPluginExample for device (ios-release)...
    Warning: Missing build name (CFBundleShortVersionString).
    Warning: Missing build number (CFBundleVersion).
    Action Required: You must set a build name and number in the pubspec.yaml file version field before submitting to the App Store.
    
    Signing iOS app for device deployment using developer identity: "Apple Development: quintin@ably.io (6Y5D927PS5)"
    Running pod install...                                              2.1s
    Running Xcode build...                                                  
                                                    
    ├─Building Dart code...                                    31.3s
    ├─Generating dSYM file...                                   0.4s
    ├─Stripping debug symbols...                                0.0s
    ├─Assembling Flutter resources...                           1.9s
    └─Compiling, linking and signing...                        16.9s
    Xcode build done.                                           60.3s
    Built /Users/quintin/code/experiments/flutter/ably_test_flutter_oldskool_plugin/example/build/ios/iphoneos/Runner.app.

## Building for Android

From this folder, use `flutter build apk`, which at the time of writing this produces the following:

    example % flutter build apk
    You are building a fat APK that includes binaries for android-arm, android-arm64, android-x64.
    If you are deploying the app to the Play Store, it's recommended to use app bundles or split the APK to reduce the APK size.
        To generate an app bundle, run:
            flutter build appbundle --target-platform android-arm,android-arm64,android-x64
            Learn more on: https://developer.android.com/guide/app-bundle
        To split the APKs per ABI, run:
            flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
            Learn more on:  https://developer.android.com/studio/build/configure-apk-splits#configure-abi-split
    Calling mockable JAR artifact transform to create file: /Users/quintin/.gradle/caches/transforms-2/files-2.1/583e0b0ef5011f70695e53e4fbaa39d5/android.jar with input /Users/quintin/Library/Android/sdk/platforms/android-28/android.jar
    Running Gradle task 'assembleRelease'...                                
    Running Gradle task 'assembleRelease'... Done                      83.1s
    ✓ Built build/app/outputs/apk/release/app-release.apk (15.1MB).

## Running

Before you can run the example application from this folder, you need to launch an emulator.
Otherwise, `flutter run` will grumble with:

    No supported devices connected.

Find out what emulators you have available with:

    flutter emulators

Which will give you an output looking something like this:

    2 available emulators:
    
    Nexus_5X_API_29_x86 • Nexus 5X API 29 x86 • Google • android
    apple_ios_simulator • iOS Simulator       • Apple  • ios

At which point you can launch an emulator using the ID specified - e.g. iOS:

    flutter emulator --launch apple_ios_simulator

or Android:

    flutter emulator --launch Nexus_5X_API_29_x86

Now, you can run the app with:

    flutter run

To see log output from the running app then, from a new console window, use:

    flutter logs

## Flutter Resources

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Flutter Docs](https://flutter.dev/docs), for tutorials,
samples, guidance on mobile development, and a full API reference.

## Troubleshooting

### Android Emulator

If your emulator was left running when you put your machine to sleep connected to one network interface (e.g. wired ethernet over USB) and then you wake it up and then connect to a different network interface (e.g. Wi-Fi) later, then you may see errors like this when you try to use the example:

> Error provisioning Ably: SocketException: Failed host lookup: 'sandbox-rest.ably.io' (OS Error: No address associated with hostname, errno = 7)

The solution appears to be to quit the emulator and then restart it.
