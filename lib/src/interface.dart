import 'ably_implementation.dart';
import 'spec/spec.dart' show Realtime, ClientOptions, Rest;

abstract class Ably {
  factory Ably() => AblyImplementation();

  Future<String> get platformVersion;
  Future<String> get version;
  Future<Realtime> createRealtime(final ClientOptions options);
  Future<Rest> createRest(final ClientOptions options);
}
