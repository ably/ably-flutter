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


@implementation AblyFlutterEventMessage

@synthesize eventName = _eventName;
@synthesize message = _message;

-(instancetype)initWithEventName:(NSString *const)eventName message:(const id)message {
    if (!eventName) {
        [NSException raise:NSInvalidArgumentException format:@"eventName cannot be nil."];
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _eventName = eventName;
    _message = message;

    return self;
}

@end
