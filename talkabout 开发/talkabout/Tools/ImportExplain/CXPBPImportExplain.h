//
//  CXPBPImportExplain.h
//  talkabout
//
//  Created by 于波 on 16/1/9.
//  Copyright © 2016年 于波. All rights reserved.
//
typedef NS_ENUM(NSInteger,bpImportExplain);

#import <Foundation/Foundation.h>

@interface CXPBPImportExplain : NSObject

+ (NSString *)bpImport:(bpImportExplain)explainIndex;

+ (NSString *)bpImportTitle:(bpImportExplain)explainIndex;
@end
