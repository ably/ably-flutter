/*
 * This file is derivative of work derived from original work at:
 * https://github.com/loup-v/streams_channel
 * 
 * Copyright 2018 Loup Inc.
 * Copyright 2020 Ably Real-time Ltd (ably.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StreamsChannel {
  StreamsChannel(this.name, [this.codec = const StandardMethodCodec()]);

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final MethodCodec codec;

  int _lastId = 0;

  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = MethodChannel(name, codec);

    final id = ++_lastId;
    final handlerName = '$name#$id';

    StreamController<dynamic> controller;
    controller = StreamController<dynamic>.broadcast(onListen: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, (ByteData reply) async {
        if (reply == null) {
          await controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
          }
        }

        return reply;
      });
      try {
        await methodChannel.invokeMethod('listen#$id', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
              'while activating platform stream on channel $name'),
        ));
      }
    }, onCancel: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, null);
      try {
        await methodChannel.invokeMethod('cancel#$id', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
              'while de-activating platform stream on channel $name'),
        ));
      }
    });
    return controller.stream;
  }
}
