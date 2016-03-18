//
//  CXPBPEditViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPBPEditViewController.h"
#import "CXPSystemTime.h"
#import "CXPUserModel.h"
#import "CXPNavItemBtn.h"

@interface CXPBPEditViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerV;
@property (nonatomic,strong) UILabel *pickerLable;
/**数据源*/
@property (nonatomic,strong) NSArray *dataArray;
/**bp名称*/
@property (weak, nonatomic) IBOutlet UITextField *bpChangeNameFiled;

@property (strong,nonatomic) NSDictionary *statusDict;
/**bp状态*/
@property (copy,nonatomic) NSString *bpStatus;
/**系统当前时间 无小时分秒*/
@property (copy,nonatomic) NSString *nowTimeNoHour;
/**系统当前时间*/
@property (copy,nonatomic) NSString *nowTime;
@end

@implementation CXPBPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    
    self.bpChangeNameFiled.delegate = self;
    self.pickerV.delegate           = self;
    self.pickerV.dataSource         = self;
    
    self.statusDict = @{@"开始":@"1",@"约谈":@"2",@"意向":@"3",@"尽调":@"4",@"签约":@"5",@"打款":@"6",@"变更":@"7",@"结束":@"8",@"放弃":@"9"};
    self.dataArray = @[@"开始",@"约谈",@"意向",@"尽调",@"签约",@"打款",@"变更",@"结束",@"放弃"];
    self.bpStatus                 = self.bpStateStr;
    self.bpChangeNameFiled.text   = self.bpNameStr;
    
    //picker默认选择
    [self.pickerV selectRow:[self.statusDict[self.bpStateStr] intValue] - 1 inComponent:0 animated:YES];
}

- (void)creatUI{
    self.view.backgroundColor    = kColor(235, 235, 235, 1);
    self.pickerV.backgroundColor = kColor(255, 255, 255, 1);
    self.navigationItem.title    = @"BP编辑";

    UIButton *lBtn                          = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [lBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    UIButton *rBtn                          = [CXPNavItemBtn btnWithWidth:50 height:30 BtnTitle:@"保存" BtnFont:16 andBtnTitleColor:[UIColor blackColor]];
    [rBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    
    self.bpChangeNameFiled.keyboardType     = UIKeyboardTypeDefault;
    self.bpChangeNameFiled.returnKeyType    = UIReturnKeyDone;
    
}

//返回按钮
- (void)backBtnClick:(UIButton *)btn{

    if (![self.bpNameStr isEqualToString:self.bpChangeNameFiled.text] || ![self.bpStateStr isEqualToString:self.bpStatus]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"投客温馨提示"
                                                        message:@"BP名称或BP进度标签有改动 是否保存"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"保存", nil];
        
        [alert show];
    } else{
    
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self saveChanged];
    }
}

#pragma mark - 保存按钮 发送请求 bp名字／bp进程状态
- (void)saveBtnClick:(UIButton *)btn{
    
    [self saveChanged];
}

- (void)saveChanged{
    __weak __typeof(self)weakSelf = self;
    __block bpChangeInfo bp;
    
    //得到当前系统时间
    self.nowTime       = [CXPSystemTime getSystemTime];
    self.nowTimeNoHour = [CXPSystemTime getSystemTimeNoHour];
    
    NSDictionary *paramsDict = @{   @"bpId"    :self.bpid,
                                    @"token"   :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                                    @"name"    :self.bpChangeNameFiled.text,
                                    @"status"  :self.statusDict[self.bpStatus],
                                    @"source"  :@"1",
                                    @"time"    :self.nowTime};
    

    [CXPHttpNetTool post:URL_BPChangeNameTimeStatus params:paramsDict success:^(id json) {

        
        NSDictionary *jsonDict = (NSDictionary *)json;
        CXP_LOG(@"修改bp名称成功:%@",jsonDict);
        
        if ([jsonDict[@"code"] isEqualToString:@"1"]) {
            
            NSString *bpNameStr     = weakSelf.bpChangeNameFiled.text;//防野指针
            NSString *bpStatusStr   = weakSelf.bpStatus;//防野指针
            bp.bpName               = bpNameStr;
            bp.bpStatus             = bpStatusStr;
            bp.bpEditTime           = weakSelf.nowTimeNoHour;
            bp.bpStatusColor        = weakSelf.statusDict[bpStatusStr];
            
            if (weakSelf.bpInfosCallBack) {
                weakSelf.bpInfosCallBack(bp);
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }else{
            [MMProgressHUD dismissWithError:@"保存失败"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"修改bp名称错误:%@",error);
        [MMProgressHUD dismissWithError:@"保存错误"];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];

}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [_dataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.bpStatus = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:row]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - 懒加载
- (NSArray *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}


@end
