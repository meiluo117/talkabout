//
//  CXPHomeCell.m
//  talkabout
//
//  Created by 于波 on 15/12/22.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPHomeCell.h"
#import "CXPHomeBPModel.h"
#import "CXPBPFileTypeStatusColor.h"

@implementation CXPHomeCell

- (void)awakeFromNib {
    // Initialization code
    [self creatUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)creatUI{
    self.backgroundColor = kColor(242, 242, 242, 1);
    self.backImage.layer.cornerRadius = 12;
    self.statusLable.textColor = [UIColor whiteColor];
}

- (void)setModel:(CXPHomeBPModel *)model{
    _model = model;
    self.titleLable.text = model.bpName;
    
    if ([model.read isEqualToString:@"2"]) {  //2是未读
        self.titleLable.textColor = [UIColor blackColor];
    }else{
        self.titleLable.textColor = [UIColor grayColor];
    }
    
    self.statusLable.text = model.statusName;
    self.iconImage.image  = [CXPBPFileTypeStatusColor bpFileTypeStr:model.fileType];
    self.backImage.image  = [CXPBPFileTypeStatusColor bpStatusColor:[model.status integerValue]];
}

@end
