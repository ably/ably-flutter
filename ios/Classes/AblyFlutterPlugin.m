@import Ably;

#import "AblyFlutterPlugin.h"
#import <ably_flutter/ably_flutter-Swift.h>

#import "codec/AblyFlutterReaderWriter.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutter.h"
#import "AblyFlutterStreamHandler.h"
#import "AblyStreamsChannel.h"
#import "codec/AblyPlatformConstants.h"

#define LOG(fmt, ...) NSLog((@"%@:%d " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterHandler)(AblyFlutterPlugin * plugin, FlutterMethodCall * call, FlutterResult result);

/**
 Anonymous category providing forward declarations of the methods implemented
 by this class for use within this implementation file, specifically from the
 static FlutterHandle declarations.
 */
@interface AblyFlutterPlugin ()
-(void)registerWithCompletionHandler:(FlutterResult)completionHandler;
@end

NS_ASSUME_NONNULL_END

static const FlutterHandler _getPlatformVersion = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"iOS (UIKit) " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
};

static const FlutterHandler _getVersion = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"CocoaPod " stringByAppendingString:[ARTDefault libraryVersion]]);
};

static const FlutterHandler _register = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    [plugin registerWithCompletionHandler:result];
};

static const FlutterHandler _createRestWithOptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterClientOptions *const options = message.message;
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];
    NSNumber *const restHandle = [ably createRestWithOptions:options];
    ARTRest *const rest = [ably getRest:restHandle];
    
    if (plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken rest:rest];
    } else if (plugin.didFailToRegisterForRemoteNotificationsWithError_error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError: plugin.didFailToRegisterForRemoteNotificationsWithError_error rest:rest];
    }
    
    result(restHandle);
};

static const FlutterHandler _setRestChannelOptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey:TxTransportKeys_channelName];
    ARTChannelOptions *const channelOptions = (ARTChannelOptions*)[_dataMap objectForKey:TxTransportKeys_options];

    ARTRest *const client = [ably getRest:messageData.handle];
    ARTRestChannel *const channel = [client.channels get:channelName];
    [channel setOptions:channelOptions];
    result(nil);
};

static const FlutterHandler _publishRestMessage = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey:TxTransportKeys_channelName];
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*)[_dataMap objectForKey:TxTransportKeys_messages];

    ARTRest *const client = [ably getRest:messageData.handle];
    ARTRestChannel *const channel = [client.channels get:channelName];

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

static const FlutterHandler _getRestHistory = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTDataQuery *const dataQuery = (ARTDataQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRest *const client = [ably getRest:messageData.handle];
    ARTRestChannel *const channel = [client.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel history; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [channel history:dataQuery callback:callback error: nil];
    } else {
        [channel history:callback];
    }
};

static const FlutterHandler _getRestPresence = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRest *const client = [ably getRest:messageData.handle];
    ARTRestChannel *const channel = [client.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel presence; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] get:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] get:callback];
    }
};

static const FlutterHandler _getRestPresenceHistory = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTPresenceQuery *const dataQuery = (ARTPresenceQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRest *const client = [ably getRest:messageData.handle];
    ARTRestChannel *const channel = [client.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting rest channel presence; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] history:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] history:callback];
    }
};

static const FlutterHandler _releaseRestChannel = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    ARTRest *const client = [ably getRest:messageData.handle];
    NSString *const channelName = (NSString*)messageData.message;
    [client.channels release:channelName];
    result(nil);
};

static const FlutterHandler _createRealtimeWithOptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterClientOptions *const options = message.message;
    options.clientOptions.pushRegistererDelegate = [PushActivationEventHandlers getInstanceWithMethodChannel: ably.channel];
    NSNumber *const realtimeHandle = [ably createRealtimeWithOptions:options];
    ARTRealtime *const realtime = [ably realtimeWithHandle:realtimeHandle];
    
    // Giving Ably client the deviceToken registered at device launch (didRegisterForRemoteNotificationsWithDeviceToken).
    // This is not an ideal solution. We save the deviceToken given in didRegisterForRemoteNotificationsWithDeviceToken and the
    // error in didFailToRegisterForRemoteNotificationsWithError and pass it to Ably in the first client that is first created.
    // Ideally, the Ably client doesn't need to be created, and we can pass the deviceToken to Ably like in Ably Java.
    // This is similarly repeated for in _createRestWithOptions
    if (plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken realtime:realtime];
    } else if (plugin.didFailToRegisterForRemoteNotificationsWithError_error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError: plugin.didFailToRegisterForRemoteNotificationsWithError_error realtime:realtime];
    }
    
    result(realtimeHandle);
};

static const FlutterHandler _connectRealtime = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    NSNumber *const handle = message.message;
    [[ably realtimeWithHandle:handle] connect];
    result(nil);
};

static const FlutterHandler _closeRealtime = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    NSNumber *const handle = message.message;
    [[ably realtimeWithHandle:handle] close];
    result(nil);
};

static const FlutterHandler _attachRealtimeChannel = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtimeWithHandle = [ably realtimeWithHandle: realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*)[realtimePayload objectForKey:TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtimeWithHandle.channels get:channelName];
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

static const FlutterHandler _detachRealtimeChannel = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtimeWithHandle = [ably realtimeWithHandle: realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString  *const channelName = (NSString*)[realtimePayload objectForKey:TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtimeWithHandle.channels get:channelName];
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

static const FlutterHandler _publishRealtimeChannelMessage = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtimeWithHandle = [ably realtimeWithHandle: realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*)[realtimePayload objectForKey:TxTransportKeys_channelName];
    ARTRealtimeChannel *const channel = [realtimeWithHandle.channels get:channelName];
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
    
    NSArray<ARTMessage *> *const messages = (NSArray<ARTMessage *>*)[realtimePayload objectForKey:TxTransportKeys_messages];
    [channel publish:messages callback:callback];
};

static const FlutterHandler _setRealtimeChannelOptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const data = message.message;
    NSNumber *const realtimeHandle = data.handle;
    ARTRealtime *const realtimeWithHandle = [ably realtimeWithHandle: realtimeHandle];
    
    NSDictionary *const realtimePayload = data.message;
    NSString *const channelName = (NSString*)[realtimePayload objectForKey:TxTransportKeys_channelName];
    ARTRealtimeChannelOptions *const channelOptions = (ARTRealtimeChannelOptions*)[realtimePayload objectForKey:TxTransportKeys_options];

    ARTRealtimeChannel *const channel = [realtimeWithHandle.channels get:channelName];
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

static const FlutterHandler _getRealtimeHistory = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting realtime channel history; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [channel history:dataQuery callback:callback error: nil];
    } else {
        [channel history:callback];
    }
};

static const FlutterHandler _getRealtimePresence = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTRealtimePresenceQuery *const dataQuery = (ARTRealtimePresenceQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
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

static const FlutterHandler _getRealtimePresenceHistory = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    ARTRealtimeHistoryQuery *const dataQuery = (ARTRealtimeHistoryQuery*)[_dataMap objectForKey: TxTransportKeys_params];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
    const id callback = ^(ARTPaginatedResult<ARTMessage *> * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error querying realtime channel presence history; err = %@", [error message]]
                    details:error
                    ]);
        } else {
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:nil];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    };
    if (dataQuery) {
        [[channel presence] history:dataQuery callback:callback error:nil];
    } else {
        [[channel presence] history:callback];
    }
};

static const FlutterHandler _enterRealtimePresence = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    NSString *const clientId = (NSString*)[_dataMap objectForKey: TxTransportKeys_clientId];
    const id data = [_dataMap objectForKey: TxTransportKeys_data];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
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

static const FlutterHandler _updateRealtimePresence = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    NSString *const clientId = (NSString*)[_dataMap objectForKey: TxTransportKeys_clientId];
    const id data = [_dataMap objectForKey: TxTransportKeys_data];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
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

static const FlutterHandler _leaveRealtimePresence = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey: TxTransportKeys_channelName];
    NSString *const clientId = (NSString*)[_dataMap objectForKey: TxTransportKeys_clientId];
    const id data = [_dataMap objectForKey: TxTransportKeys_data];
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    ARTRealtimeChannel *const channel = [client.channels get:channelName];
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

static const FlutterHandler _releaseRealtimeChannel = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const messageData = message.message;
    ARTRealtime *const client = [ably realtimeWithHandle:messageData.handle];
    NSString *const channelName = (NSString*)messageData.message;
    [client.channels release:channelName];
    result(nil);
};

static const FlutterHandler _getNextPage = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    NSNumber *const handle = message.message;
    ARTPaginatedResult *paginatedResult = [ably getPaginatedResult:handle];
    [paginatedResult next:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting next page; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

static const FlutterHandler _getFirstPage = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    NSNumber *const handle = message.message;
    ARTPaginatedResult *paginatedResult = [ably getPaginatedResult:handle];
    [paginatedResult first:^(ARTPaginatedResult * _Nullable paginatedResult, ARTErrorInfo * _Nullable error) {
        if(error){
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error getting first page; err = %@", [error message]]
                    details:error
                    ]);
        }else{
            NSNumber *const paginatedResultHandle = [ably setPaginatedResult:paginatedResult handle:handle];
            result([[AblyFlutterMessage alloc] initWithMessage:paginatedResult handle: paginatedResultHandle]);
        }
    }];
};

@implementation AblyFlutterPlugin {
    long long _nextRegistration;
    NSDictionary<NSString *, FlutterHandler>* _handlers;
    AblyStreamsChannel* _streamsChannel;
    FlutterMethodChannel* _channel;
    PushNotificationEventHandlers* _pushNotificationEventHandlers;
    CipherParamsStorage* _cipherParamsStorage;
}

@synthesize ably = _ably;

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
    FlutterMethodChannel *const channel = [FlutterMethodChannel methodChannelWithName:@"io.ably.flutter.plugin" binaryMessenger:[registrar messenger] codec:methodCodec];
    AblyFlutterPlugin *const plugin = [[AblyFlutterPlugin alloc] initWithChannel:channel streamsChannel: streamsChannel registrar:registrar];
    
    // registering method channel with registrar
    [registrar addMethodCallDelegate:plugin channel:channel];
    
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
    _ably = [AblyFlutter sharedInstance];
    [_ably setChannel: channel];
    self->_streamsChannel = streamsChannel;
    UNUserNotificationCenter *const center = UNUserNotificationCenter.currentNotificationCenter;
    _pushNotificationEventHandlers = [[PushNotificationEventHandlers alloc] initWithDelegate: center.delegate andMethodChannel: channel];
    center.delegate = _pushNotificationEventHandlers;
    
    _handlers = @{
        AblyPlatformMethod_getPlatformVersion: _getPlatformVersion,
        AblyPlatformMethod_getVersion: _getVersion,
        AblyPlatformMethod_registerAbly: _register,
        AblyPlatformMethod_createRestWithOptions: _createRestWithOptions,
        AblyPlatformMethod_setRestChannelOptions: _setRestChannelOptions,
        AblyPlatformMethod_publish: _publishRestMessage,
        AblyPlatformMethod_restHistory: _getRestHistory,
        AblyPlatformMethod_restPresenceGet: _getRestPresence,
        AblyPlatformMethod_restPresenceHistory: _getRestPresenceHistory,
        AblyPlatformMethod_releaseRestChannel: _releaseRestChannel,
        AblyPlatformMethod_createRealtimeWithOptions: _createRealtimeWithOptions,
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
        AblyPlatformMethod_channelOptionsWithCipherKey: CryptoHandlers.channelOptionsWithCipherKey,
    };
    
    _nextRegistration = 1;
    _channel = channel;
    
    [registrar addApplicationDelegate:self];
    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    LOG(@"%@(%@)", call.method, call.arguments ? [call.arguments class] : @"");
    const FlutterHandler handler = [_handlers objectForKey:call.method];
    if (!handler) {
        // We don't have a handler for a method with this name so tell the caller.
        result(FlutterMethodNotImplemented);
    } else {
        // We have a handler for a method with this name so delegate to it.
        handler(self, call, result);
    }
}

-(void)registerWithCompletionHandler:(const FlutterResult)completionHandler {
    if (!completionHandler) {
        [NSException raise:NSInvalidArgumentException format:@"completionHandler cannot be nil."];
    }
    [_ably disposeWithCompletionHandler:^{
        [self->_streamsChannel reset];
        completionHandler(nil);
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    // Check if application was launched from a notification tap.
    
    // https://stackoverflow.com/a/21611009/7365866
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        PushHandlers.pushNotificationTapLaunchedAppFromTerminatedData = notification;
    }
    
    return NO;
}

#pragma mark - Push Notifications Registration - UIApplicationDelegate
/// Save the deviceToken provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // This deviceToken will be used when a new Ably client (either realtime or rest) is made.
    _didRegisterForRemoteNotificationsWithDeviceToken_deviceToken = deviceToken;
}

/// Save the error if it occurred during APNs device registration provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // This error will be used when the first Ably client is made.
    _didFailToRegisterForRemoteNotificationsWithError_error = error;
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [_pushNotificationEventHandlers application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    return NO;
}

@end
