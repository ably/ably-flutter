@import Ably;

#import "AblyFlutter.h"
#import <ably_flutter/ably_flutter-Swift.h>
#import <Ably/Ably.h>

#import "codec/AblyFlutterReaderWriter.h"
#import "AblyFlutterMessage.h"
#import "AblyInstanceStore.h"
#import "AblyFlutterStreamHandler.h"
#import "AblyStreamsChannel.h"
#import "codec/AblyPlatformConstants.h"
#import "ARTStatsQuery+ParamBuilder.h"

#define LOG(fmt, ...) NSLog((@"%@:%d " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterHandler)(AblyFlutter * ably, FlutterMethodCall * call, FlutterResult result);

/**
 Anonymous category providing forward declarations of the methods implemented
 by this class for use within this implementation file, specifically from the
 static FlutterHandle declarations.
 */
@interface AblyFlutter ()
-(void)reset;
@end

NS_ASSUME_NONNULL_END

static const FlutterHandler _getPlatformVersion = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"iOS (UIKit) " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
};

static const FlutterHandler _getVersion = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"CocoaPod " stringByAppendingString:[ARTDefault libraryVersion]]);
};

static const FlutterHandler _resetAblyClients = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    [ably reset];
    result(nil);
};

static const FlutterHandler _createRest = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterClientOptions *const options = message.message;
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];

    NSNumber *const handle = [instanceStore getNextHandle];
    if(options.hasAuthCallback){
        options.clientOptions.authCallback =
        ^(ARTTokenParams *tokenParams, void(^callback)(id<ARTTokenDetailsCompatible>, NSError *)){
            AblyFlutterMessage *const message = [[AblyFlutterMessage alloc] initWithMessage:tokenParams handle: handle];
            [ably.channel invokeMethod:AblyPlatformMethod_authCallback
                             arguments:message
                                result:^(id tokenData){
                if (!tokenData) {
                    NSLog(@"No token data received %@", tokenData);
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTErrorAuthConfiguredProviderFailure userInfo:nil]);
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    NSLog(@"Error getting token data %@", tokenData);
                    callback(nil, tokenData);
                } else {
                    callback(tokenData, nil);
                }
            }];
        };
    }
    ARTRest *const rest = [[ARTRest alloc] initWithOptions:options.clientOptions];
    [instanceStore setRest:rest with: handle];

    NSData *const apnsDeviceToken = ably.instanceStore.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;
    NSError *const error = ably.instanceStore.didFailToRegisterForRemoteNotificationsWithError_error;
    if (apnsDeviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:apnsDeviceToken rest:rest];
    } else if (error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError:error rest:rest];
    }

    result(handle);
};

static const FlutterHandler _setRestChannelOptions = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTChannelOptions *const channelOptions = (ARTChannelOptions*) _dataMap[TxTransportKeys_options];

    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];
    [channel setOptions:channelOptions];
    result(nil);
};

static const FlutterHandler _publishRestMessage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*) _dataMap[TxTransportKeys_messages];

    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];

    [channel publish:messages callback:^(ARTErrorInfo *_Nullable error){
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error publishing rest message; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            result(nil);
        }
    }];
};

static const FlutterHandler _getRestHistory = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTDataQuery *const dataQuery = (ARTDataQuery*) _dataMap[TxTransportKeys_params];
    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel history; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [channel history:dataQuery callback:callback error: nil];
    } else {
        [channel history:callback];
    }
};

static const FlutterHandler _getRestPresence = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*) _dataMap[TxTransportKeys_params];
    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel presence; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] get:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] get:callback];
    }
};

static const FlutterHandler _getRestPresenceHistory = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*) _dataMap[TxTransportKeys_params];
    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel presence; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] history:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] history:callback];
    }
};

static const FlutterHandler _releaseRestChannel = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    ARTRest *const rest = [instanceStore restFrom:messageData.handle];
    NSString *const channelName = (NSString*)messageData.message;
    [rest.channels release:channelName];
    result(nil);
};

static const FlutterHandler _createRealtime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterClientOptions *const options = message.message;
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];

    NSNumber *const handle = [instanceStore getNextHandle];
    if(options.hasAuthCallback){
        options.clientOptions.authCallback =
        ^(ARTTokenParams *tokenParams, void(^callback)(id<ARTTokenDetailsCompatible>, NSError *)){
            AblyFlutterMessage *const message
            = [[AblyFlutterMessage alloc] initWithMessage:tokenParams handle: handle];
            [ably.channel invokeMethod:AblyPlatformMethod_realtimeAuthCallback
                               arguments:message
                                  result:^(id tokenData){
                if (!tokenData) {
                    NSLog(@"No token data received %@", tokenData);
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTErrorAuthConfiguredProviderFailure userInfo:nil]);
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    NSLog(@"Error getting token data %@", tokenData);
                    callback(nil, tokenData);
                } else {
                    callback(tokenData, nil);
                }
            }];
        };
    }
    ARTRealtime *const realtime = [[ARTRealtime alloc] initWithOptions:options.clientOptions];
    [instanceStore setRealtime:realtime with:handle];

    // Giving Ably client the deviceToken registered at device launch (didRegisterForRemoteNotificationsWithDeviceToken).
    // This is not an ideal solution. We save the deviceToken given in didRegisterForRemoteNotificationsWithDeviceToken and the
    // error in didFailToRegisterForRemoteNotificationsWithError and pass it to Ably in the first client that is first created.
    // Ideally, the Ably client doesn't need to be created, and we can pass the deviceToken to Ably like in Ably Java.
    // This is similarly repeated for in _createRest
    NSData *const apnsDeviceToken = ably.instanceStore.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;
    NSError *const error = ably.instanceStore.didFailToRegisterForRemoteNotificationsWithError_error;
    if (apnsDeviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:apnsDeviceToken realtime:realtime];
    } else if (error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError:error realtime:realtime];
    }
    
    result(handle);
};

static const FlutterHandler _connectRealtime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = message.message;
    [[instanceStore realtimeFrom:handle] connect];
    result(nil);
};

static const FlutterHandler _closeRealtime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = message.message;
    [[instanceStore realtimeFrom:handle] close];
    result(nil);
};

static const FlutterHandler _attachRealtimeChannel = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtime = [instanceStore realtimeFrom:realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [channel attach:^(ARTErrorInfo *_Nullable error){
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error attaching to realtime channel; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _detachRealtimeChannel = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtime = [instanceStore realtimeFrom:realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString  *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [channel detach:^(ARTErrorInfo *_Nullable error){
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error detaching from realtime channel; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _publishRealtimeChannelMessage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtime = [instanceStore realtimeFrom:realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    void (^callback)(ARTErrorInfo *_Nullable) = ^(ARTErrorInfo *_Nullable error){
        if (error) {
            result(
                   [FlutterError errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                                       message:[NSString stringWithFormat:@"Error publishing realtime message; err = %@", [error message]]
                                       details:error]
                   );
        } else {
            result(nil);
        }
    };
    
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*) realtimePayload[TxTransportKeys_messages];
    [channel publish:messages callback:callback];
};

static const FlutterHandler _setRealtimeChannelOptions = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtime = [instanceStore realtimeFrom:realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    ARTRealtimeChannelOptions *const channelOptions = (ARTRealtimeChannelOptions*) realtimePayload[TxTransportKeys_options];

    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [channel setOptions:channelOptions callback:^(ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error setting realtime channel options; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _getRealtimeHistory = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*) _dataMap[TxTransportKeys_params];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting realtime channel history; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [channel history:dataQuery callback:callback error: nil];
    } else {
        [channel history:callback];
    }
};

static const FlutterHandler _getRealtimePresence = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTRealtimePresenceQuery *const dataQuery = (ARTRealtimePresenceQuery*) _dataMap[TxTransportKeys_params];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    const id callback = ^(NSArray<ARTPresenceMessage *> * _Nullable presenceMembers, ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting realtime channel presence; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            result(presenceMembers);
        }
    };
    if (dataQuery) {
        [[channel presence] get:dataQuery callback:callback];
    } else {
        [[channel presence] get:callback];
    }
};

static const FlutterHandler _getRealtimePresenceHistory = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*) _dataMap[TxTransportKeys_params];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error querying realtime channel presence history; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] history:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] history:callback];
    }
};

static const FlutterHandler _enterRealtimePresence = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) _dataMap[TxTransportKeys_clientId];
    const id data = _dataMap[TxTransportKeys_data];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [[channel presence] enterClient:clientId data:data callback:^(ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error entering realtime channel presence for %@; err = %@", channelName, [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _updateRealtimePresence = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) _dataMap[TxTransportKeys_clientId];
    const id data = _dataMap[TxTransportKeys_data];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [[channel presence] updateClient:clientId data:data callback:^(ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error updating realtime channel presence for %@; err = %@", channelName, [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _leaveRealtimePresence = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*) _dataMap[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) _dataMap[TxTransportKeys_clientId];
    const id data = _dataMap[TxTransportKeys_data];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    ARTRealtimeChannel *const channel = [realtime.channels get:channelName];
    [[channel presence] leaveClient:clientId data:data callback:^(ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error leaving realtime channel presence for %@; err = %@", channelName, [error message]]
                    details:error
                    ]);
        } else {
            result(nil);
        }
    }];
};

static const FlutterHandler _releaseRealtimeChannel = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *const messageData = message.message;
    ARTRealtime *const realtime = [instanceStore realtimeFrom:messageData.handle];
    NSString *const channelName = (NSString*)messageData.message;
    [realtime.channels release:channelName];
    result(nil);
};

static const FlutterHandler _realtimeTime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    
    ARTRealtime *const realtime = [instanceStore realtimeFrom:message.message];
    [realtime time:^(NSDate * _Nullable dateTimeResult, NSError * _Nullable error) {
        if(error){
            result(error);
        }else{
            result(@([@(dateTimeResult.timeIntervalSince1970 *1000) longValue]));
        }
    }];
};

static const FlutterHandler _restTime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = message.message;
    ARTRest *const rest = [instanceStore restFrom:handle];
    [rest time:^(NSDate * _Nullable dateTimeResult, NSError * _Nullable error) {
        if(error){
            result(error);
        }else{
            result(@([@(dateTimeResult.timeIntervalSince1970 *1000) longValue]));
        }
    }];
};

static const FlutterHandler _stats = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const arguments = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    AblyFlutterMessage *message = arguments.message;
    ARTRest *const rest = [instanceStore restFrom:message.handle];
    NSDictionary *paramsDict =  message.message;
    ARTStatsQuery *query;
    if(paramsDict[@"params"]){
        NSDictionary *statsParams = paramsDict[@"params"];
        query = [ARTStatsQuery fromParams:statsParams];
    }

    NSError *statsError;
    [rest stats:query callback:^(ARTPaginatedResult<ARTStats *> *statsResult, ARTErrorInfo *error) {
        if(error){
            result(error);
        }else{
            result(statsResult);
        }
    } error:&statsError];

};

static const FlutterHandler _getNextPage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = message.message;
    ARTPaginatedResult *paginatedResult = [instanceStore getPaginatedResult:handle];
    [paginatedResult next:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting next page; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

static const FlutterHandler _getFirstPage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = message.message;
    ARTPaginatedResult *paginatedResult = [instanceStore getPaginatedResult:handle];
    [paginatedResult first:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting first page; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

@implementation AblyFlutter {
    NSDictionary<NSString *, FlutterHandler>* _handlers;
    AblyStreamsChannel* _streamsChannel;
    FlutterMethodChannel* _channel;
    PushNotificationEventHandlers* _pushNotificationEventHandlers;
}

@synthesize instanceStore = _instanceStore;

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    LOG(@"registrar: %@", [registrar class]);
    
    // Initializing reader writer and method codecs
    FlutterStandardReaderWriter *const readerWriter = [AblyFlutterReaderWriter new];
    FlutterStandardMethodCodec *const methodCodec = [FlutterStandardMethodCodec codecWithReaderWriter:readerWriter];
    
    // initializing event channel for event listeners
    AblyStreamsChannel *const streamsChannel =
    [AblyStreamsChannel streamsChannelWithName:@"io.ably.flutter.stream"
                               binaryMessenger:registrar.messenger
                                         codec:methodCodec];
    
    // initializing method channel for round-trip method calls
    FlutterMethodChannel *const methodChannel = [FlutterMethodChannel methodChannelWithName:@"io.ably.flutter.plugin" binaryMessenger:[registrar messenger] codec:methodCodec];
    AblyFlutter *const ably = [[AblyFlutter alloc] initWithChannel:methodChannel streamsChannel: streamsChannel registrar:registrar];
    
    // registering method channel with registrar
    [registrar addMethodCallDelegate:ably channel:methodChannel];
    
    // setting up stream handler factory for eventChannel to handle multiple listeners
    [streamsChannel setStreamHandlerFactory:^NSObject<FlutterStreamHandler> *(id arguments) {
        return [AblyFlutterStreamHandler new];
    }];
}

-(instancetype)initWithChannel:(FlutterMethodChannel *const)channel
                streamsChannel:(AblyStreamsChannel *const)streamsChannel
                     registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    self = [super init];
    if (!self) {
        return nil;
    }
    _instanceStore = [AblyInstanceStore sharedInstance];
    _channel = channel;
    _streamsChannel = streamsChannel;
    UNUserNotificationCenter *const center = UNUserNotificationCenter.currentNotificationCenter;
    _pushNotificationEventHandlers = [[PushNotificationEventHandlers alloc] initWithDelegate: center.delegate andMethodChannel: channel];
    center.delegate = _pushNotificationEventHandlers;
    
    _handlers = @{
        AblyPlatformMethod_getPlatformVersion: _getPlatformVersion,
        AblyPlatformMethod_getVersion: _getVersion,
        AblyPlatformMethod_resetAblyClients: _resetAblyClients,
        AblyPlatformMethod_createRest: _createRest,
        AblyPlatformMethod_setRestChannelOptions: _setRestChannelOptions,
        AblyPlatformMethod_publish: _publishRestMessage,
        AblyPlatformMethod_restHistory: _getRestHistory,
        AblyPlatformMethod_restPresenceGet: _getRestPresence,
        AblyPlatformMethod_restPresenceHistory: _getRestPresenceHistory,
        AblyPlatformMethod_releaseRestChannel: _releaseRestChannel,
        AblyPlatformMethod_createRealtime: _createRealtime,
        AblyPlatformMethod_setRealtimeChannelOptions: _setRealtimeChannelOptions,
        AblyPlatformMethod_connectRealtime: _connectRealtime,
        AblyPlatformMethod_closeRealtime: _closeRealtime,
        AblyPlatformMethod_attachRealtimeChannel: _attachRealtimeChannel,
        AblyPlatformMethod_detachRealtimeChannel: _detachRealtimeChannel,
        AblyPlatformMethod_publishRealtimeChannelMessage: _publishRealtimeChannelMessage,
        AblyPlatformMethod_realtimeHistory: _getRealtimeHistory,
        AblyPlatformMethod_nextPage: _getNextPage,
        AblyPlatformMethod_firstPage: _getFirstPage,
        AblyPlatformMethod_realtimePresenceGet: _getRealtimePresence,
        AblyPlatformMethod_realtimePresenceHistory: _getRealtimePresenceHistory,
        AblyPlatformMethod_realtimePresenceEnter: _enterRealtimePresence,
        AblyPlatformMethod_realtimePresenceUpdate: _updateRealtimePresence,
        AblyPlatformMethod_realtimePresenceLeave: _leaveRealtimePresence,
        AblyPlatformMethod_releaseRealtimeChannel: _releaseRealtimeChannel,
        AblyPlatformMethod_realtimeTime:_realtimeTime,
        AblyPlatformMethod_restTime:_restTime,
        AblyPlatformMethod_stats:_stats,
        // Push Notifications
        AblyPlatformMethod_pushActivate: PushHandlers.activate,
        AblyPlatformMethod_pushRequestPermission: PushHandlers.requestPermission,
        AblyPlatformMethod_pushGetNotificationSettings: PushHandlers.getNotificationSettings,
        AblyPlatformMethod_pushDeactivate: PushHandlers.deactivate,
        AblyPlatformMethod_pushSubscribeDevice: PushHandlers.subscribeDevice,
        AblyPlatformMethod_pushUnsubscribeDevice: PushHandlers.unsubscribeDevice,
        AblyPlatformMethod_pushSubscribeClient: PushHandlers.subscribeClient,
        AblyPlatformMethod_pushUnsubscribeClient: PushHandlers.unsubscribeClient,
        AblyPlatformMethod_pushListSubscriptions: PushHandlers.listSubscriptions,
        AblyPlatformMethod_pushDevice: PushHandlers.device,
        AblyPlatformMethod_pushNotificationTapLaunchedAppFromTerminated: PushHandlers.pushNotificationTapLaunchedAppFromTerminated,
        // Encryption
        AblyPlatformMethod_cryptoGetParams: CryptoHandlers.getParams,
        AblyPlatformMethod_cryptoGenerateRandomKey: CryptoHandlers.generateRandomKey,
    };

    [registrar addApplicationDelegate:self];
    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    LOG(@"%@(%@)", call.method, call.arguments ? [call.arguments class] : @"");
    const FlutterHandler handler = _handlers[call.method];
    if (!handler) {
        // We don't have a handler for a method with this name so tell the caller.
        result(FlutterMethodNotImplemented);
    } else {
        // We have a handler for a method with this name so delegate to it.
        handler(self, call, result);
    }
}

-(void)reset {
    [_instanceStore reset];
    [self->_streamsChannel reset];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    // Check if application was launched from a notification tap.
    
    // https://stackoverflow.com/a/21611009/7365866
    NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        PushHandlers.pushNotificationTapLaunchedAppFromTerminatedData = notification;
    }
    
    return NO;
}

#pragma mark - Push Notifications Registration - UIApplicationDelegate
/// Save the deviceToken provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Set deviceToken on all existing Ably clients, and a property which used for all future Ably clients.
    [_instanceStore didRegisterForRemoteNotificationsWithDeviceToken: deviceToken];
}

/// Save the error if it occurred during APNs device registration provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // This error will be used when the first Ably client is made.
    _instanceStore.didFailToRegisterForRemoteNotificationsWithError_error = error;
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [_pushNotificationEventHandlers application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    return NO;
}

@end
