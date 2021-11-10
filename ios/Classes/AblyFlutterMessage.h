@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterMessage : NSObject

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithMessage:(id)message
                        handle:(NSNumber *)handle NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) NSNumber * handle;
@property(nonatomic, readonly) id message;

@end

NS_ASSUME_NONNULL_END
