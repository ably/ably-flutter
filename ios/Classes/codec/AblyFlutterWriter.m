#import "AblyFlutterWriter.h"
#import "Ably.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutterReader.h"


@implementation AblyFlutterWriter

- (void)writeValue:(id)value {
    if([value isKindOfClass:[ARTErrorInfo class]]){
        [self writeByte:_ValueErrorInfo];
        [self writeErrorInfo: value];
        return;
    }
    
    [super writeValue:value];
}

- (void) writeErrorInfo:(ARTErrorInfo *const) e{
    [self writeValue: nil];    //code - not available in ably-cocoa
    [self writeValue: [e message]];
    [self writeValue: @([e statusCode])];
    [self writeValue: nil]; //href - not available in ably-cocoa
    [self writeValue: nil]; //requestId - not available in ably-java
    [self writeValue: nil]; //cause - not available in ably-java
}

@end
