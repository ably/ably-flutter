import 'ably_implementation.dart';
import 'spec/spec.dart' show Realtime, ClientOptions, Rest;

abstract class Ably {
  factory Ably() => AblyImplementation();

  /// Returns platform version
  Future<String> get platformVersion;

  /// Returns ably library version
  Future<String> get version;

  /// Creates a [Realtime] instance with [options]
  Future<Realtime> createRealtime(final ClientOptions options);

  /// Creates a [Rest] instance with [options]
  Future<Rest> createRest(final ClientOptions options);

  /// Creates a [Rest] instance with [key] obtained from ably
  Future<Rest> createRestWithKey(final String key);
}
