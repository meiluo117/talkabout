//
//  CXPSystemTime.m
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPSystemTime.h"

@implementation CXPSystemTime

+ (NSString *)getSystemTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   // [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTimeStr = [formatter stringFromDate:[NSDate date]];
    return dateTimeStr;
}

+ (NSString *)getSystemTimeNoHour{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTimeStr = [formatter stringFromDate:[NSDate date]];
    return dateTimeStr;
}

@end
