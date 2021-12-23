//
// Created by Ikbal Kaya on 23/12/2021.
//

#import "ARTStatsQuery+ParamBuilder.h"
#import "ARTNSDate+ARTUtil.h"


@implementation ARTStatsQuery (ParamBuilder)
+ (ARTStatsQuery *)fromParams:(NSDictionary *)params {
    ARTStatsQuery *query = [[ARTStatsQuery alloc] init];
    id start = params[@"start"];
    if(start && [start isKindOfClass:[NSNumber class]]){
        query.start = [NSDate artDateFromIntegerMs:[start longLongValue]];
    }
    id end = params[@"end"];
    if(end && [end isKindOfClass:[NSNumber class]]){
        query.end = [NSDate artDateFromIntegerMs:[end longLongValue]];
    }
    id direction = params[@"direction"];
    if(direction && [direction isKindOfClass:[NSString class]]){
        NSString *directionString = [direction stringValue];
        query.direction = [directionString isEqualToString:@"backwards"] ? ARTQueryDirectionBackwards : ARTQueryDirectionForwards;
    }
    id limit = params[@"limit"];
    if(limit && [limit isKindOfClass:[NSNumber class]]){
        query.limit = (uint16_t) [limit unsignedIntValue];
    }

    id unit = params[@"unit"];
    if(unit && [unit isKindOfClass:[NSString class]]){
        NSString *unitVal = [unit stringValue];
        // minute, hour, day or month,
        if ([unitVal isEqualToString:@"minute"]){
            query.unit = ARTStatsGranularityMinute;
        }else  if ([unitVal isEqualToString:@"hour"]){
            query.unit = ARTStatsGranularityHour;
        }else  if ([unitVal isEqualToString:@"day"]){
            query.unit = ARTStatsGranularityDay;
        }else  if ([unitVal isEqualToString:@"month"]){
            query.unit = ARTStatsGranularityMonth;
        }
    }
    return query;
}

@end