//
//  CXPHomeViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/15.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPHomeViewController.h"
#import "CXPAboutMeViewController.h"
#import "CXPMessageViewController.h"
#import "CXPHomeCell.h"
#import "CXPNavItemBtn.h"
#import "CXPBPReadViewController.h"
#import "CXPSearchViewController.h"
#import "CXPHttpNetTool.h"
#import "CXPHomeBPModel.h"
#import <PopMenu.h>
#import "CXPUserModel.h"
#import "CXPExplainViewController.h"
#import "CXPBPImportExplain.h"

@interface CXPHomeViewController ()<UITableViewDataSource,UITableViewDelegate>

- (IBAction)addBtnClick:(UIButton *)sender;
- (IBAction)messageBtnClick:(UIButton *)sender;
- (IBAction)MeBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,strong) NSMutableArray *dataArray;
/**设置页面网址的页数*/
@property (nonatomic,assign)int page;
/**总页数*/
@property (nonatomic,assign)int totalPage;
@property (nonatomic, strong) PopMenu *popMenu;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator ;
@end

@implementation CXPHomeViewController

static NSString * const home = @"home";
static id _instance;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.leftBarButtonItem   = nil;
    self.navigationItem.hidesBackButton     = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self creatData];
    self.tableV.delegate    = self;
    self.tableV.dataSource  = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"refresh" object:nil];
}

- (void)creatUI{
    self.navigationItem.title   = @"投客";
    self.tableV.backgroundColor = kColor(242, 242, 242, 1);
    self.tableV.separatorStyle  = NO; //隐藏cell线
    
    UIButton *searchBtn                      = [CXPNavItemBtn btnWithWidth:20 height:20 andBtnName:@"search"];
    UIBarButtonItem *rigthBtn                = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem   = rigthBtn;
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)creatData{
    [self loadNewData];
    
    self.tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    self.tableV.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

//搜索按钮
- (void)searchBtnClick:(UIButton *)btn{
    CXPSearchViewController *searchVC = [[CXPSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

//显示中间按钮add按钮内容
- (IBAction)addBtnClick:(UIButton *)sender {
    [self showMenu];
}

//消息按钮
- (IBAction)messageBtnClick:(UIButton *)sender {
    CXPMessageViewController * messageVC = [[CXPMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

//我的按钮
- (IBAction)MeBtnClick:(id)sender {
    CXPAboutMeViewController * meVC = [[CXPAboutMeViewController alloc] init];
    meVC.loginVC = self.loginController;
    [self.navigationController pushViewController:meVC animated:YES];
}

#pragma mark 加载最新数据
- (void)loadNewData{
    self.page = 1;
    [self.tableV.mj_footer endRefreshing];
    [self sendNewRequest];
}

- (void)sendNewRequest{
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"];
    NSDictionary *params = @{@"token" :userToken,
                             @"page"  :@(self.page)};
    [self loadNewDataFromNetwork:URL_BPHOME andParams:params];
    
}
- (void)loadNewDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    WS(weakSelf)
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict   = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            //请求成功 清空数组
            [weakSelf.dataArray removeAllObjects];
            
            NSDictionary *dataDict  = jsonDict[@"data"];
            NSArray *listArray      = dataDict[@"list"];
            weakSelf.totalPage      = [dataDict[@"totalPage"] intValue];
            
            for (NSDictionary *dict in listArray) {
                CXPHomeBPModel *model = [CXPHomeBPModel setupWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.tableV.mj_header endRefreshing];
            [weakSelf.tableV reloadData];
            
        }else{
            CXP_LOG(@"加载最新数据失败");
            [weakSelf.tableV.mj_header endRefreshing];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"加载最新数据错误:%@",error);
        [weakSelf.tableV.mj_header endRefreshing];
    }];
}

#pragma mark 加载更多数据
- (void)loadMoreData{
    //下一页数
    self.page ++;
    [self sendMoreRequest];
}

- (void)sendMoreRequest{
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"];
    NSDictionary *params = @{@"token" :userToken,
                             @"page"  :@(self.page)};
    [self loadMoreDataFromNetwork:URL_BPHOME andParams:params];
}
- (void)loadMoreDataFromNetwork:(NSString *)url andParams:(NSDictionary *)params{
    WS(weakSelf)
    [CXPHttpNetTool post:url params:params success:^(id json) {
        NSDictionary *jsonDict = (NSDictionary *)json;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        
        if (statusCode == 1) {
            NSDictionary *dataDict = jsonDict[@"data"];
            NSArray *listArray = dataDict[@"list"];
            
            for (NSDictionary *dict in listArray) {
                CXPHomeBPModel *model = [CXPHomeBPModel setupWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            
            if (weakSelf.page > weakSelf.totalPage) {
                [weakSelf.tableV.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.tableV.mj_footer endRefreshing];
                [weakSelf.tableV reloadData];
            }
            
        }else{
            CXP_LOG(@"加载更多数据失败");
            [weakSelf.tableV.mj_footer endRefreshing];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"加载更多数据错误:%@",error);
        [weakSelf.tableV.mj_footer endRefreshing];
    }];
}

#pragma mark - 中间按钮效果
- (void)showMenu {
    WS(weakSelf)
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:4];
    
    MenuItem *menuItem  = [MenuItem itemWithTitle:@"从邮箱导入" iconName:@"emailPop@2x"];
    [items addObject:menuItem];
    menuItem            = [MenuItem itemWithTitle:@"从微信导入" iconName:@"wechatPop@2x"];
    [items addObject:menuItem];
    menuItem            = [MenuItem itemWithTitle:@"从QQ导入" iconName:@"qqPop@2x"];
    [items addObject:menuItem];
    menuItem            = [MenuItem itemWithTitle:@"从电脑导入" iconName:@"computerPop@2x"];
    [items addObject:menuItem];
    
    _popMenu.perRowItemCount = 3;
    
    if (!_popMenu) {
        _popMenu = [[PopMenu alloc] initWithFrame:self.view.bounds items:items];
        _popMenu.menuAnimationType = kPopMenuAnimationTypeNetEase;
    }
    if (_popMenu.isShowed) {
        return;
    }
    _popMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem) {
        CXP_LOG(@"%ld",(long)selectedItem.index);
        NSInteger index                     = selectedItem.index;
        CXPExplainViewController *explainVC = [[CXPExplainViewController alloc] init];
        explainVC.explainStr                = [CXPBPImportExplain bpImport:index];
        explainVC.explainTitle              = [CXPBPImportExplain bpImportTitle:index];
        [weakSelf presentViewController:explainVC animated:YES completion:^{}];
    };
    
    [_popMenu showMenuAtView:self.navigationController.view];
}

#pragma mark - 在滑动手势删除某一行的时候，显示更多按钮
- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf)
    
    CXPHomeBPModel *model = self.dataArray[indexPath.row];
    NSString *titleString;
    if ([model.read isEqualToString:@"1"]) {
        titleString = @"标为未读";
    }else{
        titleString = @"标为已读";
    }
    UITableViewRowAction *noReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:titleString handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 切换已读未读状态(请求之前执行)
        CXPHomeBPModel *modelRead = self.dataArray[indexPath.row];
        if ([modelRead.read isEqualToString:@"1"]) {
            modelRead.read = @"2";
        }else{
            modelRead.read = @"1";
        }

        NSDictionary *readDict = @{@"bpId"      :model.bpId,
                                   @"token"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                                   @"read"      :modelRead.read,
                                   @"source"    :@"1"};
        
        [CXPHttpNetTool post:URL_BPReadOrUnread params:readDict success:^(id json) {
            NSDictionary *jsonDict = (NSDictionary *)json;
            
            if ([json[@"code"] isEqualToString:@"1"]) {
                
                CXP_LOG(@"修改已读未读成功:%@",jsonDict);
                [weakSelf.tableV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                
            }else{
                //修改失败 改回已未读状态
                CXP_LOG(@"修改已读未读失败!!!");
                if ([modelRead.read isEqualToString:@"2"]) {
                    modelRead.read = @"1";
                }else{
                    modelRead.read = @"2";
                }
                [weakSelf.tableV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
            
        } failure:^(NSError *error) {
            CXP_LOG(@"修改已读未读错误:%@",error);
        }];
        
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //发送删除请求
        CXPHomeBPModel *model = [weakSelf.dataArray objectAtIndex:indexPath.row];
        NSDictionary *deleDcit = @{@"bpId"      :model.bpId,
                                   @"token"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]};
        
        [CXPHttpNetTool post:URL_BPDelete params:deleDcit success:^(id json) {

            NSDictionary *jsonDict = (NSDictionary *)json;
            
            if ([jsonDict[@"code"] isEqualToString:@"1"]) {
                
                //移除数据源index.row
                [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
                [weakSelf.tableV deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }else{

            }
            
        } failure:^(NSError *error) {
            CXP_LOG(@"删除error:%@",error);
        }];

    }];
    
    return @[deleteAction, noReadAction];
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    if (editingStyle == UITableViewCellEditingStyleDelete) {
    //        [self.dataArray removeObjectAtIndex:indexPath.row];
    //
    //        [self.tableV deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
    //    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   // static NSString *home = @"home";

    CXPHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:home];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPHomeCell" owner:self options:nil] lastObject];
    }
    //防崩溃
    CXPHomeBPModel *model;
    if (self.dataArray.count > indexPath.row) {
        model = [self.dataArray objectAtIndex:indexPath.row];
        [cell setModel:model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf)
    
    //点击某一行后 让颜色变回来
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CXPBPReadViewController *BPReadVC   = [[CXPBPReadViewController alloc] init];
    CXPHomeBPModel *model               = self.dataArray[indexPath.row];
    BPReadVC.homeModel                  = model;
    
    // 将未读变为已读
    if ([model.read isEqualToString:@"2"]) {
        model.read = @"1";
    
        NSDictionary *readDict = @{@"bpId"      :model.bpId,
                                   @"token"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],
                                   @"read"      :model.read,
                                   @"source"    :@"1"};
        
        [CXPHttpNetTool post:URL_BPReadOrUnread params:readDict success:^(id json) {
            NSDictionary *jsonDict = (NSDictionary *)json;
            
            if ([jsonDict[@"code"] isEqualToString:@"1"]) {
                
                [weakSelf.tableV reloadData];
                
            }else{
               
            }
            
        } failure:^(NSError *error) {
            
        }];

    }
    [self.navigationController pushViewController:BPReadVC animated:YES];
}

#pragma mark - 第三方应用打开上传
- (void)openFile:(NSString *)string{
    WS(weakSelf)
    
    [self.tableV.mj_header endRefreshing];
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"];//取出token

    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:string] options:0 error:&error];
    
    if (nil == data && userToken.length == 0) return;//防崩溃
    
    //文件过大 禁止上传
    if (data.length > 20000000) {
        [MMProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"文件过大!" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return ;
    }

    NSDictionary *paramsDict = @{@"token":userToken};
    
    CXP_LOG(@"上传文件取出token:%@",userToken);
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在上传"];
    
    [CXPHttpNetTool post:URL_BPUpload params:paramsDict data:data name:@"file" fileName:weakSelf.fileName mimeType:@"application/pdf" success:^(id json) {

        NSDictionary *jsonDict = (NSDictionary *)json;
        CXP_LOG(@"json:%@",json);
        
        if ([jsonDict[@"code"] isEqualToString:@"1"]) {
            CXP_LOG(@"上传成功");
            [MMProgressHUD dismissWithSuccess:@"上传成功"];
            [weakSelf.tableV.mj_header beginRefreshing];
            
        }else{
            CXP_LOG(@"上传失败");
            [MMProgressHUD dismissWithError:@"上传失败"];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"上传错误%@",error);
        [MMProgressHUD dismissWithError:@"上传错误"];
    }];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)dealloc{
    [self.dataArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh" object:nil];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

@end
