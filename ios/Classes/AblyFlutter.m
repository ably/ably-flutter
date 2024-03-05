@import Ably;

#import "AblyFlutter.h"
#import <ably_flutter/ably_flutter-Swift.h>

#import "codec/AblyFlutterReaderWriter.h"
#import "AblyFlutterMessage.h"
#import "AblyInstanceStore.h"
#import "AblyFlutterStreamHandler.h"
#import "AblyStreamsChannel.h"
#import "codec/AblyPlatformConstants.h"
#import "ARTLog.h"

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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    AblyFlutterClientOptions *const options = (AblyFlutterClientOptions*) message[TxTransportKeys_options];
    
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];
    ARTLog *const logger = [[ARTLog alloc] init];
    logger.logLevel = options.clientOptions.logLevel;

    AblyInstanceStore *const instanceStore = [ably instanceStore];
    NSNumber *const handle = [instanceStore getNextHandle];
    
    if(options.hasAuthCallback){
        options.clientOptions.authCallback =
        ^(ARTTokenParams *tokenParams, void(^callback)(id<ARTTokenDetailsCompatible>, NSError *)){
            AblyFlutterMessage *const message = [[AblyFlutterMessage alloc] initWithMessage:tokenParams handle: handle];
            [ably.channel invokeMethod:AblyPlatformMethod_authCallback
                             arguments:message
                                result:^(id tokenData){
                if (!tokenData) {
                    [logger log:[NSString stringWithFormat:@"No token data received %@", tokenData] withLevel: ARTLogLevelWarn];
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTErrorAuthConfiguredProviderFailure userInfo:nil]);
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    [logger log:[NSString stringWithFormat:@"Error getting token data %@", tokenData] withLevel: ARTLogLevelError];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTChannelOptions *const channelOptions = (ARTChannelOptions*) message[TxTransportKeys_options];

    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
    ARTRestChannel *const channel = [rest.channels get:channelName];
    
    [channel setOptions:channelOptions];
    result(nil);
};

static const FlutterHandler _publishRestMessage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*) message[TxTransportKeys_messages];

    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTDataQuery *const dataQuery = (ARTDataQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
    
    [rest.channels release:channelName];
    result(nil);
};

static const FlutterHandler _createRealtime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    AblyFlutterClientOptions *const options = (AblyFlutterClientOptions*) message[TxTransportKeys_options];
    
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];
    ARTLog *const logger = [[ARTLog alloc] init];
    logger.logLevel = options.clientOptions.logLevel;

    AblyInstanceStore *const instanceStore = [ably instanceStore];
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
                    [logger log:[NSString stringWithFormat:@"No token data received %@", tokenData] withLevel: ARTLogLevelWarn];
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTErrorAuthConfiguredProviderFailure userInfo:nil]);
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    [logger log:[NSString stringWithFormat:@"Error getting token data %@", tokenData] withLevel: ARTLogLevelError];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];

    [[instanceStore realtimeFrom:ablyMessage.handle] connect];
    result(nil);
};

static const FlutterHandler _closeRealtime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    
    [[instanceStore realtimeFrom:ablyMessage.handle] close];
    result(nil);
};

static const FlutterHandler _attachRealtimeChannel = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const realtimePayload = ablyMessage.message;
    NSString  *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const realtimePayload = ablyMessage.message;
    NSString *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*) realtimePayload[TxTransportKeys_messages];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    
    [channel publish:messages callback:callback];
};

static const FlutterHandler _setRealtimeChannelOptions = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const realtimePayload = ablyMessage.message;
    NSString *const channelName = (NSString*) realtimePayload[TxTransportKeys_channelName];
    ARTRealtimeChannelOptions *const channelOptions = (ARTRealtimeChannelOptions*) realtimePayload[TxTransportKeys_options];

    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];

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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTRealtimePresenceQuery *const dataQuery = (ARTRealtimePresenceQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*) message[TxTransportKeys_params];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) message[TxTransportKeys_clientId];
    const id data = message[TxTransportKeys_data];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) message[TxTransportKeys_clientId];
    const id data = message[TxTransportKeys_data];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSMutableDictionary<NSString *, NSObject *> *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    NSString *const clientId = (NSString*) message[TxTransportKeys_clientId];
    const id data = message[TxTransportKeys_data];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
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
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
    
    [realtime.channels release:channelName];
    result(nil);
};

static const FlutterHandler _realtimeTime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
    
    [realtime time:^(NSDate * _Nullable dateTimeResult, NSError * _Nullable error) {
        if(error){
            result(error);
        }else{
            result(@([@(dateTimeResult.timeIntervalSince1970 *1000) longValue]));
        }
    }];
};

static const FlutterHandler _restTime = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRest *const rest = [instanceStore restFrom:ablyMessage.handle];
    
    [rest time:^(NSDate * _Nullable dateTimeResult, NSError * _Nullable error) {
        if(error){
            result(error);
        }else{
            result(@([@(dateTimeResult.timeIntervalSince1970 *1000) longValue]));
        }
    }];
};

static const FlutterHandler _connectionRecoveryKey = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
    NSString *const connectionRecoveryKey = [realtime.connection createRecoveryKey];
    result(connectionRecoveryKey);
};

static const FlutterHandler _getNextPage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTPaginatedResult *paginatedResult = [instanceStore getPaginatedResult:ablyMessage.handle];
    
    [paginatedResult next:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting next page; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:ablyMessage.handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

static const FlutterHandler _getFirstPage = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTPaginatedResult *paginatedResult = [instanceStore getPaginatedResult:ablyMessage.handle];
    
    [paginatedResult first:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting first page; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [instanceStore setPaginatedResult:paginatedResult handle:ablyMessage.handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

static const FlutterHandler _realtimeAuthCreateTokenRequest = ^void(AblyFlutter *const ably, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const ablyMessage = call.arguments;
    NSDictionary *const message = ablyMessage.message;
    NSString *const channelName = (NSString*) message[TxTransportKeys_channelName];
    ARTTokenParams *const tokenParams = (ARTTokenParams *) message[TxTransportKeys_params];
    ARTAuthOptions *const authOptions = (ARTAuthOptions *) message[TxTransportKeys_options];
    
    AblyInstanceStore *const instanceStore = [ably instanceStore];
    ARTRealtime *const realtime = [instanceStore realtimeFrom:ablyMessage.handle];
    [realtime.auth requestToken:tokenParams withOptions:authOptions callback:^(ARTTokenDetails * _Nullable tokenDetails, NSError * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error creating token request = %@", error]
                    details:error
                    ]);
        } else {
            result(tokenDetails);
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
        // Connection fields
        AblyPlatformMethod_connectionRecoveryKey:_connectionRecoveryKey,
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
        //Authorize
        AblyPlatformMethod_realtimeAuthAuthorize: AuthHandlers.realtimeAuthorize,
        AblyPlatformMethod_realtimeAuthCreateTokenRequest: AuthHandlers.realtimeCreateTokenRequest,
        AblyPlatformMethod_realtimeAuthRequestToken: AuthHandlers.realtimeRequestToken,
        AblyPlatformMethod_realtimeAuthGetClientId: AuthHandlers.realtimeAuthClientId,
        AblyPlatformMethod_restAuthAuthorize: AuthHandlers.restAuthorize,
        AblyPlatformMethod_restAuthCreateTokenRequest: AuthHandlers.restCreateTokenRequest,
        AblyPlatformMethod_restAuthRequestToken: AuthHandlers.restRequestToken,
        AblyPlatformMethod_restAuthGetClientId: AuthHandlers.restAuthClientId
    };

    [registrar addApplicationDelegate:self];
    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // We can't use ARTLog here because Ably library may not have been initialized yet
    // And ARTLogLevel is only available after ARTClientOptions are set
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
    
    return YES;
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
    return YES;
}

@end
