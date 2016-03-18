//
//  CXPServiceTermsViewController.m
//  talkabout
//
//  Created by 于波 on 16/2/16.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPServiceTermsViewController.h"
#import "CXPNavItemBtn.h"

@interface CXPServiceTermsViewController ()

@end

@implementation CXPServiceTermsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    UIButton *lbuttn                        = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [lbuttn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lbuttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    self.navigationItem.title = @"服务条款";
    self.view.backgroundColor = kColor(239, 239, 239, 1);
    
    UIWebView *serviceWeb = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"serviceTerms" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [serviceWeb loadRequest:request];
    serviceWeb.scrollView.bounces = NO;
    [self.view addSubview:serviceWeb];
}

- (void)cancelBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
