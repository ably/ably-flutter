#import "ARTClientOptions+AblyFlutterClientOptions.h"
#import <objc/runtime.h>

@implementation ARTClientOptions (AblyFlutterClientOptions)

- (void) setHasAuthCallback:(BOOL) value {
    NSNumber *number = [NSNumber numberWithBool: value];
    objc_setAssociatedObject(self, @selector(hasAuthCallback), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) hasAuthCallback {
    NSNumber *number = objc_getAssociatedObject(self, @selector(hasAuthCallback));
    return [number boolValue];
}

@end
