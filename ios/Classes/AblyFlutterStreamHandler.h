@import Foundation;
@import Flutter;
#import "AblyFlutterPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterStreamHandler : NSObject<FlutterStreamHandler>

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithAbly:(AblyFlutterPlugin *const)plugin NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) AblyFlutterPlugin * plugin;

- (nullable FlutterError *)onListenWithArguments:(nullable id)arguments eventSink:(FlutterEventSink)eventSink;
- (nullable FlutterError *)onCancelWithArguments:(nullable id)arguments;
@end

NS_ASSUME_NONNULL_END
