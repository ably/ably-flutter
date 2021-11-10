import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class PublishQueueItem {
  final List<Message> messages;
  final Completer<void> completer;

  PublishQueueItem(this.completer, this.messages);
}
