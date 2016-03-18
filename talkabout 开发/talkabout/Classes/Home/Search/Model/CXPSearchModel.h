//
//  CXPSearchModel.h
//  talkabout
//
//  Created by 于波 on 16/1/6.
//  Copyright © 2016年 于波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXPSearchModel : NSObject
/**bpid*/
@property (nonatomic,copy)NSString *bpId;
/**bp名称*/
@property (nonatomic,copy)NSString *bpName;
/**bp下载url*/
@property (nonatomic,copy)NSString *url;
/**文档类型*/
@property (nonatomic,copy)NSString *fileType;
/**bp状态标示*/
@property (nonatomic,copy)NSString *status;
/**bp状态*/
@property (nonatomic,copy)NSString *statusName;
/**bp是否阅读*/
@property (nonatomic,copy)NSString *read;
/**md5*/
@property (nonatomic,copy)NSString *md5;
/**bp备注 评论*/
@property (nonatomic,copy)NSString *comment;
/**bp备注时间 评论时间*/
@property (nonatomic,copy)NSString *updateTime;

+ (instancetype)setupWithDict:(NSDictionary*)dict;
- (instancetype)initWithDict:(NSDictionary*)dict;
@end
