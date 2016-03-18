//
//  CXPSetNameViewController.h
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXPSetNameViewController : UIViewController
@property (copy,nonatomic) void(^messageCallBack)(NSString *msg);
@property (copy,nonatomic)NSString *nameStr;
@end
