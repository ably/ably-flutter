import 'dart:async';

import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';
import '../platform_object.dart';


class RestPlatformChannel extends PlatformObject implements spec.Channel{

  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.Presence presence;

  RestPlatformChannel(int ablyHandle, MethodChannel methodChannel, int restHandle, this.ably, this.name, this.options)
      : super(ablyHandle, methodChannel, restHandle);

  @override
  Future<spec.PaginatedResult<spec.Message>> history([spec.RestHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  @override
  Future<void> publish([String name, dynamic data]) async {
    try {
      await this.invoke(PlatformMethod.publish, {
        "channel": this.name,
        "name": name,
        "message": data
      });
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message);
    }
  }

}


class RestPlatformChannels extends spec.RestChannels<RestPlatformChannel>{

  int ablyHandle;
  MethodChannel methodChannel;
  int restHandle;

  RestPlatformChannels(this.ablyHandle, this.methodChannel, this.restHandle, spec.AblyBase ably): super(ably);

  @override
  RestPlatformChannel createChannel(name, options){
    return RestPlatformChannel(ablyHandle, methodChannel, restHandle, ably, name, options);
  }

}