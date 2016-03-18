//
//  CXPSearchModel.m
//  talkabout
//
//  Created by 于波 on 16/1/6.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPSearchModel.h"

@implementation CXPSearchModel

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

@end
