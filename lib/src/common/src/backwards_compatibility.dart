/// This function was added to add backwards compatibility.
///
/// `unawaited` was previously imported in code from package:pedantic.
/// However, this package was deprecated, and `unawaited` was added to Flutter
/// directly. Unfortunately, it was only added in Flutter 2.5 (Dart 2.14).
///
/// Users who use the package with Flutter versions older than 2.5 will
/// face missing method errors. Forcing users to upgrade to 2.5 may force them
/// to undergo [breaking changes](https://flutter.dev/docs/release/breaking-changes#released-in-flutter-25).
///
/// Reminder: Once we increase our minimum dart version support to 2.14 and
/// minimum Flutter version support 2.5.0, we can remove this method and replace
/// it with `unawaited`
void unawaitedWorkaroundForDartPre214(Future<void> future) {}
