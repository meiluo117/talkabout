//
//  CXPSetHeaderImageCell.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPSetHeaderImageCell.h"

@implementation CXPSetHeaderImageCell

- (void)awakeFromNib {
    [self creatUI];
}

- (void)creatUI{
    self.headerImageV.layer.masksToBounds       = YES;
    self.headerImageV.layer.cornerRadius        = 3.0;
    self.headerImageV.userInteractionEnabled    = YES;
    
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
