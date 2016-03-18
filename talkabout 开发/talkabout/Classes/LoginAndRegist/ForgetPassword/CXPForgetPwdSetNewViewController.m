//
//  CXPForgetPwdSetNewViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/27.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPForgetPwdSetNewViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPVerify.h"

@interface CXPForgetPwdSetNewViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pwdTextF;
@property (weak, nonatomic) IBOutlet UITextField *againPwdTextF;

@end

@implementation CXPForgetPwdSetNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"重设密码";
    
    UIButton *lbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"取消" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [lbuttn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lbuttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    UIButton *rbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"保存" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [rbuttn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rbuttn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
    
    self.pwdTextF.delegate      = self;
    self.againPwdTextF.delegate = self;
}

//取消按钮
- (void)cancelBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//保存按钮
- (void)saveBtnClick:(UIButton *)btn{

    if (![self verifyTextField]) return;
    
    if (![CXPVerify checkVerifyPassword:self.againPwdTextF.text password:self.pwdTextF.text]) return;
    
    NSDictionary *params = @{@"passWord"    :self.pwdTextF.text,
                             @"mobile"      :self.phone};
    
    [self loadDataFromNetwork:URL_FORGET_PASSWORD params:params];
}

//消除键盘
-(void)cancelKeyboard{
    [self.view endEditing:YES];
}

/**
 *  文本框校验
 */
- (BOOL)verifyTextField{
    //检验密码位数
    if(![CXPVerify checkLengthOfPassword:self.pwdTextF.text]) return NO;
    
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在保存"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"重设密码成功:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            
            [MMProgressHUD dismiss];
            [weakSelf saveData:jsonDict];
            [weakSelf sureAlert];
            
        }else{
            CXP_LOG(@"重设密码失败");
            [MMProgressHUD dismissWithError:jsonDict[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"重设密码错误:%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

- (void)sureAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"恭喜!" message:@"重设密码成功,请重新登陆" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController popToViewController:self.loginConterollers animated:YES];
    }
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
    __weak __typeof(self)weakSelf = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:weakSelf.phone forKey:@"user_phone"];//保存手机 以便跳转登陆直接显示手机号
    [defaults synchronize];
}

@end
