import 'package:ably_flutter/ably_flutter.dart' as ably;

class PushNotificationService {
  late final ably.Realtime? realtime;
  late final ably.Rest? rest;
  ably.RealtimeChannelInterface? _realtimeChannel;
  ably.RestChannelInterface? _restChannel;

  // add a Stream to Realtime, rest, so that we can update the UI when it changes.
  PushNotificationService({required this.realtime, required this.rest})


}