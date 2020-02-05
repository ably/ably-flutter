@import Foundation;

@class ARTRealtime;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterSurfaceRealtime : NSObject

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithInstance:(ARTRealtime *)realtime;

-(void)connect;

-(void)close;

@end

NS_ASSUME_NONNULL_END
