#import "AblyFlutterReaderWriter.h"
#import "AblyFlutterReader.h"
#import "AblyFlutterWriter.h"

@implementation AblyFlutterReaderWriter

-(FlutterStandardReader *)readerWithData:(NSData *const)data {
    return [[AblyFlutterReader alloc] initWithData:data];
}

- (FlutterStandardWriter*)writerWithData:(NSMutableData*)data {
    return [[AblyFlutterWriter alloc] initWithData:data];
}

@end
