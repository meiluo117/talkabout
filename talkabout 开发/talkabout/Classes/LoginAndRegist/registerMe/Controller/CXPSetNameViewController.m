//
//  CXPSetNameViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//
//左侧空白
#define LEFT_SPACE 10
//字数限制
#define CONTENT_LIMIT 7

#import "CXPSetNameViewController.h"
#import "CXPNavItemBtn.h"

@interface CXPSetNameViewController ()<UITextFieldDelegate>
@property (weak,nonatomic)UITextField *nameTextF;

@end

@implementation CXPSetNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)creatUI{
    self.view.backgroundColor = kColor(242, 242, 242, 1);
    self.navigationItem.title = @"姓名";
    
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
    self.nameTextF = textF;
    self.nameTextF.placeholder        = @"请输入7字以内姓名";
    self.nameTextF.font               = [UIFont systemFontOfSize:17];
    self.nameTextF.clearButtonMode    = UITextFieldViewModeAlways;
    self.nameTextF.keyboardType       = UIKeyboardTypeDefault;
    self.nameTextF.returnKeyType      = UIReturnKeyDone;
    self.nameTextF.delegate           = self;
    if (self.nameStr.length != 0) {
        self.nameTextF.text = self.nameStr;
    }
    [subView addSubview:self.nameTextF];
    
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
    
    if (self.nameTextF.text.length > CONTENT_LIMIT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入7字以内姓名" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        
        if (self.messageCallBack) {
            self.messageCallBack(self.nameTextF.text);
        }
        [CXPUserModel sharedModel].name = self.nameTextF.text;
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
    
    if (self.nameTextF == textField) {
        if (infoString.length > CONTENT_LIMIT) {
            textField.text = [infoString substringToIndex:CONTENT_LIMIT];
            
            return NO;
        }
        
    }
    return YES;
}

@end
