@import Foundation;
@import Flutter;
#import "AblyFlutter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterStreamHandler : NSObject<FlutterStreamHandler>

@property(nonatomic, readonly) AblyInstanceStore * instanceStore;

- (nullable FlutterError *)onListenWithArguments:(nullable id)arguments
                                       eventSink:(FlutterEventSink)eventSink;

- (nullable FlutterError *)onCancelWithArguments:(nullable id)arguments;

@end

NS_ASSUME_NONNULL_END
