//
//  CXPBPReadWebViewController.h
//  talkabout
//
//  Created by 于波 on 15/12/24.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXPBPReadWebViewController : UIViewController

/**bp下载地址*/
@property (copy,nonatomic)NSString *bpReadUrl;
/**bp文档类型*/
@property (copy,nonatomic)NSString *bpfileTypeStr;
/**bp名称*/
@property (copy,nonatomic)NSString *bpNameStr;
/**bpmd5*/
@property (copy,nonatomic)NSString *bpmd5;

@end
