import 'package:flutter/foundation.dart';

import '../common.dart';
import '../connection.dart';
import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'channels.dart';


abstract class Realtime extends AblyBase {

  Realtime({
    ClientOptions options,
    final String key
  }): super(options: options, key: key);

  String clientId;
  void close();
  void connect();
  Connection connection;
  RealtimeChannels channels;

}