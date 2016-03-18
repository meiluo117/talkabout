//
//  CXPLoginViewController.h
//  talkabout
//
//  Created by 于波 on 15/12/10.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXPLoginViewController : UIViewController

@property (copy,nonatomic)NSString *userTokenStr;
/**手机号*/
@property (weak, nonatomic) IBOutlet UITextField *phoneTextFiled;
/**密码*/
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@end
