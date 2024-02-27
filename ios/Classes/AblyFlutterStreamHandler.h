@import Foundation;
@import Flutter;
#import "AblyFlutter.h"

@class ARTConnectionStateChange;

NS_ASSUME_NONNULL_BEGIN

@interface _AblyConnectionStateChange : NSObject

@property(nonatomic, readonly) ARTConnectionStateChange *value;
@property(nonatomic, readonly) NSString *connectionId;
@property(nonatomic, readonly) NSString *connectionKey;

- (instancetype)initWithStateChange:(ARTConnectionStateChange *)stateChange connectionId:(NSString *)connectionId connectionKey:(NSString *)connectionKey;

@end

@interface AblyFlutterStreamHandler : NSObject<FlutterStreamHandler>

@property(nonatomic, readonly) AblyInstanceStore * instanceStore;

- (nullable FlutterError *)onListenWithArguments:(nullable id)arguments
                                       eventSink:(FlutterEventSink)eventSink;

- (nullable FlutterError *)onCancelWithArguments:(nullable id)arguments;

@end

NS_ASSUME_NONNULL_END
