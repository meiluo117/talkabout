//
//  CXPRegisterMeViewController.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//
typedef NS_ENUM(NSInteger,imageEnum){
    imageUnknow = 0,
    imageHead   = 1,//头像
    imageCard   = 2//名片
};

#import "CXPRegisterMeViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPHomeViewController.h"
#import "CXPSetHeaderImageCell.h"
#import "CXPSetNameCell.h"
#import "CXPSetCardImageCell.h"
#import "CXPSetNameViewController.h"
#import "CXPSetCompanyViewController.h"
#import "CXPSetJobViewController.h"
#import "CXPSetWechatViewController.h"

@interface CXPRegisterMeViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak,nonatomic)UITableView *tableV;
@property (assign,nonatomic)NSInteger index;
@property (copy,nonatomic) NSString *headImageUrl;//纪录上传头像url
@property (copy,nonatomic) NSString *cardImageUrl;//纪录上传名片url
@end

@implementation CXPRegisterMeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = imageUnknow;
    [self creatUI];
}

- (void)creatUI{
    self.navigationItem.title = @"我";
    self.navigationItem.hidesBackButton = YES;

    //右侧按钮
    UIButton *rBtn                          = [CXPNavItemBtn btnWithWidth:50 height:30 BtnTitle:@"提交" BtnFont:16 andBtnTitleColor:[UIColor blackColor]];
    [rBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rigthBtn               = [[UIBarButtonItem alloc] initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem  = rigthBtn;
    //左侧按钮
    UIButton *lBtn                          = [CXPNavItemBtn btnWithWidth:50 height:30 BtnTitle:@"跳过" BtnFont:16 andBtnTitleColor:[UIColor blackColor]];
    [lBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn               = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem  = leftBtn;
    
    UITableView *tableview  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    self.tableV             = tableview;
    [self.view addSubview:self.tableV];
    self.tableV.delegate    = self;
    self.tableV.dataSource  = self;
    self.tableV.bounces     = NO;
}

//跳过按钮
- (void)jumpBtnClick:(UIButton *)btn{
    CXPHomeViewController *homeVC = [[CXPHomeViewController alloc] init];
    [self.navigationController pushViewController:homeVC animated:YES];
}

//提交按钮
- (void)submitBtnClick:(UIButton *)btn{
    [self sendRequest];
}

- (void)sendRequest{
    UITextField *nameTextF      = (UITextField *)[self.view viewWithTag:101];
    UITextField *companyTextF   = (UITextField *)[self.view viewWithTag:102];
    UITextField *jobTextF       = (UITextField *)[self.view viewWithTag:103];
    UITextField *wechatTextF    = (UITextField *)[self.view viewWithTag:105];
    
    if (self.headImageUrl.length == 0) {
        self.headImageUrl = @"";
    }
    if (self.cardImageUrl.length == 0) {
        self.cardImageUrl = @"";
    }
    
    NSDictionary *params = @{@"realName"    :nameTextF.text,
                             @"mobile"      :self.phone,
                             @"company"     :companyTextF.text,
                             @"position"    :jobTextF.text,
                             @"headImg"     :self.headImageUrl,
                             @"wechat"      :wechatTextF.text,
                             @"card"        :self.cardImageUrl,
                             @"token"       :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                             @"source"      :@"1"};
    
    [self loadDataFromNetwork:URL_ABOUTME params:params];
}

#pragma mark - 加载数据
- (void)loadDataFromNetwork:(NSString *)url params:(NSDictionary *)params{
    __weak __typeof(self)weakSelf = self;
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在提交"];
    
    [CXPHttpNetTool post:url params:params success:^(id json) {
        CXP_LOG(@"提交的个人信息?:%@",json);
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            CXP_LOG(@"提交个人信息成功:%@",json);
            [MMProgressHUD dismissWithSuccess:@"提交个人信息成功"];
            NSDictionary *dataDict = jsonDict[@"data"];
            [weakSelf saveData:dataDict];
            
        }else{
            CXP_LOG(@"提交个人信息失败");
            [MMProgressHUD dismissWithError:@"提交个人信息失败"];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"提交个人信息错误:%@",error);
        [MMProgressHUD dismissWithError:@"请求超时"];
    }];
}

#pragma mark - 存储接口数据
- (void)saveData:(id)obj{
    //   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CXPUserModel *userModel = [CXPUserModel sharedModel];
    [userModel setValuesForKeysWithDictionary:obj];
    CXPHomeViewController *homeVC = [[CXPHomeViewController alloc] init];
    [self.navigationController pushViewController:homeVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            CXPSetHeaderImageCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetHeaderImageCell" owner:self options:nil] lastObject];
            cell.headerImageV.tag = 1000;
            UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseHeadPicture)];
            [cell.headerImageV addGestureRecognizer:tapToCancelKeyboard];
            
            return cell;
        }
            break;
            
        case 1:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"姓名";
            cell.infoTextF.tag = 101;
            return cell;
        }
            break;
            
        case 2:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"公司";
            cell.infoTextF.tag = 102;
            return cell;
        }
            break;
            
        case 3:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"职位";
            cell.infoTextF.tag = 103;
            return cell;
        }
            break;
            
        case 4:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"手机";
            cell.infoTextF.text = self.phone;
            cell.infoTextF.tag = 104;
            return cell;
        }
            break;
            
        case 5:
        {
            CXPSetNameCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetNameCell" owner:self options:nil] lastObject];
            cell.titleL.text = @"微信号";
            cell.infoTextF.tag = 105;
            return cell;
        }
            break;
            
        default:
        {
            CXPSetCardImageCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSetCardImageCell" owner:self options:nil] lastObject];
            cell.cardImageV.tag = 1006;
            UITapGestureRecognizer *tapToCancelKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCardPicture)];
            [cell.cardImageV addGestureRecognizer:tapToCancelKeyboard];
            
            return cell;
        }
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 1:
        {
            CXPSetNameViewController *setNameVC = [[CXPSetNameViewController alloc] init];
            UITextField *textF = (UITextField *)[self.view viewWithTag:101];
            [setNameVC setMessageCallBack:^(NSString *msg) {
                textF.text = msg;
            }];
            [self.navigationController pushViewController:setNameVC animated:YES];
        }
            break;
            
        case 2:
        {
            CXPSetCompanyViewController *companyVC = [[CXPSetCompanyViewController alloc] init];
            UITextField *textF = (UITextField *)[self.view viewWithTag:102];
            [companyVC setMessageCallBack:^(NSString *msg) {
                textF.text = msg;
            }];
            [self.navigationController pushViewController:companyVC animated:YES];
        }
            break;
            
        case 3:
        {
            CXPSetJobViewController *jobVC = [[CXPSetJobViewController alloc] init];
            UITextField *textF = (UITextField *)[self.view viewWithTag:103];
            [jobVC setMessageCallBack:^(NSString *msg) {
                textF.text = msg;
            }];
            [self.navigationController pushViewController:jobVC animated:YES];
        }
            break;
            
        case 5:
        {
            CXPSetWechatViewController *wechatVC = [[CXPSetWechatViewController alloc] init];
            UITextField *textF = (UITextField *)[self.view viewWithTag:105];
            [wechatVC setMessageCallBack:^(NSString *msg) {
                textF.text = msg;
            }];
            [self.navigationController pushViewController:wechatVC animated:YES];
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row       == 0) {
        return 100.0f;
    }else if (indexPath.row == 6){
        return 220.0f;
    }else{
        return 60.0f;
    }
}

#pragma mark - 选择头像
- (void)chooseHeadPicture {
    _index = imageHead;
    [self alert];
}

- (void)chooseCardPicture{
    _index = imageCard;
    [self alert];
}

- (void)alert{
    __weak __typeof(self)weakSelf   = self;
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
    UIImageView *imageV2 = (UIImageView *)[self.view viewWithTag:1006];
    imageV2.image = [UIImage imageWithData:data];
    [self sendCardImage:data];
}

- (void)sendHeadImage:(NSData *)data{
    __weak __typeof(self)weakSelf   = self;
    [CXPHttpNetTool post:URL_SEND_IMAGE params:nil data:data name:@"file" fileName:@"head.jpeg" mimeType:@"image/jpeg" success:^(id json) {
        
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger status = [jsonDict[@"code"] integerValue];
        if (status == 1) {
            CXP_LOG(@"上传名片成功");
            NSDictionary *dictData = jsonDict[@"data"];
            weakSelf.headImageUrl = dictData[@"url"];
        }else{
            CXP_LOG(@"上传头像失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"上传头像错误%@",error);
    }];
}
- (void)sendCardImage:(NSData *)data{
    __weak __typeof(self)weakSelf   = self;
    [CXPHttpNetTool post:URL_SEND_IMAGE params:nil data:data name:@"file" fileName:@"card.jpeg" mimeType:@"image/jpeg" success:^(id json) {

        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger status = [jsonDict[@"code"] integerValue];
        if (status == 1) {
            CXP_LOG(@"上传名片成功");
            NSDictionary *dictData = jsonDict[@"data"];
            weakSelf.cardImageUrl = dictData[@"url"];
        }else{
            CXP_LOG(@"上传名片失败");
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"上传名片错误%@",error);
    }];
}
@end
