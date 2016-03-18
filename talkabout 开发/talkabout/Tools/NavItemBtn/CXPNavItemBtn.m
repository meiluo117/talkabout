//
//  CXPNavItemBtn.m
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPNavItemBtn.h"

@implementation CXPNavItemBtn
+ (UIButton*)btnWithWidth:(float)Width height:(float)Height andBtnName:(NSString *)btnName{
    
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame        = CGRectMake(0, 0, Width, Height);
    
    [button setImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
    
    return button;
}

+ (UIButton*)btnWithWidth:(float)Width height:(float)Height BtnTitle:(NSString *)btnTitle BtnFont:(CGFloat)btnFont andBtnTitleColor:(UIColor *)btnTitleColor{
    
    UIButton *button        = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.titleLabel.font  = [UIFont systemFontOfSize:btnFont];
    
    [button setTitleColor:btnTitleColor forState:UIControlStateNormal];
    
    button.frame            = CGRectMake(0, 0, Width, Height);
    
    [button setTitle:btnTitle forState:UIControlStateNormal];
    
    return button;
}
@end
