//
//  CXPRegisterViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/22.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPRegisterViewController.h"
#import "CXPLoginViewController.h"
#import "CXPVerify.h"
//#import "IQKeyboardManager.h"
#import "VerificationPhoneViewController.h"
#import "CXPRegisterMeViewController.h"
#import "CXPServiceTermsViewController.h"

@interface CXPRegisterViewController ()<UITextFieldDelegate>{
    BOOL _wasKeyboardManagerEnabled;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneTextF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextF;
- (IBAction)termsBtnClick:(UIButton *)sender;
- (IBAction)registerBtnClick:(UIButton *)sender;
- (IBAction)backLoginBtnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation CXPRegisterViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 //   [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
//    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    [self creatUI];
}

- (void)creatUI{
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    self.phoneTextF.delegate  = self;
    self.pwdTextF.delegate    = self;
    self.pwdTextF.secureTextEntry   = YES;
    self.phoneTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTextF.clearButtonMode   = UITextFieldViewModeWhileEditing;
  //  [self.phoneTextF becomeFirstResponder];
}

/**
 *  文本框校验
 */
- (BOOL)verifyTextField{
    //检验手机号是否为空
    if([CXPVerify isPobileNumEmpty:self.phoneTextF.text]) return NO;
    //检验手机号是否合法
    if(![CXPVerify isPhoneNumAvailability:self.phoneTextF.text]) return NO;
    //检验密码位数
    if(![CXPVerify checkLengthOfPassword:self.pwdTextF.text]) return NO;
    
    return YES;
}
//取消键盘
- (void)cancelKeyboard{
    [self.view endEditing:YES];
}
//服务条款按钮
- (IBAction)termsBtnClick:(UIButton *)sender {
    CXPServiceTermsViewController *serviceTermsVC = [[CXPServiceTermsViewController alloc] init];
    [self.navigationController pushViewController:serviceTermsVC animated:YES];
}
//返回登陆按钮
- (IBAction)backLoginBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建
- (IBAction)registerBtnClick:(UIButton *)sender {
    
    if(![self verifyTextField]) return;
    sender.enabled = NO;
    
    [self sendRequest];
}

- (void)sendRequest{
    NSDictionary *params = @{@"mobile":self.phoneTextF.text,
                             @"source":@"1"};
    [self loadDataFromNetwork:URL_VERIFICATION_PHONE params:params];
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
//    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
//    [MMProgressHUD showWithTitle:nil status:@"正在校验"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"发送验证码到手机成功:%@",json);
            weakSelf.registerBtn.enabled = YES;
            [weakSelf saveData:jsonDict];
            
        }else{
            CXP_LOG(@"发送验证码到手机失败");
            [MMProgressHUD dismissWithError:json[@"msg"]];
            weakSelf.registerBtn.enabled = YES;
        }
        
    } failure:^(NSError *error) {
        [MMProgressHUD dismissWithError:@"请求超时"];
        CXP_LOG(@"发送验证码到手机错误:%@",error);
        weakSelf.registerBtn.enabled = YES;
    }];
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
 //   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    VerificationPhoneViewController *verificationPhoneVC = [[VerificationPhoneViewController alloc] init];
    verificationPhoneVC.phoneNum = self.phoneTextF.text;
    verificationPhoneVC.pwdNum = self.pwdTextF.text;
    [self.navigationController pushViewController:verificationPhoneVC animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

@end
