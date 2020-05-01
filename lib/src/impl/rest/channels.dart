import 'dart:async';

import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';
import '../platform_object.dart';


class RestPlatformChannel extends PlatformObject implements spec.RestChannel{

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
  Future<void> publish({String name, dynamic data}) async {
    try {
      Map _map = { "channel": this.name, };
      if(name!=null) _map["name"] = name;
      if(data!=null) _map["message"] = data;
      await this.invoke(PlatformMethod.publish, _map);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
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