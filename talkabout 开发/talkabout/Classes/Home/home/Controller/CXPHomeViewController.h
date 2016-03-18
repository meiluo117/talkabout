//
//  CXPHomeViewController.h
//  talkabout
//
//  Created by 于波 on 15/12/15.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXPHomeViewController : UIViewController

@property (weak,nonatomic)UIViewController *loginController;
/**bp文件路径*/
@property (copy,nonatomic)NSString *filePath;
/**bp文件名字*/
@property (copy,nonatomic)NSString *fileName;
/**第三方应用打开传入路径*/
- (void)openFile:(NSString *)string;

@end
