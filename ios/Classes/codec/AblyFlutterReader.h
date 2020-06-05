@import Foundation;
@import Flutter;
#import "ARTTokenDetails.h"
#import "ARTTokenParams.h"


NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterReader : FlutterStandardReader

+(ARTTokenDetails *)tokenDetailsFromDictionary: (NSDictionary *) dictionary;
+(ARTTokenParams *)tokenParamsFromDictionary: (NSDictionary *) dictionary;

@end

NS_ASSUME_NONNULL_END
