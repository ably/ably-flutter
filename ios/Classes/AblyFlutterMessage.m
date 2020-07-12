#import "AblyFlutterMessage.h"

@implementation AblyFlutterMessage

@synthesize handle = _handle;
@synthesize message = _message;

-(instancetype)initWithMessage:(const id)message handle:(NSNumber *const)handle  {
    if (!message) {
        [NSException raise:NSInvalidArgumentException format:@"message cannot be nil."];
    }

    self = [super init];
    if (!self) {
        return nil;
    }
    
    _handle = handle;
    _message = message;
    
    return self;
}

@end
