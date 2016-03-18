//
//  CXPUserModel.h
//  talkabout
//
//  Created by 于波 on 15/12/31.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXPUserModel : NSObject
/**用户唯一token*/
@property (nonatomic,copy) NSString *userToken;

/**用户id*/
@property (nonatomic,copy) NSString *userId;

/**用户姓名*/
@property (nonatomic,copy) NSString *name;

/**用户头像*/
@property (nonatomic,copy) NSString *logo;

/**用户公司*/
@property (nonatomic,copy) NSString *company;

/**用户职位*/
@property (nonatomic,copy) NSString *position;

/**用户手机号*/
@property (nonatomic,copy) NSString *mobile;

/**用户微信号*/
@property (nonatomic,copy) NSString *wechat;

/**用户名片*/
@property (nonatomic,copy) NSString *card;

+ (instancetype)sharedModel;

- (void)clear;

+ (instancetype)setupWithDict:(NSDictionary*)dict;
- (instancetype)initWithDict:(NSDictionary*)dict;


@end
