//
//  CXPAPPMessageViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/21.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPAPPMessageViewController.h"
#import "CXPNavItemBtn.h"
@interface CXPAPPMessageViewController ()

@end

@implementation CXPAPPMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
  //  self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"关于本软件";
    
    UIButton *lbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"返回" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [lbuttn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lbuttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
}

//取消按钮
- (void)cancelBtnClick:(UIButton *)cancelBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
