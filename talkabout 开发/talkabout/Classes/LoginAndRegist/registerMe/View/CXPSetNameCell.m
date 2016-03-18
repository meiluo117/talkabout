//
//  CXPSetNameCell.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPSetNameCell.h"

@implementation CXPSetNameCell

- (void)awakeFromNib {
    [self creatUI];
}

- (void)creatUI{
    self.infoTextF.userInteractionEnabled = YES;
    self.infoTextF.enabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
