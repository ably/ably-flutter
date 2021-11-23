# Ably Flutter Plugin Example

Demonstrates how to use the Ably Flutter plugin.

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

To see log output from the running app then, from a new console window, you may need to use:

    flutter logs

To see all Android output from the running app then you will need to use `adb logcat`, which is a
lot less noisy if you supply it with the id of the Flutter process. So, for example, were you to
observe this in the output from `flutter run`:

    I/flutter (13997): initPlatformState()

then you can view Android output for just that process in another terminal session with:

    adb logcat --pid=13997

As an example, when I was debugging Android, I was seeing the following unhelpful message in the terminal
where I had launched with `flutter run`:

    I/flutter (15216): createRealtime with registered handle 2
    I/flutter (15216): Error creating Ably Realtime: MissingPluginException(No implementation found for method createRealtime on channel ably_test_flutter_oldskool_plugin)
    I/flutter (15216): widget build

What was confusing was that I had definitely implemented a handler for this method and was sure that
it could not be my Java code that was calling `result.notImplemented()`. It was only after I used
`adb logcat --pid=15216` that I could see the real cause:

    02-05 10:13:42.984 15216 15254 I flutter : createRealtime with registered handle 2
    02-05 10:13:42.992 15216 15216 E DartMessenger: Uncaught exception in binary message listener
    02-05 10:13:42.992 15216 15216 E DartMessenger: java.lang.IllegalArgumentException: Message corrupted
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.plugin.common.StandardMessageCodec.readValueOfType(StandardMessageCodec.java:433)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.ably.flutter.ably_test_flutter_oldskool_plugin.AblyMessageCodec.readValueOfType(AblyMessageCodec.java:21)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.plugin.common.StandardMessageCodec.readValue(StandardMessageCodec.java:343)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.plugin.common.StandardMethodCodec.decodeMethodCall(StandardMethodCodec.java:46)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.plugin.common.MethodChannel$IncomingMethodCallHandler.onMessage(MethodChannel.java:229)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.embedding.engine.dart.DartMessenger.handleMessageFromDart(DartMessenger.java:93)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at io.flutter.embedding.engine.FlutterJNI.handlePlatformMessage(FlutterJNI.java:642)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at android.os.MessageQueue.nativePollOnce(Native Method)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at android.os.MessageQueue.next(MessageQueue.java:336)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at android.os.Looper.loop(Looper.java:174)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at android.app.ActivityThread.main(ActivityThread.java:7356)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at java.lang.reflect.Method.invoke(Native Method)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:492)
    02-05 10:13:42.992 15216 15216 E DartMessenger: 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:930)
    02-05 10:13:43.006 15216 15254 I flutter : Error creating Ably Realtime: MissingPluginException(No implementation found for method createRealtime on channel ably_test_flutter_oldskool_plugin)
    02-05 10:13:43.011 15216 15254 I flutter : widget build

The message codec gets invoked before my method call handler ever gets called. And it seems that the Flutter
Engine comes back to the Dart side with 'not implemented' when there has, in fact, been a codec error.
In this case the message is not technically corrupted, it was just that I had not implemented in Java the new
value type that I had added on the Dart side.

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
