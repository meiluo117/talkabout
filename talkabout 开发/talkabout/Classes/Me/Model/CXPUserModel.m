//
//  CXPUserModel.m
//  talkabout
//
//  Created by 于波 on 15/12/31.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPUserModel.h"

@implementation CXPUserModel

+ (instancetype) sharedModel{
    
    static CXPUserModel *mannager = nil;
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        
        mannager = [[CXPUserModel alloc]init];
        
    });
    
    return mannager;
}

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

- (void)clear
{
    //  取得当前类类型
    Class cls = [self class];
    
    unsigned int ivarsCnt = 0;
    //　获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如 @property(retain) NSString *abc;则 key == _abc;
        
        //　获取变量值
        id value = [self valueForKey:key];
        
        //　取得变量类型
        // 通过 type[0]可以判断其具体的内置类型
        const char *type = ivar_getTypeEncoding(ivar);
        if (value)
        {
            if (type[0] == 'c'|| type[0] == 'i' || type[0] == 's'|| type[0] == 'l'|| type[0] == 'q'|| type[0] == 'C' || type[0] == 'I'|| type[0] == 'S'|| type[0] == 'L'|| type[0] == 'Q' || type[0] == 'B'|| type[0] == 'f'||type[0] == 'd') {
                value = 0;
                
            }else{
                value = nil;
            }
            //赋值
            object_setIvar(self, ivar, value);
        }
    }
}
@end
