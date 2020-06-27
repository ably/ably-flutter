import 'ably_implementation.dart';
import 'spec/spec.dart' as spec;

abstract class AblyLibrary {

  static final AblyLibrary _instance = AblyImplementation();
  factory AblyLibrary() => _instance;

  /// Invokes a platform method
  Future<T> invoke<T>(String method, [dynamic arguments]);

  /// Returns platform version
  Future<String> get platformVersion;

  /// Returns ably library version
  Future<String> get version;

  /// Creates a [Realtime] instance either with [options] or with [key]
  /// obtained from Ably dashboard
  spec.Realtime Realtime({
    spec.ClientOptions options,
    final String key
  });

  /// Creates a [Rest] instance either with [options] or with [key]
  /// obtained from Ably dashboard
  spec.Rest Rest({
    spec.ClientOptions options,
    final String key
  });

}

final AblyLibrary Ably = AblyLibrary();
