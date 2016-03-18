//
//  CXPExplainViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/4.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPExplainViewController.h"

@interface CXPExplainViewController ()<UIWebViewDelegate>{
    UIActivityIndicatorView *_activityIndicator;
    UIWebView *_webV;
}

@end

@implementation CXPExplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    CGFloat topHeight = 64;
    UIView *topView   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, topHeight)];
    topView.backgroundColor = kColor(245, 245, 245, 1);
    [self.view addSubview:topView];
    
    CGFloat titleLableW = 100;
    CGFloat titleLableH = 44;
    CGFloat titleLableX = (ScreenWidth - titleLableW) / 2;
    CGFloat titleLableY = 20;
    UILabel *topTitleLable          = [[UILabel alloc] initWithFrame:CGRectMake(titleLableX, titleLableY, titleLableW, titleLableH)];
    topTitleLable.text              = self.explainTitle;
    topTitleLable.backgroundColor   = kColor(245, 245, 245, 1);
    topTitleLable.textColor         = [UIColor blackColor];
    topTitleLable.textAlignment     = NSTextAlignmentCenter;
    topTitleLable.font              = [UIFont systemFontOfSize:16];
    [topView addSubview:topTitleLable];
    
    CGFloat btnX = 20;
    CGFloat btnY = 33;
    CGFloat btnW = 12;
    CGFloat btnH = 20;
    UIButton *leftBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame       = CGRectMake(btnX, btnY, btnW, btnH);
    [leftBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    
    _webV = [[UIWebView alloc]initWithFrame:CGRectMake(0, topHeight, ScreenWidth, ScreenHeight - topHeight)];
    _webV.scrollView.bounces = NO;
    _webV.delegate           = self;
    [self.view addSubview:_webV];
    [_webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.explainStr]]];
}

- (void)back:(UIButton *)btn{
    _webV.delegate = nil;
    [_webV removeFromSuperview];
    
    [_activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UIWebViewDelegate代理方法
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_activityIndicator setCenter:view.center];
    [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [_activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}

@end
