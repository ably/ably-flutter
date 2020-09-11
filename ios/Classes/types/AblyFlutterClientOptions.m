//
//  AblyFlutterClientOptions.m
//  Ably
//
//  Created by Rohit R. Abbadi on 11/09/20.
//

#import "AblyFlutterClientOptions.h"


@implementation AblyFlutterClientOptions

@synthesize clientOptions = _clientOptions;
@synthesize hasAuthCallback = _hasAuthCallback;

-(instancetype)initWithClientOptions:(ARTClientOptions *)clientOptions
                     hasAuthCallback:(BOOL)hasAuthCallback {

    self = [super init];
    if (!self) {
        return nil;
    }
    
    _clientOptions = clientOptions;
    _hasAuthCallback = hasAuthCallback;
    
    return self;
}

@end
