//
//  CXPBPReadViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/22.
//  Copyright © 2015年 于波. All rights reserved.
//
#define SharedDetail @"我这儿有个不错的BP,邀您一起查看"

#import "CXPBPReadViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPSystemTime.h"
#import "CXPBPEditViewController.h"
#import "CXPBPFileTypeStatusColor.h"
#import "CXPBPReadWebViewController.h"
#import "CXPHomeBPModel.h"
#import "CXPBPFileTypeStatusColor.h"
#import <UMSocial.h>
#import "HYActivityView.h"

@interface CXPBPReadViewController ()<UITextViewDelegate,UMSocialUIDelegate,UMSocialDataDelegate>
- (IBAction)changeTitleBtnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
/**bp编辑时间*/
@property (weak, nonatomic) IBOutlet UILabel *editLable;
/**备注*/
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
/**bp图标*/
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
/**bp名称*/
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
/**bp状态背景颜色*/
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
/**bp状态*/
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
/*状态字典*/
@property (strong,nonatomic) NSDictionary *statusDict;

@property (nonatomic, strong) HYActivityView *activityView;
@end

@implementation CXPBPReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    
    self.statusDict = @{@"开始":@"1",@"约谈":@"2",@"意向":@"3",@"尽调":@"4",@"签约":@"5",@"打款":@"6",@"变更":@"7",@"结束":@"8",@"放弃":@"9"};
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)creatUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title               = @"阅读BP";
    self.view.backgroundColor               = kColor(239, 239, 239, 1);
    self.detailTextView.delegate            = self;
    self.detailTextView.keyboardType        = UIKeyboardTypeDefault;
    self.detailTextView.backgroundColor = [UIColor clearColor];
  //  self.detailTextView.showsVerticalScrollIndicator    = NO;
    self.detailTextView.showsHorizontalScrollIndicator  = NO;
    self.detailTextView.contentInset = UIEdgeInsetsMake(10, 0, 250, 0);//上左下右
    self.editLable.text                     = self.homeModel.updateTime;//编辑时间
    self.titleLable.text                    = self.homeModel.bpName;
    self.statusLable.text                   = self.homeModel.statusName;
    self.iconImage.userInteractionEnabled   = YES;
    //备注
    if (self.homeModel.comment.length == 0) {
        self.detailTextView.text = @"请在此输入您的备注...";
    }else{
        self.detailTextView.text = self.homeModel.comment;
    }
    
    self.iconImage.image = [CXPBPFileTypeStatusColor bpFileTypeStr:self.homeModel.fileType];
    self.backImage.image = [CXPBPFileTypeStatusColor bpStatusColor:[self.homeModel.status integerValue]];
    
    //添加手势跳转页面 阅读bp
    UITapGestureRecognizer *backGroundViewTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readBP)];
    [self.backgroundView addGestureRecognizer:backGroundViewTag];
    
    UIButton *lBtn                          = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [lBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    UIButton *rBtn                          = [CXPNavItemBtn btnWithWidth:25 height:6 andBtnName:@"share2"];
    [rBtn addTarget:self action:@selector(sharedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    rBtn.tag                                = 107;
    
    //点击空白消除键盘
    UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [self.view addGestureRecognizer:tapToCancelKeyboard];

}

- (void)readBP{
    CXPBPReadWebViewController *readWebVC   = [[CXPBPReadWebViewController alloc] init];
    readWebVC.bpReadUrl     = self.homeModel.url;
    readWebVC.bpNameStr     = self.homeModel.bpName;
    readWebVC.bpfileTypeStr = self.homeModel.fileType;
    readWebVC.bpmd5         = self.homeModel.md5;
    
    [self.navigationController pushViewController:readWebVC animated:YES];
}

/**消除键盘*/
-(void)cancelKeyboard{
    [self.view endEditing:YES];
}

//返回按钮
- (void)backBtnClick:(UIButton *)btn{
    btn.enabled = NO;//防止多次点击
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    NSString *saveString = self.detailTextView.text;
    if ([saveString isEqualToString:@"请在此输入您的备注..."]) {
        saveString = @"";
    }else{
      //  saveString = [saveString stringByReplacingOccurrencesOfString: @"\n" withString: @"\\n"];
    }
    
    if (![saveString isEqualToString:self.homeModel.comment]) {
        
        NSDictionary *paramsDict = @{@"bpId"    :self.homeModel.bpId,
                                     @"token"   :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                                     @"content" :saveString};
        
        [CXPHttpNetTool post:URL_BPComment params:paramsDict success:^(id json) {
            NSDictionary *jsonDict = (NSDictionary *)json;
            
            if ([jsonDict[@"code"] isEqualToString:@"1"]) {
                CXP_LOG(@"修改备注成功");
                btn.enabled = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refresh" object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                CXP_LOG(@"修改备注失败");
                btn.enabled = YES;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            
        } failure:^(NSError *error) {
            btn.enabled = YES;
            CXP_LOG(@"修改备注错误:%@",error);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];

    }else{
        btn.enabled = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refresh" object:nil];
}

//编辑 BP 名称和状态
- (IBAction)changeTitleBtnClick:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    CXPBPEditViewController *BPEditVC   = [[CXPBPEditViewController alloc] init];
    BPEditVC.bpNameStr   = self.titleLable.text;
    BPEditVC.bpStateStr  = self.statusLable.text;
    BPEditVC.bpid        = self.homeModel.bpId;
    
    [BPEditVC setBpInfosCallBack:^(bpChangeInfo bp) {
        weakSelf.titleLable.text            = bp.bpName;
        weakSelf.statusLable.text           = bp.bpStatus;
        weakSelf.editLable.text             = bp.bpEditTime;
        weakSelf.backImage.image  = [CXPBPFileTypeStatusColor bpStatusColor:[bp.bpStatusColor intValue]];
    }];
    
    [self.navigationController pushViewController:BPEditVC animated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([self.detailTextView.text isEqualToString:@"请在此输入您的备注..."]) {
        self.detailTextView.text = @"";
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (self.detailTextView.text.length == 0) {
        self.detailTextView.text = @"请在此输入您的备注...";
    }
    return YES;
}

#pragma mark - 分享
- (void)sharedBtnClick:(UIButton *)btn{
    __weak __typeof(self)weakSelf = self;
    [self.view endEditing:YES];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view setNeedsUpdateConstraints];
    //分享跳转url
    NSString *sharedUrl = [NSString stringWithFormat:URLOther_Shared,self.homeModel.bpId,[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]];
    //分享的图片
    UIImage *image = [CXPBPFileTypeStatusColor bpFileTypeStr:self.homeModel.fileType];
    
    if (!self.activityView) {
        self.activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:self.view];
        
        //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
        self.activityView.numberOfButtonPerLine = 3;
        
        ButtonView *bv = [[ButtonView alloc]initWithText:@"微信好友" image:[UIImage imageNamed:@"wechat"] handler:^(ButtonView *buttonView){
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url      = sharedUrl;//微信好友分享url
            [UMSocialData defaultData].extConfig.wechatSessionData.title    = SharedDetail;//微信好友分享title
            
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:weakSelf.homeModel.bpName image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [weakSelf sharedRecord];
                }
            }];
            
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"QQ好友" image:[UIImage imageNamed:@"qq"] handler:^(ButtonView *buttonView){
            [UMSocialData defaultData].extConfig.qqData.url     = sharedUrl;//qq好友分享url
            [UMSocialData defaultData].extConfig.qqData.title   = SharedDetail;//qq好友分享title
            
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:weakSelf.homeModel.bpName image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [weakSelf sharedRecord];
                }
            }];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"微信朋友圈" image:[UIImage imageNamed:@"wechattime"] handler:^(ButtonView *buttonView){
            [UMSocialData defaultData].extConfig.wechatTimelineData.url     = sharedUrl;//微信朋友圈分享url
            [UMSocialData defaultData].extConfig.wechatTimelineData.title   = SharedDetail;//微信朋友圈分享title
            
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:weakSelf.homeModel.bpName image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    [weakSelf sharedRecord];
                }
            }];
        }];
        [self.activityView addButtonView:bv];
        
    }
    
    [self.activityView show];
}

- (void)sharedRecord{
    //分享成功后  发送请求告诉后台有分享操作
    NSDictionary *params = @{@"bpId"    :self.homeModel.bpId,
                             @"token"   :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                             @"source"  :@"1"};
    
    [CXPHttpNetTool post:URL_BPSharedRecord params:params success:^(id json) {
        CXP_LOG(@"分享成功:%@",json);
    } failure:^(NSError *error) {
        CXP_LOG(@"分享错误:%@",error);
    }];
}
@end
