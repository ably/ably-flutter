#import "AblyFlutterMessage.h"

@implementation AblyFlutterMessage

@synthesize handle = _handle;
@synthesize message = _message;

-(instancetype)initWithHandle:(NSNumber *const)handle message:(const id)message {
    if (!handle) {
        [NSException raise:NSInvalidArgumentException format:@"handle cannot be nil."];
    }
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
