//
//  CXPSetCardImageCell.m
//  talkabout
//
//  Created by 于波 on 16/1/25.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "CXPSetCardImageCell.h"

@implementation CXPSetCardImageCell

- (void)awakeFromNib {
    [self creatUI];
}

- (void)creatUI{
    self.cardImageV.userInteractionEnabled  = YES;
    self.cardImageV.layer.masksToBounds     = YES;
    self.cardImageV.layer.cornerRadius      = 3.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
