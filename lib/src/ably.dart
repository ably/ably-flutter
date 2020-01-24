import 'package:ably_test_flutter_oldskool_plugin/ably.dart' as api;

/// An object which has a live counterpart in the Platform client library SDK.
abstract class PlatformObject {
}

class Realtime extends PlatformObject implements api.Realtime {
  @override
  // TODO: implement channels
  api.Channels get channels => null;

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void connect() {
    // TODO: implement connect
  }

  @override
  // TODO: implement connection
  api.Connection get connection => null;
}
