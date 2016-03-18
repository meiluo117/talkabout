//
//  CXPSearchCell.h
//  talkabout
//
//  Created by 于波 on 16/1/6.
//  Copyright © 2016年 于波. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CXPSearchModel;

@interface CXPSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;//bp文档格式
@property (weak, nonatomic) IBOutlet UILabel *titleLable;//bp标题
@property (weak, nonatomic) IBOutlet UIImageView *backImage;//状态背景颜色
@property (weak, nonatomic) IBOutlet UILabel *statusLable;//bp状态

@property (nonatomic,strong)CXPSearchModel *model;
@end
