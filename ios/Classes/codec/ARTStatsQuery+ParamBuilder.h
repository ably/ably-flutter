//
// Created by Ikbal Kaya on 23/12/2021.
//

#import <Foundation/Foundation.h>
#import "ARTStats.h"

@interface ARTStatsQuery (ParamBuilder)

+(ARTStatsQuery *)fromParams:(NSDictionary *)params;

@end