#import <Flutter/Flutter.h>
#import "AblyFlutter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterPlugin : NSObject<FlutterPlugin>

+(instancetype)new NS_UNAVAILABLE;
+(instancetype)init NS_UNAVAILABLE;

- (AblyFlutter *)ablyWithHandle:(NSNumber *)handle;

@end

NS_ASSUME_NONNULL_END
