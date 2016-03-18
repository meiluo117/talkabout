//
//  CXPLoginViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/10.
//  Copyright © 2015年 于波. All rights reserved.

#import "CXPLoginViewController.h"
#import "CXPHomeViewController.h"
#import "CXPVerify.h"
#import "CXPMD5.h"
#import "CXPHttpNetTool.h"
#import <UMSocial.h>
#import <UMSocialSinaSSOHandler.h>
#import <UMSocialSnsService.h>
#import "CXPUserModel.h"
//#import "IQKeyboardManager.h"
#import "CXPRegisterViewController.h"
#import "CXPForgetPwdViewController.h"

@interface CXPLoginViewController ()<UITextFieldDelegate>{
 //   BOOL _wasKeyboardManagerEnabled;
}

- (IBAction)loginBtnClick:(UIButton *)sender;
- (IBAction)wechatLogin:(UIButton *)sender;
- (IBAction)QQLogin:(UIButton *)sender;
- (IBAction)weiboLogin:(UIButton *)sender;
- (IBAction)registerBtnClick:(UIButton *)sender;
- (IBAction)forgetBtnClick:(UIButton *)sender;

@end

@implementation CXPLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
//    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    [self creatUI];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 //    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
}

- (void)creatUI{
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_phone = [userDefaults objectForKey:@"user_phone"];
    if (user_phone.length != 0) {
        self.phoneTextFiled.text = user_phone;
    }
    
    self.phoneTextFiled.delegate  = self;
    self.pwdTextField.delegate    = self;
    self.pwdTextField.secureTextEntry   = YES;
    self.phoneTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTextField.clearButtonMode   = UITextFieldViewModeWhileEditing;
//    if (self.phoneTextFiled.text.length == 0) {
//        [self.phoneTextFiled becomeFirstResponder];
//    }
    
}

/**消除键盘*/
-(void)cancelKeyboard{
    [self.view endEditing:YES];
}

/**
 *  文本框校验
 */
- (BOOL)verifyTextField{
    //检验手机号是否为空
    if([CXPVerify isPobileNumEmpty:self.phoneTextFiled.text]) return NO;
    //检验手机号是否合法
    if(![CXPVerify isPhoneNumAvailability:self.phoneTextFiled.text]) return NO;
    //检验密码位数
    if(![CXPVerify checkLengthOfPassword:self.pwdTextField.text]) return NO;
    
    return YES;
}

/**
 *  点击登陆
 */
- (IBAction)loginBtnClick:(UIButton *)sender {
    if(![self verifyTextField]) return;
    
    [self sendRequest];
}

//注册
- (IBAction)registerBtnClick:(UIButton *)sender {
    CXPRegisterViewController *registerVC = [[CXPRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

//忘记密码
- (IBAction)forgetBtnClick:(UIButton *)sender {
    CXPForgetPwdViewController *forgetPwdVC = [[CXPForgetPwdViewController alloc] init];
    forgetPwdVC.loginController = self;
    [self.navigationController pushViewController:forgetPwdVC animated:YES];
}

#pragma mark - 发送请求
//登陆请求
- (void)sendRequest{
    NSDictionary *params = @{@"password"   :self.pwdTextField.text,
                             @"username"   :self.phoneTextFiled.text,
                             @"source"     :@"1"};
    
    [self loadDataFromNetwork:URL_LOGIN andParams:params];
}
//获取个人信息请求
- (void)sendUserRequest{
    __weak __typeof(self)weakSelf = self;
    NSDictionary *params = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]};
    [weakSelf loadUserDataFromNetwork:URL_BPMe andParams:params];
}

- (void)sendWechatOrQQRequestUrl:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    NSDictionary *dict = @{@"openId"    :params[@"openid"],
                           @"headImg"   :params[@"profile_image_url"],
                           @"name"      :params[@"screen_name"],
                           @"source"    :@"1"};
    [weakSelf loadDataForOtherLogin:url andParams:dict];
}

- (void)sendWeiboRequestUrl:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    NSDictionary *dict = @{@"openId"    :params[@"uid"],
                           @"headImg"   :params[@"profile_image_url"],
                           @"name"      :params[@"screen_name"],
                           @"source"    :@"1"};
    [weakSelf loadDataForOtherLogin:url andParams:dict];
}

#pragma mark - 微信登录
- (IBAction)wechatLogin:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                CXP_LOG(@"微信用户信息:%@",response.data);
                [weakSelf sendWechatOrQQRequestUrl:URL_WECHAT_LOGIN andParams:response.data];
            }];
            
        }
        
    });
    
}
#pragma mark - QQ登录
- (IBAction)QQLogin:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                CXP_LOG(@"qq用户信息:%@",response.data);
                [weakSelf sendWechatOrQQRequestUrl:URL_QQ_LOGIN andParams:response.data];
            }];
        }});
}
#pragma mark - 微博登录
- (IBAction)weiboLogin:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
            NSLog(@"用户名:%@, 用户uid:%@, 用户token:%@ url:%@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            //获取accestoken以及新浪用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                NSLog(@"微博用户信息:%@",response.data);
                [weakSelf sendWeiboRequestUrl:URL_WEIBO_LOGIN andParams:response.data];
            }];
        }});
}

#pragma mark - load数据
- (void)loadUserDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [CXPHttpNetTool post:url params:params success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            [MMProgressHUD dismissWithSuccess:@"登陆成功"];
            NSDictionary *dataDict = json[@"data"];
            [weakSelf savaUserData:dataDict];
            
        }else{
            [MMProgressHUD dismissWithError:@"获取用户信息失败"];
        }
    } failure:^(NSError *error) {
        CXP_LOG(@"获取用户信息错误:%@",error);
        [MMProgressHUD dismissWithError:@"获取用户信息超时"];
    }];
}

- (void)loadDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在登陆"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf savaData:dataDict ];
            
        }else{
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
            weakSelf.pwdTextField.text = @"";
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"登录错误:%@",error);
        [MMProgressHUD dismissWithError:@"登陆超时"];
    }];
    
}

- (void)loadDataForOtherLogin:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在登陆"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"otherLoginInfo:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == 1) {
            NSDictionary *dataDcit = jsonDict[@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDcit[@"token"] forKey:@"user_token"];
            
            [weakSelf sendUserRequest];
        }else{
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"三方登陆错误:%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

#pragma mark - 保存信息
- (void)savaUserData:(id)obj{
    __weak __typeof(self)weakSelf = self;
    CXPUserModel *userModel = [CXPUserModel sharedModel];
    [userModel setValuesForKeysWithDictionary:obj];
    
    CXPHomeViewController * homeVC  = [[CXPHomeViewController alloc] init];
    homeVC.loginController = weakSelf;
    UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

- (void)savaData:(id)obj{
    __weak __typeof(self)weakSelf = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:weakSelf.phoneTextFiled.text forKey:@"user_phone"];
    [userDefaults setObject:weakSelf.pwdTextField.text forKey:@"user_pwd"];
    [userDefaults setObject:obj[@"token"] forKey:@"user_token"];
    [userDefaults synchronize];
    
    [weakSelf sendUserRequest];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (void)dealloc{

}

@end
