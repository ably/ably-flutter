#import "AblyFlutterReaderWriter.h"
#import "AblyFlutterReader.h"

@implementation AblyFlutterReaderWriter

-(FlutterStandardReader *)readerWithData:(NSData *const)data {
    return [[AblyFlutterReader alloc] initWithData:data];
}

@end
