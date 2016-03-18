//
//  CXPAboutMeViewController.m
//  talkabout
//
//  Created by 于波 on 16/2/1.
//  Copyright © 2016年 于波. All rights reserved.
//
typedef NS_ENUM(NSInteger,imageEnum){
    imageUnknow = 0,
    imageHead   = 1,//头像
    imageCard   = 2//名片
};

#import "CXPAboutMeViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPOtherTableViewCell.h"
#import "CXPSetHeaderImageCell.h"
#import "CXPSetNameCell.h"
#import "CXPSetCardImageCell.h"
#import "CXPSetNameViewController.h"
#import "CXPSetCompanyViewController.h"
#import "CXPSetJobViewController.h"
#import "CXPSetWechatViewController.h"
#import "CXPChangePwdViewController.h"
#import "CXPAPPMessageViewController.h"
#import "CXPLoginViewController.h"

@interface CXPAboutMeViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak,nonatomic)UITableView *tableV;
@property (assign,nonatomic) NSInteger index;
@property (copy,nonatomic) NSString *headImageUrl;//纪录上传头像url
@property (copy,nonatomic) NSString *cardImageUrl;//纪录上传名片url
@end

@implementation CXPAboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = imageUnknow;
    [self creatUI];
}

- (void)creatUI{
    self.navigationItem.title = @"我";
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *button                        = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [button addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    button.tag                              = 10000;
    
    UITableView *tableview  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    
    self.tableV             = tableview;
    [self.view addSubview:self.tableV];
    self.tableV.delegate    = self;
    self.tableV.dataSource  = self;
    self.tableV.bounces     = NO;
    
    UIView * footView           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    footView.backgroundColor    = CXP_ColorFromRGB(0xe8e8e8);
    self.tableV.tableFooterView = footView;
    
    UIButton * exitBtn      = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame           = CGRectMake(0, 30, ScreenWidth, 50);
    exitBtn.backgroundColor = kColor(255, 255, 255, 1);
    [exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitBtn setTitleColor:CXP_ColorFromRGB(0x333333) forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:exitBtn];
}

#pragma mark - 发送请求
- (void)sendRequest{
    UITextField *nameTextF      = (UITextField *)[self.view viewWithTag:101];
    UITextField *companyTextF   = (UITextField *)[self.view viewWithTag:102];
    UITextField *jobTextF       = (UITextField *)[self.view viewWithTag:103];
    UITextField *wechatTextF    = (UITextField *)[self.view viewWithTag:105];
    
    if ([CXPUserModel sharedModel].logo == 0) {
        [CXPUserModel sharedModel].logo = @"";
    }
    if ([CXPUserModel sharedModel].card == 0) {
        [CXPUserModel sharedModel].card = @"";
    }
    if ([CXPUserModel sharedModel].mobile.length == 0) {
        [CXPUserModel sharedModel].mobile = @"";
    }
    
    NSDictionary *params = @{@"realName"    :nameTextF.text,
                             @"mobile"      :[CXPUserModel sharedModel].mobile,
                             @"company"     :companyTextF.text,
                             @"position"    :jobTextF.text,
                             @"headImg"     :[CXPUserModel sharedModel].logo,
                             @"wechat"      :wechatTextF.text,
                             @"card"        :[CXPUserModel sharedModel].card,
                             @"token"       :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                             @"source"      :@"1"};
    CXP_LOG(@"----%@",params);
    
    [self loadDataFromNetwork:URL_ABOUTME params:params];
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    WS(weakSelf)
    UIButton *btn = (UIButton *)[self.view viewWithTag:10000];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"提交的个人信息?:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"提交个人信息成功:%@",json);
            [MMProgressHUD dismissWithSuccess:@"提交个人信息成功"];
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveData:dataDict];
            btn.enabled = YES;
            
        }else{
            CXP_LOG(@"提交个人信息失败");
            btn.enabled = YES;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"提交个人信息错误:%@",error);
        btn.enabled = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
    CXPUserModel *userModel = [CXPUserModel sharedModel];
    [userModel setValuesForKeysWithDictionary:obj];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 返回按钮 保存数据
- (void)backClick:(UIButton*)btn{
    btn.enabled = NO;
    [self sendRequest];
}
#pragma mark - 退出登陆 清空用户信息
- (void)exitBtnClick:(UIButton *)btn{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"user_phone"];
    [userDefaults removeObjectForKey:@"user_pwd"];
    [userDefaults removeObjectForKey:@"user_token"];
    [userDefaults synchronize];
    
    CXPUserModel *model = [CXPUserModel sharedModel];
    [model clear];
    
    CXPLoginViewController *loginVC     = [[CXPLoginViewController alloc] init];
    loginVC.pwdTextField.text           = @"";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            CXPSetHeaderImageCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetHeaderImageCell" owner:self options:nil] lastObject];
            cell.headerImageV.tag = 1000;
            UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseHeadPic)];
            [cell.headerImageV addGestureRecognizer:tapToCancelKeyboard];
            
            NSString *head = [CXPUserModel sharedModel].logo;
            CXP_LOG(@"%@",head);
            if (head.length != 0) {
                [cell.headerImageV sd_setImageWithURL:[NSURL URLWithString:head]];
            }else{
                [cell.headerImageV setImage:[UIImage imageNamed:@"head"]];
            }
            return cell;
        }
            break;
            
        case 1:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"姓名";
            cell.infoTextF.text = [CXPUserModel sharedModel].name;
            cell.infoTextF.tag = 101;
            return cell;
        }
            break;
            
        case 2:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"公司";
            cell.infoTextF.text = [CXPUserModel sharedModel].company;
            cell.infoTextF.tag = 102;
            return cell;
        }
            break;
            
        case 3:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"职位";
            cell.infoTextF.text = [CXPUserModel sharedModel].position;
            cell.infoTextF.tag = 103;
            return cell;
        }
            break;
            
        case 4:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"手机";
            cell.infoTextF.text = [CXPUserModel sharedModel].mobile;
            cell.infoTextF.tag = 104;
            return cell;
        }
            break;
            
        case 5:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"微信号";
            cell.infoTextF.text = [CXPUserModel sharedModel].wechat;
            cell.infoTextF.tag = 105;
            return cell;
        }
            break;
            
        case 6:
        {
            CXPOtherTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPOtherTableViewCell" owner:self options:nil] lastObject];
            cell.titleLable.text = @"修改密码";
            return cell;
        }
            break;
            
        case 7:
        {
            CXPSetCardImageCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetCardImageCell" owner:self options:nil] lastObject];
            cell.cardImageV.tag = 1007;
            UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCardPic)];
            [cell.cardImageV addGestureRecognizer:tapToCancelKeyboard];
            
            NSString *card = [CXPUserModel sharedModel].card;
            if (card.length != 0) {
                [cell.cardImageV sd_setImageWithURL:[NSURL URLWithString:card]];
            }else{
                [cell.cardImageV setImage:[UIImage imageNamed:@"card3"]];
            }
            return cell;
        }
            break;
            
        default:
        {
            CXPOtherTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"CXPOtherTableViewCell" owner:self options:nil] lastObject];
            cell.titleLable.text = @"关于本软件";
            return cell;
        }
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row       == 0) {
        return 100.0f;
    }else if(indexPath.row  == 7){
        return 220.0f;
    }else{
        return 60.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击某一行后 让颜色变回来
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WS(weakSelf)
    switch (indexPath.row) {
        case 1:
        {
            CXPSetNameViewController *setNameVC = [[CXPSetNameViewController alloc] init];
            [setNameVC setMessageCallBack:^(NSString *msg) {
                UITextField *textF = (UITextField *)[weakSelf.view viewWithTag:101];
                textF.text = msg;
            }];
            setNameVC.nameStr = [CXPUserModel sharedModel].name;
            [self.navigationController pushViewController:setNameVC animated:YES];
        }
            break;
        case 2:
        {
            CXPSetCompanyViewController *setCompanyVC = [[CXPSetCompanyViewController alloc] init];
            [setCompanyVC setMessageCallBack:^(NSString *msg) {
                UITextField *textF = (UITextField *)[weakSelf.view viewWithTag:102];
                textF.text = msg;
            }];
            setCompanyVC.companyStr = [CXPUserModel sharedModel].company;
            [self.navigationController pushViewController:setCompanyVC animated:YES];
        }
            break;
        case 3:
        {
            CXPSetJobViewController *setJobVC = [[CXPSetJobViewController alloc] init];
            [setJobVC setMessageCallBack:^(NSString *msg) {
                UITextField *textF = (UITextField *)[weakSelf.view viewWithTag:103];
                textF.text = msg;
            }];
            setJobVC.jobStr = [CXPUserModel sharedModel].position;
            [self.navigationController pushViewController:setJobVC animated:YES];
        }
            break;
        case 5:
        {
            CXPSetWechatViewController *setWechatVC = [[CXPSetWechatViewController alloc] init];
            [setWechatVC setMessageCallBack:^(NSString *msg) {
                UITextField *textF = (UITextField *)[weakSelf.view viewWithTag:105];
                textF.text = msg;
            }];
            setWechatVC.wechatStr = [CXPUserModel sharedModel].wechat;
            [self.navigationController pushViewController:setWechatVC animated:YES];
        }
            break;
        case 6:
        {
            CXPChangePwdViewController *changePwdVC = [[CXPChangePwdViewController alloc] init];
            [self.navigationController pushViewController:changePwdVC animated:YES];
        }
            break;
        case 8:
        {
            CXPAPPMessageViewController *APPMessageVC = [[CXPAPPMessageViewController alloc] init];
            [self.navigationController pushViewController:APPMessageVC animated:YES];
        }
            break;
    }
}

#pragma mark - 选择头像/名片
- (void)chooseHeadPic {
    _index = imageHead;
    [self alert];
}

- (void)chooseCardPic{
    _index = imageCard;
    [self alert];
}

- (void)alert{
    WS(weakSelf)
    UIAlertController *alerVc = [UIAlertController alertControllerWithTitle:@"选择您的照片" message:@"您可以从相机拍摄照片或者从相册中选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCamera     = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf pickImageBySourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *actionImagePicker = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf pickImageBySourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alerVc addAction:actionCamera];
    [alerVc addAction:actionImagePicker];
    [alerVc addAction:actionCancel];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alerVc animated:YES completion:nil];
}

- (void)pickImageBySourceType:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate        = self;
    imagePicker.sourceType      = sourceType;
    imagePicker.allowsEditing   = YES;
    [self presentViewController:imagePicker animated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
    NSData *data = UIImageJPEGRepresentation(image, 0.1);
    
    switch (_index) {
        case imageHead:
            [self setHeadImage:data];
            break;
        case imageCard:
            [self setCardImage:data];
            break;
    }
}

- (void)setHeadImage:(NSData *)data{
    UIImageView *imageV = (UIImageView *)[self.view viewWithTag:1000];
    imageV.image = [UIImage imageWithData:data];
    [self sendHeadImage:data];
}
- (void)setCardImage:(NSData *)data{
    UIImageView *imageV2 = (UIImageView *)[self.view viewWithTag:1007];
    imageV2.image = [UIImage imageWithData:data];
    [self sendCardImage:data];
}

- (void)sendHeadImage:(NSData *)data{
    [CXPHttpNetTool post:URL_SEND_IMAGE params:nil data:data name:@"file" fileName:@"head.jpeg" mimeType:@"image/jpeg" success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger status = [jsonDict[@"code"] integerValue];
        if (status == 1) {
            CXP_LOG(@"上传名片成功");
            NSDictionary *dictData = jsonDict[@"data"];
            [CXPUserModel sharedModel].logo = dictData[@"url"];
        }else{
            CXP_LOG(@"上传头像失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"上传头像错误%@",error);
    }];
}
- (void)sendCardImage:(NSData *)data{
    [CXPHttpNetTool post:URL_SEND_IMAGE params:nil data:data name:@"file" fileName:@"card.jpeg" mimeType:@"image/jpeg" success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger status = [jsonDict[@"code"] integerValue];
        if (status == 1) {
            CXP_LOG(@"上传名片成功");
            NSDictionary *dictData = jsonDict[@"data"];
            [CXPUserModel sharedModel].card = dictData[@"url"];
        }else{
            CXP_LOG(@"上传名片失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"上传名片错误%@",error);
    }];
}


@end
