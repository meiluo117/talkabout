//
//  CXPSetJobViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/26.
//  Copyright © 2016年 于波. All rights reserved.
//
#define LEFT_SPACE 10
//字数限制
#define CONTENT_LIMIT 10

#import "CXPSetJobViewController.h"
#import "CXPNavItemBtn.h"

@interface CXPSetJobViewController ()<UITextFieldDelegate>
@property (weak,nonatomic)UITextField *jobTextF;
@end

@implementation CXPSetJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"职位";
    
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
    self.jobTextF = textF;
    self.jobTextF.placeholder        = @"请输入10字以内职位名";
    self.jobTextF.font               = [UIFont systemFontOfSize:17];
    self.jobTextF.clearButtonMode    = UITextFieldViewModeAlways;
    self.jobTextF.keyboardType       = UIKeyboardTypeDefault;
    self.jobTextF.returnKeyType      = UIReturnKeyDone;
    self.jobTextF.delegate           = self;
    if (self.jobStr.length != 0) {
        self.jobTextF.text = self.jobStr;
    }
    [subView addSubview:self.jobTextF];
    
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
    
    if (self.jobTextF.text.length > CONTENT_LIMIT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入10字以内职位名" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        
        if (self.messageCallBack) {
            self.messageCallBack(self.jobTextF.text);
        }
        [CXPUserModel sharedModel].position = self.jobTextF.text;
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
    
    if (self.jobTextF == textField) {
        if (infoString.length > CONTENT_LIMIT) {
            textField.text = [infoString substringToIndex:CONTENT_LIMIT];
            
            return NO;
        }
        
    }
    return YES;
}
@end
