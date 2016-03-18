//
//  CXPHomeBPModel.m
//  talkabout
//
//  Created by 于波 on 15/12/24.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPHomeBPModel.h"

@implementation CXPHomeBPModel

+ (instancetype)setupWithDict:(NSDictionary *)dict{
    
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+ (instancetype) sharedModel{
    
    static CXPHomeBPModel *mannager = nil;
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        
        mannager = [[CXPHomeBPModel alloc]init];
        
    });
    
    return mannager;
}
@end
