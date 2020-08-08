import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/rest/rest.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';

import '../platform_object.dart';


class RestPlatformChannel extends PlatformObject implements spec.RestChannel{

  /// [Rest] instance
  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.Presence presence;

  RestPlatformChannel(this.ably, this.name, this.options);

  Rest get restPlatformObject => this.ably as Rest;

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async  => await restPlatformObject.handle;

  @override
  Future<spec.PaginatedResult<spec.Message>> history([spec.RestHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  bool authCallbackInProgress = false;

  @override
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    dynamic data,
  }) async {
    bool hasAuthCallback = ably.options.authCallback!=null;
    while (hasAuthCallback && authCallbackInProgress) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    try {
      if(messages == null){
        if (message != null) {
          messages = [message];
        } else {
          messages ??= [
            spec.Message(
              name: name,
              data: data
            )
          ];
        }
      }
      await invoke(PlatformMethod.publish, {
        'channel': this.name,
        'messages': messages
      });
    } on PlatformException catch (pe) {
      if (hasAuthCallback && pe.code == "80019") {
        authCallbackInProgress = true;
        await publish(name: name, data: data);
      } else {
        throw spec.AblyException(pe.code, pe.message, pe.details);
      }
    }
  }

  void authUpdateComplete() {
    authCallbackInProgress = false;
  }

}


class RestPlatformChannels extends spec.RestChannels<RestPlatformChannel>{

  RestPlatformChannels(Rest ably): super(ably);

  @override
  RestPlatformChannel createChannel(name, options){
    return RestPlatformChannel(ably, name, options);
  }

}
