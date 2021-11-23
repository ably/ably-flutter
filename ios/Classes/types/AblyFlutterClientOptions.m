#import "AblyFlutterClientOptions.h"


@implementation AblyFlutterClientOptions

@synthesize clientOptions = _clientOptions;
@synthesize hasAuthCallback = _hasAuthCallback;

-(instancetype)initWithClientOptions:(ARTClientOptions *)clientOptions
                     hasAuthCallback:(id)hasAuthCallback {

    self = [super init];
    if (!self) {
        return nil;
    }

    _clientOptions = clientOptions;
    _hasAuthCallback = [((NSNumber *)hasAuthCallback) boolValue];
    
    return self;
}

@end
