//
//  AppDelegate.m
//  talkabout
//
//  Created by 于波 on 15/12/7.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "AppDelegate.h"
#import "CXPLoginViewController.h"
#import "CXPHomeViewController.h"
#import "CXPNewFeatureViewController.h"
#import <UMSocial.h>
#import <UMSocialSinaHandler.h>
#import <UMSocialWechatHandler.h>
#import <UMSocialQQHandler.h>
#import "CXPGetFile.h"
#import <Bugtags/Bugtags.h>//bug监测

@interface AppDelegate ()
@property (nonatomic,strong)NSURL *fileUrl;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    WS(weakSelf)
    //注册bugtags
    [Bugtags startWithAppKey:@"0ac732233a1ee2a150d6561aba2fe8a9" invocationEvent:BTGInvocationEventNone];

    //监测app从其他应用调起
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        CXP_LOG(@"第三方应用唤醒");
        
      //  [[NSNotificationCenter defaultCenter] postNotificationName:@"loadData" object:nil];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[CXPLoginViewController alloc] init];//不加这句ios9崩溃
    [self.window makeKeyAndVisible];
    
    //判断新特性
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVerson     = [appDefaults stringForKey:@"CFBundleVersion"];//过去版本
    NSString *currentVerson  = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];//现在版本
    
    if([lastVerson isEqualToString:currentVerson])
    {
        //没有新版本
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *userPhone = [defaults objectForKey:@"user_phone"];
//        NSString *userPwd   = [defaults objectForKey:@"user_pwd"];
        NSString *userToken = [defaults objectForKey:@"user_token"];
    
        if (nil == userToken) {
            //没登陆过 进行登陆
            CXPLoginViewController *loginVC = [[CXPLoginViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
            
        }else{
            //之前登陆过 获取个人信息 再登陆
            [weakSelf sendUserRequest];
        }
        
    }else{
        //有新版本 跳转新特性页面
        [appDefaults setObject:currentVerson forKey:@"CFBundleVersion"];
        [appDefaults synchronize];
        [UIApplication sharedApplication].keyWindow.rootViewController = [[CXPNewFeatureViewController alloc] init];
    }
    
    [self shared];//注册分享
    
    return YES;
}

#pragma mark - 发送请求
//登陆请求
- (void)sendLoginRequest{
    WS(weakSelf)
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSString *user_phone        = [defaults objectForKey:@"user_phone"];
    NSString *user_pwd          = [defaults objectForKey:@"user_pwd"];
    
    NSDictionary *params = @{@"password"    :user_pwd,
                             @"username"    :user_phone,
                             @"source"      :@"1"};
    
    [weakSelf loadDataFromNetwork:URL_LOGIN andParams:params];
}
//获取用户信息请求
- (void)sendUserRequest{
    WS(weakSelf)
    NSDictionary *params = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]};
    
    [weakSelf loadUserInfoDataFromNetwork:URL_BPMe andParams:params];
}

#pragma mark - loadData
- (void)loadDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    WS(weakSelf)
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在登陆"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"自动登陆成功");
            //登陆成功 请求用户信息存储model
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveToken:dataDict];
            [weakSelf sendUserRequest];
            
        }else{
            CXP_LOG(@"自动登陆失败");
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
            //用户名或密码错误 跳转到登录页面重新登录
            CXPLoginViewController *loginVC = [[CXPLoginViewController alloc] init];
            UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"自动登陆错误%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

- (void)loadUserInfoDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    WS(weakSelf)
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"获取用户信息成功");
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveUserInfo:dataDict];
            
        }else{
            CXP_LOG(@"获取用户信息失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"获取用户信息错误:%@",error);
    }];
}

#pragma mark - 保存信息
- (void)saveToken:(id)obj{
    [[NSUserDefaults standardUserDefaults] setObject:obj[@"token"] forKey:@"user_token"];
}
//存储用户信息
- (void)saveUserInfo:(id)obj{
    CXPUserModel *userModel = [CXPUserModel sharedModel];
    [userModel setValuesForKeysWithDictionary:obj];
    
    [MMProgressHUD dismiss];
    CXPHomeViewController * homeVC  = [[CXPHomeViewController alloc] init];
    UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

#pragma mark - shared
- (void)shared{
    //友盟分享
    [UMSocialData setAppKey:umengAppKey];
    //微博
    [UMSocialSinaHandler openSSOWithRedirectURL:WeiboSSO];
    //QQ
    [UMSocialQQHandler setQQWithAppId:QQWithAppId appKey:QQWithAppKey url:QQWithUrl];
    //微信
    [UMSocialWechatHandler setWXAppId:WXAppId appSecret:WXAppSecret url:WXWithUrl];
}

#pragma mark - 第三方应用打开
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        
        if (url != nil) {
            self.fileUrl = url;
            NSString *filepath = [url absoluteString];//文件路径
            CXP_LOG(@"导入文件路径:%@",filepath);

            NSString *fileName = [url lastPathComponent];//文件名称
            CXP_LOG(@"导入文件名称:%@",fileName);

            CXPHomeViewController *homeVC   = [[CXPHomeViewController alloc] init];
            homeVC.filePath                 = filepath;
            homeVC.fileName                 = fileName;
            
            UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:homeVC];
            self.window.rootViewController  = nav;
            [homeVC openFile:filepath];
        }
    }
    return YES;
}


@end
