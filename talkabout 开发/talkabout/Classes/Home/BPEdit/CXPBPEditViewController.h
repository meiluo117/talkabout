//
//  CXPBPEditViewController.h
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//
typedef struct {
    __unsafe_unretained NSString *bpStatus;
    __unsafe_unretained NSString *bpName;
    __unsafe_unretained NSString *bpEditTime;
    __unsafe_unretained NSString *bpStatusColor;
} bpChangeInfo;

#import <UIKit/UIKit.h>

@interface CXPBPEditViewController : UIViewController
/**bp名称*/
@property (copy, nonatomic)NSString *bpNameStr;
/**bp状态*/
@property (copy, nonatomic)NSString *bpStateStr;
/**bpId*/
@property (copy,nonatomic)NSString *bpid;

@property (copy,nonatomic) void (^bpInfosCallBack)(bpChangeInfo bp);

@end
