//
//  CXPMessageViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPMessageViewController.h"
#import "CXPNavItemBtn.h"
#import "CXPSystemTime.h"

@interface CXPMessageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation CXPMessageViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self creatBarButtonItem];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self creatBarButtonItem];
//    
//    self.tableV.delegate   = self;
//    self.tableV.dataSource = self;
//    
//    //伪数据
//    for (int i = 0; i < 10; i++) {
//        NSString *string = [NSString stringWithFormat:@"我是第%d行,点我呀",i];
//        [self.dataArray addObject:string];
//    }
//}
//
//自定义nav
- (void)creatBarButtonItem{
    UIButton *buttn                         = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [buttn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:buttn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    self.navigationItem.title               = @"消息";
    buttn.tag                               = 10000;
}

//返回按钮
- (void)backClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - UITableViewDelegate
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.dataArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *message = @"message";
//    UITableViewCell *cell    = [tableView dequeueReusableCellWithIdentifier:message];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:message];
//    }
//    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%@",[CXPSystemTime getSystemTime]];
//    cell.textLabel.text         = _dataArray[indexPath.row];
//    cell.imageView.image        = [UIImage imageNamed:@"head@2x"];
//    //设置向右的箭头
//    cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
//    return cell;
//}
//
////设置cell的高度
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 80;
//}
//
////点击 cell的代理方法
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    //点击某一行后 让颜色变回来
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    CXP_LOG(@"你点击了第%ld行",(long)indexPath.row);
//}
//
//#pragma mark - 懒加载
//- (NSMutableArray *)dataArray{
//    if (_dataArray == nil) {
//        _dataArray = [NSMutableArray array];
//    }
//    return _dataArray;
//}



@end
