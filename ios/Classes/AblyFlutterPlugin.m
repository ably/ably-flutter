#import "AblyFlutterPlugin.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;
#import "Ably.h"

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
    result([ably createRestWithOptions:message.message]);
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
    result([ably createRealtimeWithOptions:message.message]);
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

typedef ARTPush* (^GetPushFromAblyClientHandler)(AblyFlutter *const ably, FlutterMethodCall *const call);
static const GetPushFromAblyClientHandler _getPushFromAblyClientHandle = ^ARTPush*(AblyFlutter const* ably, FlutterMethodCall *const call) {
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

//typedef void (^FlutterHandler)(AblyFlutterPlugin * plugin, FlutterMethodCall * call, FlutterResult result);
typedef void (^RealtimeClientHandler)(ARTRealtime *const realtime,
                                      FlutterMethodCall *const call,
                                      const FlutterResult result);
typedef void (^RestClientHandler)(ARTRest *const realtime,
                                  FlutterMethodCall *const call,
                                  const FlutterResult result);
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
    if ([message.message class] == [AblyFlutterMessage class]) {
        AblyFlutterMessage *const messageData = message.message;
        clientHandle = messageData.handle;
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
        realtimeClientHandler(realtime, call, result);
        return;
    } else if (rest != nil) {
        restClientHandler(rest, call, result);
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

static const FlutterHandler _pushDeactivate = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    ARTPush *const push = _getPushFromAblyClientHandle([plugin ably], call);
    [push deactivate];
    result(nil);
};

static const FlutterHandler _pushSubscribeDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    NSString *const channelName = message.message;
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        [[realtime.channels get: channelName].push subscribeDevice];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
        [[rest.channels get:channelName].push subscribeDevice];
        result(nil);
    }
   );
};

static const FlutterHandler _pushUnsubscribeDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    NSString *const channelName = message.message;
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        [[realtime.channels get: channelName].push unsubscribeDevice];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
        [[rest.channels get:channelName].push unsubscribeDevice];
        result(nil);
    }
   );
};

static const FlutterHandler _pushSubscribeClient = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    NSString *const channelName = message.message;
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        [[realtime.channels get: channelName].push subscribeClient];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
        [[rest.channels get:channelName].push subscribeClient];
        result(nil);
    }
   );
};

static const FlutterHandler _pushUnsubscribeClient = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    NSString *const channelName = message.message;
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        [[realtime.channels get: channelName].push unsubscribeClient];
        result(nil);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
        [[rest.channels get:channelName].push unsubscribeClient];
        result(nil);
    }
   );
};

static const FlutterHandler _pushListSubscriptions = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    AblyFlutterMessage *const messageData = message.message;
    
    NSMutableDictionary<NSString *, NSObject *> *const _dataMap = messageData.message;
    NSString *const channelName = (NSString*)[_dataMap objectForKey:TxTransportKeys_channelName];
    NSDictionary *const params = (NSDictionary<NSString *, NSString *> *)[_dataMap objectForKey:TxTransportKeys_params];
    
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        ARTPushChannel *const pushChannel = [realtime.channels get: channelName].push;
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
            result(pushChannelSubscriptionPaginatedResult);
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
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
// TODO call the rest version of above
    }
   );

};

static const FlutterHandler _pushDevice = ^void(AblyFlutterPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    _ablyClientReceiver(plugin, call, result,
                       ^void(ARTRealtime *const realtime,
                             FlutterMethodCall *const call,
                             const FlutterResult result) {
        result([realtime device]);
    },
                       ^void(ARTRest *const rest,
                             FlutterMethodCall *const call,
                             const FlutterResult result){
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
    AblyFlutterPlugin *const plugin = [[AblyFlutterPlugin alloc] initWithChannel:channel streamsChannel: streamsChannel];
    
    // regustering method channel with registrar
    [registrar addMethodCallDelegate:plugin channel:channel];
    
    // setting up stream handler factory for eventChannel to handle multiple listeners
    [streamsChannel setStreamHandlerFactory:^NSObject<FlutterStreamHandler> *(id arguments) {
        return [AblyFlutterStreamHandler new];
    }];
    
}

-(instancetype)initWithChannel:(FlutterMethodChannel *const)channel streamsChannel:(AblyStreamsChannel *const)streamsChannel {
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

@end
