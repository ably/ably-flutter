#import "AblyFlutterPlugin.h"

@import Ably;

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
    NSNumber *const restHandle = [ably createRestWithOptions:message.message];
    ARTRest *const rest = [ably getRest:restHandle];
    
    if (plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken rest:rest];
        plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken = nil;
    } else if (plugin.didFailToRegisterForRemoteNotificationsWithError_error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError: plugin.didFailToRegisterForRemoteNotificationsWithError_error rest:rest];
        plugin.didFailToRegisterForRemoteNotificationsWithError_error = nil;
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
//    UNUserNotificationCenterDelegate *const delegate = UNUserNotificationCenter.currentNotificationCenter.delegate;
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutter *const ably = [plugin ably];
    NSNumber *const realtimeHandle = [ably createRealtimeWithOptions:message.message];
    ARTRealtime *const realtime = [ably realtimeWithHandle:realtimeHandle];
    
    // Giving Ably client the deviceToken registered at device launch (didRegisterForRemoteNotificationsWithDeviceToken).
    // This is not an ideal solution. We save the deviceToken given in didRegisterForRemoteNotificationsWithDeviceToken and the
    // error in didFailToRegisterForRemoteNotificationsWithError and pass it to Ably in the first client that is first created.
    // Ideally, the Ably client doesn't need to be created, and we can pass the deviceToken to Ably like in Ably Java.
    // This is similarly repeated for in _createRestWithOptions
    if (plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken != nil) {
        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken realtime:realtime];
        plugin.didRegisterForRemoteNotificationsWithDeviceToken_deviceToken = nil;
    } else if (plugin.didFailToRegisterForRemoteNotificationsWithError_error != nil) {
        [ARTPush didFailToRegisterForRemoteNotificationsWithError: plugin.didFailToRegisterForRemoteNotificationsWithError_error realtime:realtime];
        plugin.didFailToRegisterForRemoteNotificationsWithError_error = nil;
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
    [channel setOptions:channelOptions callback:callback];
    result(nil);
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

typedef ARTPush* (^GetPushFromAblyClientHandle)(AblyFlutter *const ably, FlutterMethodCall *const call);
static const GetPushFromAblyClientHandle _getPushFromAblyClientHandle = ^ARTPush*(AblyFlutter *const ably, FlutterMethodCall *const call) {
    AblyFlutterMessage *const message = call.arguments;
    NSNumber *const ablyClientHandle = message.message;
    
    ARTRealtime *const realtimeWithHandle = [ably realtimeWithHandle: ablyClientHandle];
    ARTRest *const restWithHandle = [ably getRest:ablyClientHandle];
    
    if (realtimeWithHandle != nil) {
        return realtimeWithHandle.push;
    } else if (restWithHandle != nil) {
        return restWithHandle.push;
    }
    
    [NSException raise: NSInternalInconsistencyException
                format: @"No ably client exists (rest or realtime)"];
    return nil;
};

/// Typedefs related to _ablyClientReceiver:
/// (running a callback based on whether dart side gave a handle to ARTRealtime or ARTRest client.)
typedef void (^RealtimeClientHandler)(ARTRealtime *const realtime,
                                      FlutterMethodCall *const call,
                                      const FlutterResult result,
                                      NSString *const _Nullable channelName);
typedef void (^RestClientHandler)(ARTRest *const realtime,
                                  FlutterMethodCall *const call,
                                  const FlutterResult result,
                                  NSString *const _Nullable channelName);
typedef void (^AblyClientReceiver)(AblyFlutterPlugin *const plugin,
                                   FlutterMethodCall *const call,
                                   const FlutterResult result,
                                   RealtimeClientHandler const realtimeClientHandler,
                                   RestClientHandler const restClientHandler);

/// The dart side can provide a handle (Int) which gets a ARTRealtime or ARTRest Ably client.
/// This block calls the correct handler (RealtimeClientHandler, RestClientHandler) based on what client this handle provides.
static const AblyClientReceiver _ablyClientReceiver = ^void(AblyFlutterPlugin *const plugin,
                                                   FlutterMethodCall *const call,
                                                   FlutterResult const result,
                                                   RealtimeClientHandler const realtimeClientHandler,
                                                   RestClientHandler const restClientHandler) {
    AblyFlutter *const ably = [plugin ably];
    
    AblyFlutterMessage *const message = call.arguments;
    // Make AblyMessage usage consistent on Dart side, instead of nesting AblyMessages
    // See platform_object.dart invoke method: AblyMessage(AblyMessage(argument, handle: _handle))
    NSNumber * clientHandle;
    NSString * channelName;
    if ([message.message class] == [AblyFlutterMessage class]) {
        AblyFlutterMessage *const messageData = message.message;
        clientHandle = messageData.handle;
        NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
        channelName = (NSString*)[_dataMap objectForKey:TxTransportKeys_channelName];
    } else {
        clientHandle = message.message;
    }
    
    if (!clientHandle) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Client handle was null"];
    }
    
    ARTRealtime *const realtime = [ably realtimeWithHandle: clientHandle];
    ARTRest *const rest = [ably getRest: clientHandle];
    
    if (realtime != nil) {
        realtimeClientHandler(realtime, call, result, channelName);
        return;
    } else if (rest != nil) {
        restClientHandler(rest, call, result, channelName);
        return;
    }
    
    [NSException raise: NSInternalInconsistencyException
                format: @"No ably client exists (rest or realtime)"];
    return;
};

static const FlutterHandler _pushActivate = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    ARTPush *const push = _getPushFromAblyClientHandle([plugin ably], call);
    [push activate];
    result(nil);
};

static const FlutterHandler _pushRequestNotificationPermission = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSNumber *const provisionalPermissionRequest = (NSNumber *)[_dataMap objectForKey:TxPushRequestNotificationPermission_provisionalPermissionRequest];
    
    UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound
        | UNAuthorizationOptionAlert | UNAuthorizationOptionProvidesAppNotificationSettings;
    if ([provisionalPermissionRequest  isEqual: @(YES)]) {
        if (@available(iOS 12, *)) {
            options = options | UNAuthorizationOptionProvisional | UNAuthorizationOptionProvidesAppNotificationSettings;
        }
    }

    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                    message:[NSString stringWithFormat:@"Error requesting authorization to show user notifications; err = %@", error.localizedDescription]
                    details:nil
                    ]);
            return;
        }
        result([NSNumber numberWithBool:granted]);
    }];
};

static const FlutterHandler _pushDeactivate = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    ARTPush *const push = _getPushFromAblyClientHandle([plugin ably], call);
    [push deactivate];
    result(nil);
};

static const FlutterHandler _pushSubscribeDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const channelName) {
        ARTRealtimeChannel *const channel = [realtime.channels get: channelName];
        [channel.push subscribeDevice];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName){
        [[rest.channels get:channelName].push subscribeDevice];
        result(nil);
    }
   );
};

static const FlutterHandler _pushUnsubscribeDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName) {
        [[realtime.channels get: channelName].push unsubscribeDevice];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName){
        [[rest.channels get:channelName].push unsubscribeDevice];
        result(nil);
    }
   );
};

static const FlutterHandler _pushSubscribeClient = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName) {
        [[realtime.channels get: channelName].push subscribeClient];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName){
        [[rest.channels get:channelName].push subscribeClient];
        result(nil);
    }
   );
};

static const FlutterHandler _pushUnsubscribeClient = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName) {
        [[realtime.channels get: channelName].push unsubscribeClient];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName){
        [[rest.channels get:channelName].push unsubscribeClient];
        result(nil);
    }
   );
};

typedef void (^ListSubscriptionsOnPushChannelHandler)(NSDictionary *const params,
                                                      ARTPushChannel *const pushChannel,
                                                      NSString *const _Nullable channelName,
                                                      AblyFlutter *const ably,
                                                      const FlutterResult result);
static const ListSubscriptionsOnPushChannelHandler _listSubscriptionsOnPushChannel = ^void(NSDictionary *const params,
                                                                                           ARTPushChannel *const pushChannel,
                                                                                           NSString *const _Nullable channelName,
                                                                                           AblyFlutter *const ably,
                                                                                           const FlutterResult result) {
    // The pushChannel:listSubscription API has 2 ways of returning errors:
    // - If it is a network error or error called in `ARTPaginatedResult:executePaginated`, it provides an error in the callback you provide.
    // - If it is a non-network error, it will mutate the errorPtr you pass in.
    NSError * nsError;
    bool ret = [pushChannel listSubscriptions: params
                          callback: ^void(ARTPaginatedResult<ARTPushChannelSubscription *> *const pushChannelSubscriptionPaginatedResult, ARTErrorInfo * errorInfo) {
        if (errorInfo) {
            result([
                    FlutterError
                    errorWithCode:[NSString stringWithFormat: @"%ld", (long)errorInfo.code]
                    message:[NSString stringWithFormat:@"Error listing subscriptions from push Channel %@; err = %@", channelName, [errorInfo message]]
                    details:errorInfo
                    ]);
            return;
        }
        NSNumber *const paginatedResultHandle = [ably setPaginatedResult:pushChannelSubscriptionPaginatedResult handle:nil];
        result([[AblyFlutterMessage alloc] initWithMessage:pushChannelSubscriptionPaginatedResult handle: paginatedResultHandle]);
    }
                                        error: &nsError];
    if (nsError) {
        result([
                FlutterError
                errorWithCode:[NSString stringWithFormat: @"%ld", (long)nsError.code]
                message:[NSString stringWithFormat:@"Error listing subscriptions from push Channel %@; err = %@", channelName, nsError.localizedDescription]
                details:nil
                ]);
        return;
    }
    
    if (!ret) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"ARTPushChannel.listSubscription could not make the network request for an unknown request"];
    }
};

static const FlutterHandler _pushListSubscriptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutter *const ably = [plugin ably];
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutterMessage *const messageData = message.message;
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSDictionary *const params = (NSDictionary<NSString *, NSString *> *)[_dataMap objectForKey:TxTransportKeys_params];
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName) {
        ARTPushChannel *const pushChannel = [realtime.channels get: channelName].push;
        _listSubscriptionsOnPushChannel(params, pushChannel, channelName, ably, result);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable channelName){
        ARTPushChannel *const pushChannel = [rest.channels get: channelName].push;
        _listSubscriptionsOnPushChannel(params, pushChannel, channelName, ably, result);
    }
   );
};

static const FlutterHandler _pushDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable _) {
        result([realtime device]);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result,
                             NSString *const _Nullable _){
        result([rest device]);
    }
   );
};

@implementation AblyFlutterPlugin {
    long long _nextRegistration;
    NSDictionary<NSString *, FlutterHandler>* _handlers;
    AblyStreamsChannel* _streamsChannel;
    FlutterMethodChannel* _channel;
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
    
    // regustering method channel with registrar
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
        AblyPlatformMethod_pushActivate: _pushActivate,
        AblyPlatformMethod_pushRequestNotificationPermission: _pushRequestNotificationPermission,
        AblyPlatformMethod_pushDeactivate: _pushDeactivate,
        AblyPlatformMethod_pushSubscribeDevice: _pushSubscribeDevice,
        AblyPlatformMethod_pushUnsubscribeDevice: _pushUnsubscribeDevice,
        AblyPlatformMethod_pushSubscribeClient: _pushSubscribeClient,
        AblyPlatformMethod_pushUnsubscribeClient: _pushUnsubscribeClient,
        AblyPlatformMethod_pushListSubscriptions: _pushListSubscriptions,
        AblyPlatformMethod_pushDevice: _pushDevice,
    };
    
    _nextRegistration = 1;
    _channel = channel;
    
    [registrar addApplicationDelegate:self];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(uiApplicationDidFinishLaunchingWithOptionsNotificationHandler:)
               name:UIApplicationDidFinishLaunchingNotification
             object:nil];
    
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

-(void)uiApplicationDidFinishLaunchingWithOptionsNotificationHandler:(nonnull NSNotification *)notification {
    UNUserNotificationCenter *const notificationCenter = UNUserNotificationCenter.currentNotificationCenter;
    notificationCenter.delegate = self;
    
    // Calling registerForRemoteNotifications on didFinishLaunchingWithOptions because it may change between app launches
    // More information at https://stackoverflow.com/questions/29456954/ios-8-remote-notifications-when-should-i-call-registerforremotenotifications
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // By default, only "silent notifications" will be delivered to the device.
    // The user still needs to requestAuthorizationWithOptions to show notifications to the user.
    // See https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications?language=objc
    // and https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649527-requestauthorizationwithoptions?language=objc
}

#pragma mark - Push Notifications Registration - UIApplicationDelegate
/// Save the deviceToken provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // This deviceToken will be used when a new client gets made.
    _didRegisterForRemoteNotificationsWithDeviceToken_deviceToken = deviceToken;
}

/// Save the error if it occurred during APNs device registration provided so we can pass it to the first Ably client which gets created, in createRealtime or createRest.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    _didFailToRegisterForRemoteNotificationsWithError_error = error;
}

// Only called when the app is in the foreground
#pragma mark - Push Notifications - UNUserNotificationCenterDelegate
// https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate?language=objc
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    // Don't show the notification if the app is in the foreground. This is the default behaviour on Android.
    // TODO allow the user to specify the behaviour here on dart side.
    completionHandler(UNNotificationPresentationOptionNone);
}

// Only called when `'content-available' : 1` is set in the push payload
# pragma mark - Push Notifications - FlutterApplicationLifeCycleDelegate (not UIApplicationDelegate)
- (bool)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // TODO Implement Push Notifications listener https://github.com/ably/ably-flutter/issues/141
    // Call a callback in dart side so the user can handle it.
//    bool handled = handleRemoteNotificationOnDartSide(userInfo, completionHandler);
//    if (handled) {
//        return YES;
//    } else {
//        return NO;
//    }
    completionHandler(UIBackgroundFetchResultNewData);
    return NO;
}

#pragma mark - Push Notifications - UNNotificationContentExtension
// From apple docs: The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction
// TODO allow the user to specify the behaviour here on dart side.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    completionHandler();
}

@end
