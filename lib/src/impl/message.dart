class AblyMessage {

  final int handle;
  final int type;
  final dynamic message;

  AblyMessage(dynamic message, {this.handle, this.type}):
      assert(message!=null),
      this.message = message;

}

class AblyEventMessage {

  final String eventName;
  final dynamic message;

  AblyEventMessage(String eventName, [this.message]):
    assert(eventName!=null, "eventName cannot be null"),
    this.eventName = eventName;

}
