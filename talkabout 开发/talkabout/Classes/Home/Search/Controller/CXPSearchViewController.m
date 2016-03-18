//
//  CXPSearchViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/23.
//  Copyright © 2015年 于波. All rights reserved.
//

//搜索条 Width
#define cancelBtnFrameX ScreenWidth-60
#define topViewHeigth 64

#import "CXPSearchViewController.h"
#import "CXPSearchCell.h"
#import "CXPSearchModel.h"
#import "CXPBPReadViewController.h"

@interface CXPSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate>
@property (strong,nonatomic) UITableView *searchTableV;
@property (strong,nonatomic) NSMutableArray *searchDataArray;
@property (strong,nonatomic) UISearchBar *searBar;

@end

@implementation CXPSearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatSearchUI];
    [self creatTableView];
    
    self.searBar.delegate           = self;
    self.searchTableV.delegate      = self;
    self.searchTableV.dataSource    = self;
    
    self.searchTableV.separatorStyle  = NO; //隐藏cell线
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupdata) name:@"refresh" object:nil];
}

- (void)creatData{
    __weak __typeof(self)weakSelf = self;
    NSString *search = [[NSString stringWithFormat:URL_BPSearch,[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],self.searBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"正在搜索"];
    [CXPHttpNetTool get:search params:nil success:^(id json) {
        
        if ([json[@"code"] isEqualToString:@"1"]) {
            
            [MMProgressHUD dismissWithSuccess:@"搜索完成"];
            NSDictionary *dataDict = json[@"data"];
            NSArray *listArray = dataDict[@"list"];
            for (NSDictionary *dict in listArray) {
                CXPSearchModel *model = [CXPSearchModel setupWithDict:dict];
                [weakSelf.searchDataArray addObject:model];
            }
            [weakSelf.searchTableV reloadData];
        }
        else{
            CXP_LOG(@"未找到搜索");
            [MMProgressHUD dismissWithError:@"未找到搜索内容"];
        }
        
    } failure:^(NSError *error) {
        CXP_LOG(@"搜索错误:%@",error);
    }];
}

- (void)creatSearchUI{
    UIView *topView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenHeight, topViewHeigth)];
    topView.backgroundColor = kColor(245, 245, 245, 1);
    [self.view addSubview:topView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame     = CGRectMake(cancelBtnFrameX, 28, 50, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cancelBtn];
    
    self.searBar                    = [[UISearchBar alloc]initWithFrame:CGRectMake(-3, 28, cancelBtnFrameX + 5, 30)];
    self.searBar.tintColor          = [UIColor blueColor];//光标颜色
    self.searBar.layer.cornerRadius = 3.0f;
    self.searBar.placeholder        = @"搜索BP名称";
    self.searBar.returnKeyType      = UIReturnKeySearch;
    [self.view addSubview:self.searBar];
    
    //去掉搜索框背景
    for (UIView *subview in self.searBar.subviews)
    {
        for (UIView *inSubview in subview.subviews) {
            if ([inSubview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [inSubview removeFromSuperview];
                break;
            }
        }
    }
}

- (void)creatTableView{
    self.searchTableV = [[UITableView alloc] initWithFrame:CGRectMake(0, topViewHeigth, ScreenWidth, ScreenHeight - topViewHeigth) style:UITableViewStylePlain];
    
    [self.view addSubview:self.searchTableV];
}

//取消按钮
- (void)cancelBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *search = @"search";
    CXPSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:search];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CXPSearchCell" owner:self options:nil] lastObject];
    }
    
    CXPSearchModel *model;
    if (self.searchDataArray.count > indexPath.row) {
        model = [self.searchDataArray objectAtIndex:indexPath.row];
        [cell setModel:model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击某一行后 让颜色变回来
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    CXPBPReadViewController *BPReadVC   = [[CXPBPReadViewController alloc] init];
    CXPSearchModel *model               = self.searchDataArray[indexPath.row];

    BPReadVC.homeModel = (CXPHomeBPModel *)model;
    
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
                
                [weakSelf.searchTableV reloadData];
                
            }else{
                
            }
            
        } failure:^(NSError *error) {
            
        }];
        
    }
    
    [self.navigationController pushViewController:BPReadVC animated:YES];

}

#pragma mark - 在滑动手势删除某一行的时候，显示更多按钮
- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak __typeof(self)weakSelf = self;
    CXPSearchModel *model = self.searchDataArray[indexPath.row];
    NSString *titleString;
    if ([model.read isEqualToString:@"1"]) {
        titleString = @"标为未读";
    }else{
        titleString = @"标为已读";
    }
    UITableViewRowAction *noReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:titleString handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 切换已读未读状态
        CXPSearchModel *modelRead = self.searchDataArray[indexPath.row];
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
                [weakSelf.searchTableV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                
            }else{
                //修改失败 改回已未读状态
                CXP_LOG(@"修改已读未读失败!!!");
                if ([modelRead.read isEqualToString:@"2"]) {
                    modelRead.read = @"1";
                }else{
                    modelRead.read = @"2";
                }
                [weakSelf.searchTableV reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
            
        } failure:^(NSError *error) {
            CXP_LOG(@"修改已读未读错误:%@",error);
        }];
        
    }];
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //发送删除请求

        CXPSearchModel *model = [weakSelf.searchDataArray objectAtIndex:indexPath.row];
        NSDictionary *deleDcit = @{@"bpId"      :model.bpId,
                                   @"token"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]};
        
        [CXPHttpNetTool post:URL_BPDelete params:deleDcit success:^(id json) {
            NSDictionary *jsonDict = (NSDictionary *)json;
            if ([jsonDict[@"code"] isEqualToString:@"1"]) {

                //移除数据源index.row
                [weakSelf.searchDataArray removeObjectAtIndex:indexPath.row];
                [weakSelf.searchTableV deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }else{

            }
            
        } failure:^(NSError *error) {

            CXP_LOG(@"删除error:%@",error);
        }];
        
    }];
    
    return @[deleteAction, noReadAction];
}

- (void)setupdata{
    __weak __typeof(self)weakSelf = self;
    NSString *search = [[NSString stringWithFormat:URL_BPSearch,[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"],self.searBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [CXPHttpNetTool get:search params:nil success:^(id json) {
        
        if ([json[@"code"] isEqualToString:@"1"]) {
            //搜索请求成功  先清空数据源
            [weakSelf.searchDataArray removeAllObjects];
            
            NSDictionary *dataDict = json[@"data"];
            NSArray *listArray = dataDict[@"list"];
            for (NSDictionary *dict in listArray) {
                CXPSearchModel *model = [CXPSearchModel setupWithDict:dict];
                [weakSelf.searchDataArray addObject:model];
            }
            [weakSelf.searchTableV reloadData];
        }
        else{

        }
        
    } failure:^(NSError *error) {

    }];

}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchDataArray removeAllObjects];
    [self creatData];
    [self.searBar endEditing:YES];
}

#pragma mark - 懒加载
- (NSMutableArray *)searchDataArray{
    if (nil == _searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

- (void)dealloc{
    [self.searchDataArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh" object:nil];
}


@end
