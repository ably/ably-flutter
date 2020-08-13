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

#import "AblyStreamsChannel.h"

@interface AblyStreamsChannelStream : NSObject
  @property(strong, nonatomic) FlutterEventSink sink;
  @property(strong, nonatomic) NSObject<FlutterStreamHandler> *handler;
@end

@implementation AblyStreamsChannelStream

@end

// Inspired from: https://github.com/flutter/engine/blob/master/shell/platform/darwin/common/framework/Source/FlutterChannels.mm
@implementation AblyStreamsChannel {
  NSObject<FlutterBinaryMessenger>* _messenger;
  NSString* _name;
  NSObject<FlutterMethodCodec>* _codec;
  __block NSMutableDictionary *_streams;
  __block NSMutableDictionary *_listenerArguments;
}

+ (instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger {
  NSObject<FlutterMethodCodec>* codec = [FlutterStandardMethodCodec sharedInstance];
  return [AblyStreamsChannel streamsChannelWithName:name binaryMessenger:messenger codec:codec];
}

+ (instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                               codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec {
  return [[AblyStreamsChannel alloc] initWithName:name binaryMessenger:messenger codec:codec];
}

- (instancetype)initWithName:(NSString* _Nonnull)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                       codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec {
  self = [super init];
  NSAssert(self, @"Super init cannot be nil");
  _name = name;
  _messenger = messenger;
  _codec = codec;
  return self;
}

- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  if (!factory) {
    [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:nil];
    return;
  }
  
  _streams = [NSMutableDictionary new];
  _listenerArguments = [NSMutableDictionary new];
  FlutterBinaryMessageHandler messageHandler = ^(NSData* message, FlutterBinaryReply callback) {
    FlutterMethodCall* call = [self->_codec decodeMethodCall:message];
    NSArray *methodParts = [call.method componentsSeparatedByString:@"#"];
    
    if (methodParts.count != 2) {
      callback(nil);
      return;
    }
    
    NSInteger keyValue = [methodParts.lastObject integerValue];
    if(keyValue == 0) {
      callback([self->_codec encodeErrorEnvelope:[FlutterError errorWithCode:@"error" message:[NSString stringWithFormat:@"Invalid method name: %@", call.method] details:nil]]);
      return;
    }
    
    NSNumber *key = [NSNumber numberWithInteger:keyValue];
    
    if ([methodParts.firstObject isEqualToString:@"listen"]) {
        [self listenForCall:call withKey:key usingCallback:callback andFactory:factory];
    } else if ([methodParts.firstObject isEqualToString:@"cancel"]) {
        [self cancelForCall:call withKey:key usingCallback:callback andFactory:factory];
    } else {
      callback(nil);
    }
  };
  
  [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:messageHandler];
}

- (void) reset{
    for (NSString* key in [_streams copy]) {
        AblyStreamsChannelStream *stream = _streams[key];
        [stream.handler onCancelWithArguments:nil];
        [_streams removeObjectForKey:key];
        [_listenerArguments removeObjectForKey:key];
    }
}

- (void)listenForCall:(FlutterMethodCall*)call withKey:(NSNumber*)key usingCallback:(FlutterBinaryReply)callback andFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  AblyStreamsChannelStream *stream = [AblyStreamsChannelStream new];
  stream.sink = ^(id event) {
    NSString *name = [NSString stringWithFormat:@"%@#%@", self->_name, key];
    
    if (event == FlutterEndOfEventStream) {
      [self->_messenger sendOnChannel:name message:nil];
    } else if ([event isKindOfClass:[FlutterError class]]) {
      [self->_messenger sendOnChannel:name
                              message:[self->_codec encodeErrorEnvelope:(FlutterError*)event]];
    } else {
      [self->_messenger sendOnChannel:name message:[self->_codec encodeSuccessEnvelope:event]];
    }
  };
  stream.handler = factory(call.arguments);
  
  [_streams setObject:stream forKey:key];
  [_listenerArguments setObject:call.arguments forKey:key];
  
  [self triggerCallback:callback
                  error:[stream.handler onListenWithArguments:call.arguments eventSink:stream.sink]];
}
  
- (void)cancelForCall:(FlutterMethodCall*)call withKey:(NSNumber*)key usingCallback:(FlutterBinaryReply)callback andFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  AblyStreamsChannelStream *stream = [_streams objectForKey:key];
  if(!stream) {
    callback([_codec encodeErrorEnvelope:[FlutterError errorWithCode:@"error" message:@"No active stream to cancel" details:nil]]);
    return;
  }
  
  [_streams removeObjectForKey:key];
  [_listenerArguments removeObjectForKey:key];
  
  [self triggerCallback:callback error:[stream.handler onCancelWithArguments:call.arguments]];
}

- (void) triggerCallback:(FlutterBinaryReply)callback error:(FlutterError *const) error {
    if (error) {
      callback([_codec encodeErrorEnvelope:error]);
    } else {
      callback([_codec encodeSuccessEnvelope:nil]);
    }
}

@end
