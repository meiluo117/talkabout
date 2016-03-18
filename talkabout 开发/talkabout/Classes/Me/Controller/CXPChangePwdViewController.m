//
//  CXPChangePwdViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/21.
//  Copyright © 2015年 于波. All rights reserved.
//
//左侧空白
#define LEFT_SPACE 20

#import "CXPChangePwdViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPVerify.h"

@interface CXPChangePwdViewController ()<UITextFieldDelegate>

@end

@implementation CXPChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"修改密码";
    
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    UIButton *lbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"取消" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [lbuttn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lbuttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    UIButton *rbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"保存" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [rbuttn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rbuttn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    
    UILabel *beforePwdL     = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_SPACE, 84, ScreenHeight, 20)];
    beforePwdL.font         = [UIFont systemFontOfSize:12];
    beforePwdL.text         = @"现有密码";
    beforePwdL.textColor    = kColor(130, 130, 130, 1);
    [self.view addSubview:beforePwdL];
    
    UIView *beforePwdView         = [[UIView alloc]initWithFrame:CGRectMake(0, 104, ScreenHeight, 44)];
    beforePwdView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:beforePwdView];
    self.beforePwdF                    = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_SPACE, 0, ScreenHeight - (LEFT_SPACE*3), 44)];
    self.beforePwdF.placeholder        = @"请输入现有密码";
    self.beforePwdF.font               = [UIFont systemFontOfSize:17];
    self.beforePwdF.clearButtonMode    = UITextFieldViewModeAlways;
    self.beforePwdF.keyboardType       = UIKeyboardTypeDefault;
    self.beforePwdF.borderStyle        = UITextBorderStyleNone;
    self.beforePwdF.secureTextEntry    = YES;
    self.beforePwdF.delegate           = self;
    [beforePwdView addSubview:self.beforePwdF];
    
    //
    UILabel *pwdL     = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_SPACE, 164, ScreenHeight, 20)];
    pwdL.font         = [UIFont systemFontOfSize:12];
    pwdL.text         = @"新密码";
    pwdL.textColor    = kColor(130, 130, 130, 1);
    [self.view addSubview:pwdL];
    
    UIView *pwdView         = [[UIView alloc]initWithFrame:CGRectMake(0, 184, ScreenHeight, 44)];
    pwdView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdView];
    self.pwdF                    = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_SPACE, 0, ScreenHeight - (LEFT_SPACE*3), 44)];
    self.pwdF.placeholder        = @"请输入新密码";
    self.pwdF.font               = [UIFont systemFontOfSize:17];
    self.pwdF.clearButtonMode    = UITextFieldViewModeAlways;
    self.pwdF.keyboardType       = UIKeyboardTypeDefault;
    self.pwdF.borderStyle        = UITextBorderStyleNone;
    self.pwdF.secureTextEntry    = YES;
    self.pwdF.delegate           = self;
    [pwdView addSubview:self.pwdF];
    
    //
    UILabel *pwdOnceL     = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_SPACE, 244, ScreenHeight, 20)];
    pwdOnceL.font         = [UIFont systemFontOfSize:12];
    pwdOnceL.text         = @"确认密码";
    pwdOnceL.textColor    = kColor(130, 130, 130, 1);
    [self.view addSubview:pwdOnceL];
    
    UIView *pwdOnceView         = [[UIView alloc]initWithFrame:CGRectMake(0, 264, ScreenHeight, 44)];
    pwdOnceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pwdOnceView];
    self.pwdOnceF                    = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_SPACE, 0, ScreenHeight - (LEFT_SPACE*3), 44)];
    self.pwdOnceF.placeholder        = @"请确认新密码";
    self.pwdOnceF.font               = [UIFont systemFontOfSize:17];
    self.pwdOnceF.clearButtonMode    = UITextFieldViewModeAlways;
    self.pwdOnceF.keyboardType       = UIKeyboardTypeDefault;
    self.pwdOnceF.borderStyle        = UITextBorderStyleNone;
    self.pwdOnceF.secureTextEntry    = YES;
    self.pwdOnceF.delegate           = self;
    [pwdOnceView addSubview:self.pwdOnceF];
}

//消除键盘
-(void)cancelKeyboard{
    [self.view endEditing:YES];
}

//取消按钮
- (void)cancelBtnClick:(UIButton *)cancelBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

//保存按钮
- (void)saveBtnClick:(UIButton *)saveBtn{
    __weak __typeof(self)weakSelf = self;
    
    if (![self verification]) return;
    
    [self sendRequest];
}

- (void)sendRequest{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"];
    NSDictionary *params = @{@"token"       :token,
                             @"passWord"    :self.beforePwdF.text,
                             @"newPwd"      :self.pwdF.text};
    [self loadDataFromNetwork:URL_CHANGE_PASSWORD andParams:params];
}

- (void)loadDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在保存"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == 1) {
            CXP_LOG(@"修改密码成功");
            [MMProgressHUD dismissWithSuccess:jsonDict[@"msg"]];
            [weakSelf saveData:jsonDict];
            
        }else{
            CXP_LOG(@"修改密码失败");
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"修改密码错误%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

- (void)saveData:(id)obj{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.pwdF.text forKey:@"user_pwd"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)verification{
    //验证旧密码
    if (![self verificationBeforePwd:self.beforePwdF.text]) return NO;
    //检验密码位数
    if(![CXPVerify checkLengthOfPassword:self.pwdF.text]) return NO;
    //检验两次密码一样
    if (![CXPVerify checkVerifyPassword:self.pwdOnceF.text password:self.pwdF.text]) return NO;
    
    return YES;
}

//验证旧密码
- (BOOL)verificationBeforePwd:(NSString *)beforePwd{
    NSString *oldPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_pwd"];
    if ([beforePwd isEqualToString:oldPwd]) return YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"现有密码不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    return NO;
}
@end
