//
//  CXPBPFileTypeStatusColor.h
//  talkabout
//
//  Created by 于波 on 15/12/24.
//  Copyright © 2015年 于波. All rights reserved.
//
typedef NS_ENUM(NSInteger,bpStatusType);

#import <Foundation/Foundation.h>

@interface CXPBPFileTypeStatusColor : NSObject

/**bp文件类型*/
+ (UIImage *)bpFileTypeStr:(NSString *)fileTypeStr;
/**bp状态背景色*/
+ (UIImage *)bpStatusColor:(bpStatusType)statusType;
@end
