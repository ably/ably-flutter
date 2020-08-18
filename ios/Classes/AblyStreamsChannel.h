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

#import <Flutter/Flutter.h>

//typedef FlutterMessageHandler (^FlutterStreamsHandlerFactory)();

@interface AblyStreamsChannel : NSObject

+ (nonnull instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                               binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;

+ (nonnull instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                               binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                                         codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec;

- (nonnull instancetype)initWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                               codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec;

- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler>* _Nullable (^ _Nonnull)(id _Nonnull))factory;

- (void) reset;

@end
