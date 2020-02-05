#import "AblyFlutterSurfaceRealtime.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;
#import "Ably.h"

@implementation AblyFlutterSurfaceRealtime {
    ARTRealtime* _instance;
}

-(instancetype)initWithInstance:(ARTRealtime *)instance {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _instance = instance;
    
    return self;
}

-(void)connect {
    [_instance connect];
}

-(void)close {
    [_instance close];
}

@end
