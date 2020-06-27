class AblyMessage {

  final int handle;
  final int type;
  final dynamic message;

  AblyMessage(dynamic message, {this.handle, this.type}):
      assert(message!=null),
      this.message = message;

}
