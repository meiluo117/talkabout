//
//  headerCell.m
//  talkabout
//
//  Created by 于波 on 16/2/1.
//  Copyright © 2016年 于波. All rights reserved.
//

#import "headerCell.h"

@implementation headerCell

- (void)awakeFromNib {
    // Initialization code
    self.headimage.userInteractionEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
