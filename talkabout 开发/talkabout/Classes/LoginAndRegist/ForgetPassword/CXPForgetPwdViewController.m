//
//  CXPForgetPwdViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPForgetPwdViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPVerify.h"
#import "CXPForgetPwdSetNewViewController.h"

@interface CXPForgetPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextF;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextF;
- (IBAction)sendVerificationBtnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendVerificationBtn;
- (IBAction)findBtnClick:(UIButton *)sender;

@end

@implementation CXPForgetPwdViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    self.navigationItem.title = @"忘记密码";
    self.view.backgroundColor = kColor(239, 239, 239, 1);
    
    UIButton *button                        = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [button addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem   = leftBtn;
}

//消除键盘
-(void)cancelKeyboard{
    [self.view endEditing:YES];
}

//返回按钮
- (void)backClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取验证码按钮
- (IBAction)sendVerificationBtnClick:(UIButton *)sender {
    //手机号文本框校验
    if(![self verifyPhone]) return;
    
    [self getServercodeTimer];
    [self sendVerificationCode];
}

- (void)sendVerificationCode{
    NSDictionary *params = @{@"mobile" :self.phoneTextF.text,
                             @"source" :@"1"};
    
    [self loadDataFromNetwork:URL_ALREADY_REGISTER params:params];
}

- (void)sendRequest{
    NSDictionary *params = @{@"mobile"  :self.phoneTextF.text,
                             @"code"    :self.verificationTextF.text};
    
    [self loadDataJumpNextConterollerFromNetwork:URL_SEND_CODE params:params];
}

//确认按钮
- (IBAction)findBtnClick:(UIButton *)sender {
    //验证码文本框校验
    if([self verifyCode]) return;
    
    [self sendRequest];
}

/**
 *  手机号文本框校验
 */
- (BOOL)verifyPhone {
    //检验手机号是否为空
    if([CXPVerify isPobileNumEmpty:self.phoneTextF.text]) return NO;
    //检验手机号是否合法
    if(![CXPVerify isPhoneNumAvailability:self.phoneTextF.text]) return NO;
    
    return YES;
}

-(void)getServercodeTimer{
    __weak __typeof(self)weakSelf = self;
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            //            dispatch_release(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{

                [weakSelf.sendVerificationBtn setTitle:@"获取验证码" forState: UIControlStateNormal];
                [weakSelf.sendVerificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [weakSelf.sendVerificationBtn setEnabled:YES];
                
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d秒", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{

                [weakSelf.sendVerificationBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [weakSelf.sendVerificationBtn setTitle:strTime forState:UIControlStateNormal];
                [weakSelf.sendVerificationBtn setEnabled:NO];
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

/**
 *  验证码文本框校验
 */
- (BOOL)verifyCode {
    //检验验证码是否合法
    if([CXPVerify checkVerificationCodeLength:self.verificationTextF.text]) return NO;
    
    return YES;
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"忘记密码，发送验证码:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            
        }else{
            CXP_LOG(@"忘记密码，发送验证码失败");
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"忘记密码，发送验证码错误:%@",error);
    }];
}

- (void)loadDataJumpNextConterollerFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"验证验证码:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            //验证手机成功
            CXPForgetPwdSetNewViewController *setNewPwdVC = [[CXPForgetPwdSetNewViewController alloc] init];
            setNewPwdVC.loginConterollers   = weakSelf.loginController;
            setNewPwdVC.phone               = weakSelf.phoneTextF.text;
            [weakSelf.navigationController pushViewController:setNewPwdVC animated:YES];

        }else{
            CXP_LOG(@"验证验证码失败");
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"验证验证码错误:%@",error);
    }];
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
    __weak __typeof(self)weakSelf = self;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

}

@end
