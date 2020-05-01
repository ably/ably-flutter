import 'ably_implementation.dart';
import 'spec/spec.dart' show Realtime, ClientOptions, Rest;

abstract class Ably {
  factory Ably() => AblyImplementation();

  /// Returns platform version
  Future<String> get platformVersion;

  /// Returns ably library version
  Future<String> get version;

  /// Creates a [Realtime] instance either with [options] or with [key]
  /// obtained from Ably dashboard
  Future<Realtime> createRealtime({
    ClientOptions options,
    final String key
  });

  /// Creates a [Rest] instance either with [options] or with [key]
  /// obtained from Ably dashboard
  Future<Rest> createRest({
    ClientOptions options,
    final String key
  });

  CancelListening startListening(Listener listener);
}
