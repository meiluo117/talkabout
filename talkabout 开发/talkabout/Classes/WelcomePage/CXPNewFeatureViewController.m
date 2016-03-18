//
//  CXPNewFeatureViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/28.
//  Copyright © 2015年 于波. All rights reserved.
//

//引导页数
#define CXP_NewfeatureImageCount 3
//btn坐标
#define btnW 150.0f
#define btnH 40.0f
#define btnX (ScreenWidth-btnW)/2
#define btnY ScreenHeight-150

#import "CXPNewFeatureViewController.h"
#import "CXPHomeViewController.h"
#import "CXPLoginViewController.h"
#import "CXPUserModel.h"

@interface CXPNewFeatureViewController ()<UIScrollViewDelegate>
@property (nonatomic, weak, readwrite) UIPageControl *pageControll;
@end

@implementation CXPNewFeatureViewController

//隐藏电量那行
- (BOOL)prefersStatusBarHidden{return YES;}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupPageControl];
}

- (void)setupScrollView
{
    //在scrollView后面添加一个背景色
    self.view.backgroundColor = kColor(246, 246, 246, 1);
    
    UIScrollView *scrollView  = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    for(int i = 0; i< CXP_NewfeatureImageCount; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        NSString *imageName;
        imageName              = [NSString stringWithFormat:@"welcomePage_%d.png", i + 1];
        imageView.image        = [UIImage imageNamed:imageName];
        imageView.frame        = CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight);
        
        [scrollView addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        if (2 == i) {
            UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [goBtn setImage:[UIImage imageNamed:@"experienceBtn"] forState:UIControlStateNormal];
            goBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            goBtn.tag = 111;
            [goBtn addTarget:self action:@selector(goBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:goBtn];
        }
    }
    scrollView.pagingEnabled = YES;
    scrollView.contentSize   = CGSizeMake(CXP_NewfeatureImageCount * ScreenWidth, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.delegate = self;
}

- (void)goBtnClick:(UIButton *)btn{
    [self btnEnabled:NO];
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSString *userphone         = [defaults objectForKey:@"user_phone"];
    NSString *userpwd           = [defaults objectForKey:@"user_pwd"];
    NSString *userToken         = [defaults objectForKey:@"user_token"];
    
    if (nil == userToken) {
        //没登陆过 进行登陆
        [self btnEnabled:YES];
        CXPLoginViewController *loginVC = [[CXPLoginViewController alloc] init];
        UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    }else{
        //之前登陆过 直接登陆
        [self sendUserRequest];
    }
}

- (void)setupPageControl
{
    //添加进度圆点
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages  = CXP_NewfeatureImageCount;
    CGFloat centerX            = ScreenWidth * 0.5;
    CGFloat centerY            = ScreenHeight - 30;
    pageControl.center         = CGPointMake(centerX, centerY);
    pageControl.bounds         = CGRectMake(0, 0, 100, 30);
    
    pageControl.currentPageIndicatorTintColor = kColor(253, 98, 42, 1);
    pageControl.pageIndicatorTintColor        = kColor(189, 189, 189, 1);
    pageControl.userInteractionEnabled = NO;
    _pageControll = pageControl;
    [self.view addSubview:pageControl];
}

#pragma mark - ScrollView代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    __weak __typeof(self)weakSelf = self;
    double page = scrollView.contentOffset.x / ScreenWidth;
    self.pageControll.currentPage = round(page);  //使用round实现四舍五入
    if (page > (CXP_NewfeatureImageCount -1) + 0.1) {
//        //判断是否以前登录过
//        NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
//        NSString *userphone         = [defaults objectForKey:@"user_phone"];
//        NSString *userpwd           = [defaults objectForKey:@"user_pwd"];
//        
//        if (nil == userphone || nil == userpwd) {
//            //没登陆过 进行登陆
//            CXPLoginViewController *loginVC = [[CXPLoginViewController alloc] init];
//            UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginVC];
//            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
//        }else{
//            //之前登陆过 直接登陆
//            [weakSelf sendLoginRequest];
//        }
    }
}

#pragma mark - 发送请求
- (void)sendLoginRequest{
    __weak __typeof(self)weakSelf = self;
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSString *user_phone         = [defaults objectForKey:@"user_phone"];
    NSString *user_pwd           = [defaults objectForKey:@"user_pwd"];
    
    NSDictionary *params = @{@"password"   :user_pwd,
                             @"username"   :user_phone,
                             @"source"     :@"1"};
    
    [weakSelf loadDataFromNetwork:URL_LOGIN andParams:params];
}

//获取用户信息请求
- (void)sendUserRequest{
    WS(weakSelf);
    NSDictionary *params = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]};
    
    [weakSelf loadUserInfoDataFromNetwork:URL_BPMe andParams:params];
}

#pragma mark - loadData
- (void)loadDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveUserToekn:dataDict];
            [weakSelf sendUserRequest];
            
        }else{
            //用户名或密码错误 跳转到登录页面重新登录
            [weakSelf btnEnabled:YES];
            [weakSelf goLogin];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"请求超时");
        [weakSelf btnEnabled:YES];
        [weakSelf goLogin];
    }];
}

- (void)loadUserInfoDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    WS(weakSelf);
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"获取用户信息成功");
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveUserInfo:dataDict];
            
        }else{
            CXP_LOG(@"获取用户信息失败");
            [weakSelf btnEnabled:YES];
            [weakSelf goLogin];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"获取用户信息错误:%@",error);
        [weakSelf btnEnabled:YES];
        [weakSelf goLogin];
    }];
}

#pragma mark - 存储信息
- (void)saveUserToekn:(id)obj{
    [[NSUserDefaults standardUserDefaults] setObject:obj[@"token"] forKey:@"user_token"];
}

//存储用户信息
- (void)saveUserInfo:(id)obj{
    __weak __typeof(self)weakSelf = self;
    CXPUserModel *userModel = [CXPUserModel sharedModel];
    [userModel setValuesForKeysWithDictionary:obj];
    
    [MMProgressHUD dismiss];
    [weakSelf btnEnabled:YES];
    CXPHomeViewController * homeVC  = [[CXPHomeViewController alloc] init];
    UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

- (void)btnEnabled:(BOOL)isEnabled{
    UIButton *btn = (UIButton *)[self.view viewWithTag:111];
    if (isEnabled) {
        btn.enabled = YES;
    }else{
        btn.enabled = NO;
    }
}

- (void)goLogin{
    CXPLoginViewController *loginVC = [[CXPLoginViewController alloc] init];
    UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

@end
