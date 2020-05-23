@import Foundation;
@import Flutter;
#import "ARTTokenDetails.h"
#import "ARTTokenParams.h"


NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterReader : FlutterStandardReader

+(ARTTokenDetails *)readTokenDetails: (NSDictionary *) jsonDict;
+(ARTTokenParams *)readTokenParams: (NSDictionary *) jsonDict;

@end

NS_ASSUME_NONNULL_END
