//
//  CXPNavItemBtn.h
//  talkabout
//
//  Created by 于波 on 15/12/17.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXPNavItemBtn : NSObject
+ (UIButton*)btnWithWidth:(float)Width
                   height:(float)Height
               andBtnName:(NSString *)btnName;

+ (UIButton*)btnWithWidth:(float)Width
                   height:(float)Height
                 BtnTitle:(NSString *)btnTitle
                  BtnFont:(CGFloat)btnFont
         andBtnTitleColor:(UIColor *)btnTitleColor;
@end
