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


@interface AblyFlutterEventMessage : NSObject

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithEventName:(NSString *)eventName
                         message:(id)message NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) NSString * eventName;
@property(nonatomic, readonly) id message;

@end

NS_ASSUME_NONNULL_END
