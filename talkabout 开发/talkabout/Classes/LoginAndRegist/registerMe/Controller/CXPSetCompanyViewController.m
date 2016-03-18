//
//  CXPSetCompanyViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/26.
//  Copyright © 2016年 于波. All rights reserved.
//
#define LEFT_SPACE 10
//字数限制
#define CONTENT_LIMIT 20

#import "CXPSetCompanyViewController.h"
#import "CXPNavItemBtn.h"

@interface CXPSetCompanyViewController ()<UITextFieldDelegate>
@property (weak,nonatomic)UITextField *companyTextF;
@end

@implementation CXPSetCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"公司";
    
    UIButton *lbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"取消" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [lbuttn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lbuttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    UIButton *rbuttn                        = [CXPNavItemBtn btnWithWidth:30 height:20 BtnTitle:@"保存" BtnFont:14 andBtnTitleColor:kColor(35, 35, 35, 1)];
    [rbuttn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rbuttn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    
    UIView *subView         = [[UIView alloc]initWithFrame:CGRectMake(0, 84, ScreenWidth, 44)];
    subView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:subView];
    
    UITextField *textF                   = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_SPACE, 0, ScreenWidth - (LEFT_SPACE*2), 44)];
    self.companyTextF = textF;
    self.companyTextF.placeholder        = @"请输入20字以内公司名";
    self.companyTextF.font               = [UIFont systemFontOfSize:17];
    self.companyTextF.clearButtonMode    = UITextFieldViewModeAlways;
    self.companyTextF.keyboardType       = UIKeyboardTypeDefault;
    self.companyTextF.returnKeyType      = UIReturnKeyDone;
    self.companyTextF.delegate           = self;
    if (self.companyStr.length != 0) {
        self.companyTextF.text = self.companyStr;
    }
    [subView addSubview:self.companyTextF];
    
    //点击消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];
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
- (void)saveBtnClick:(UIButton *)btn{
    
    if (self.companyTextF.text.length > CONTENT_LIMIT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入20字以内公司名" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        
        if (self.messageCallBack) {
            self.messageCallBack(self.companyTextF.text);
        }
        [CXPUserModel sharedModel].company = self.companyTextF.text;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *infoString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (self.companyTextF == textField) {
        if (infoString.length > CONTENT_LIMIT) {
            textField.text = [infoString substringToIndex:CONTENT_LIMIT];
            
            return NO;
        }
        
    }
    return YES;
}

@end
