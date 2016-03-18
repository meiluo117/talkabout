//
//  VerificationPhoneViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "VerificationPhoneViewController.h"
#import "CXPVerify.h"
#import "CXPNavItemBtn.h"
#import "CXPRegisterMeViewController.h"

@interface VerificationPhoneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeF;
- (IBAction)sendVerificationCodeBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendVerBtn;
- (IBAction)sureBtn:(UIButton *)sender;

@end

@implementation VerificationPhoneViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
    [self getServercodeTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    self.navigationItem.title = @"验证手机";
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
- (void)backClick:(UIButton*)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//发送验证码按钮
- (IBAction)sendVerificationCodeBtn:(UIButton *)sender {
    [self getServercodeTimer];
    [self sendRequestVerification];
}

//确认按钮
- (IBAction)sureBtn:(UIButton *)sender {
    //验证码文本框校验
    if(![self verifyCode]) return;

    [self sendRequest];
}

- (void)sendRequestVerification{
    NSDictionary *params = @{@"mobile":self.phoneNum,
                             @"source":@"1"};
    
    [self loadDataFromNetworkVerification:URL_VERIFICATION_PHONE params:params];
}

- (void)sendRequest{
    NSDictionary *params = @{@"username"   :self.phoneNum,
                             @"identify"   :self.verificationCodeF.text,
                             @"password"   :self.pwdNum,
                             @"source"     :@"1"};
    
    [self loadDataFromNetwork:URL_REGISTER params:params];
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
                
                [weakSelf.sendVerBtn setTitle:@"重新发送" forState: UIControlStateNormal];
                [weakSelf.sendVerBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [weakSelf.sendVerBtn setEnabled:YES];
                
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d秒后重试", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.sendVerBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [weakSelf.sendVerBtn setTitle:strTime forState:UIControlStateNormal];
                [weakSelf.sendVerBtn setEnabled:NO];
                
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
    if([CXPVerify checkVerificationCodeLength:self.verificationCodeF.text]) return YES;
    
    return NO;
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在注册"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"注册成功:%@",json);
            [MMProgressHUD dismissWithSuccess:json[@"msg"]];
            //注册成功 存储用户名 密码 token
            [weakSelf saveData:jsonDict];
        }else{
            CXP_LOG(@"注册失败");
            [MMProgressHUD dismissWithError:json[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"注册错误:%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

- (void)loadDataFromNetworkVerification:(NSString *)url params:(NSDictionary *)params{
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"发送验证码到手机成功:%@",json);
        }else{
            CXP_LOG(@"发送验证码到手机失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"发送验证码到手机错误:%@",error);
    }];
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
    NSDictionary *dataDict = obj[@"data"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dataDict[@"token"] forKey:@"user_token"];
    [defaults setObject:self.phoneNum forKey:@"user_phone"];
    [defaults setObject:self.pwdNum forKey:@"user_pwd"];
    
    CXPRegisterMeViewController *aboutMe = [[CXPRegisterMeViewController alloc] init];
    aboutMe.phone = self.phoneNum;
    [self.navigationController pushViewController:aboutMe animated:YES];
    
}

@end
