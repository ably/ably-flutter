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

import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// @nodoc
/// Manages multiple event listeners which would otherwise require verbose code
/// on platform side.
class StreamsChannel {
  /// @nodoc
  /// Initializes with event channel [name] and method [codec].
  StreamsChannel(this.name, this.codec);

  /// @nodoc
  /// The logical channel on which communication happens, not null.
  final String name;

  /// @nodoc
  /// The message codec used by this channel, not null.
  final MethodCodec codec;

  int _lastId = 0;

  /// @nodoc
  /// Registers a listener on platform side and manages the listener
  /// with incremental identifiers.
  Stream<T> receiveBroadcastStream<T>([Object? arguments]) {
    final methodChannel = MethodChannel(name, codec);

    final id = ++_lastId;
    final handlerName = '$name#$id';

    late StreamController<T> controller;
    controller = StreamController<T>.broadcast(onListen: () async {
      // We need to keep this null-asserted for backwards compatibility with
      // Flutter versions before 3.0.0
      // ignore: unnecessary_non_null_assertion
      ServicesBinding.instance!.defaultBinaryMessenger
          .setMessageHandler(handlerName, (reply) async {
        if (reply == null) {
          await controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply) as T);
          } on PlatformException catch (pe) {
            if (pe.details is ErrorInfo) {
              throw AblyException.fromPlatformException(pe);
            } else {
              controller.addError(pe);
            }
          }
        }

        return reply;
      });
      try {
        await methodChannel.invokeMethod('listen#$id', arguments);
      } on Exception catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
              'while activating platform stream on channel $name'),
        ));
      }
    }, onCancel: () async {
      // We need to keep this null-asserted for backwards compatibility with
      // Flutter versions before 3.0.0
      // ignore: unnecessary_non_null_assertion
      ServicesBinding.instance!.defaultBinaryMessenger
          .setMessageHandler(handlerName, null);
      try {
        await methodChannel.invokeMethod('cancel#$id', arguments);
      } on Exception catch (exception, stack) {
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
