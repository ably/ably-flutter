class AblyMessage {

  final int handle;
  final int type;
  final Object message;

  AblyMessage(this.message, {this.handle, this.type}):
      assert(message!=null);

}

class AblyEventMessage {

  final String eventName;
  final Object message;

  AblyEventMessage(this.eventName, [this.message]):
    assert(eventName!=null, "eventName cannot be null");

}
