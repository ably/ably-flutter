import 'dart:async';

import 'package:ably_flutter_plugin/src/spec/message.dart';
import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';
import 'package:flutter/services.dart';

import '../../spec/spec.dart' as spec;
import '../platform_object.dart';


class RestPlatformChannel extends PlatformObject implements spec.Channel{
  @override
  AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.Presence presence;

  RestPlatformChannel(int ablyHandle, MethodChannel methodChannel, int restHandle, this.ably, this.name, this.options)
      : super(ablyHandle, methodChannel, restHandle);

  @override
  Future<spec.PaginatedResult<Message>> history([spec.RestHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  @override
  Future<void> publish([String name, dynamic data]) async {
    await this.invoke(PlatformMethod.publish, {
      "channel": this.name,
      "name": name,
      "message": data
    });
    return null;
  }

}


class RestPlatformChannels extends spec.RestChannels<RestPlatformChannel>{

  int ablyHandle;
  MethodChannel methodChannel;
  int restHandle;

  RestPlatformChannels(this.ablyHandle, this.methodChannel, this.restHandle, AblyBase ably): super(ably);

  @override
  RestPlatformChannel createChannel(name, options){
    return RestPlatformChannel(ablyHandle, methodChannel, restHandle, ably, name, options);
  }

}