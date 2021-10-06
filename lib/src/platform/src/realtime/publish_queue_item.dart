import 'dart:async';

import '../../../message/src/message.dart';

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class PublishQueueItem {
  List<Message> messages;
  final Completer<void> completer;

  PublishQueueItem(this.completer, this.messages);
}
