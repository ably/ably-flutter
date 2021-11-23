@import Ably;


NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterClientOptions : NSObject

-(instancetype)initWithClientOptions:(ARTClientOptions *)clientOptions
                     hasAuthCallback:(id)hasAuthCallback NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) ARTClientOptions* clientOptions;
@property (nonatomic, readonly) BOOL hasAuthCallback;

@end

NS_ASSUME_NONNULL_END
