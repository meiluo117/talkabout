//
//  CXPBPImportExplain.m
//  talkabout
//
//  Created by 于波 on 16/1/9.
//  Copyright © 2016年 于波. All rights reserved.
//
typedef NS_ENUM(NSInteger,bpImportExplain) {
    bpImportFromEmail      = 0,
    bpImportFromWechat     = 1,
    bpImportFromQQ         = 2,
    bpImportFromComputer   = 3
};

#import "CXPBPImportExplain.h"

@implementation CXPBPImportExplain

+ (NSString *)bpImport:(bpImportExplain)explainIndex{
    
    switch (explainIndex) {
        case bpImportFromEmail:
            return [NSString stringWithFormat:URLOther_Explain_Email];
            break;
        case bpImportFromWechat:
            return [NSString stringWithFormat:URLOther_Explain_Wechat];
            break;
        case bpImportFromQQ:
            return [NSString stringWithFormat:URLOther_Explain_QQ];
            break;
        case bpImportFromComputer:
            return [NSString stringWithFormat:URLOther_Explain_PC];
            break;
    }
}

+ (NSString *)bpImportTitle:(bpImportExplain)explainIndex{
    
    switch (explainIndex) {
        case bpImportFromEmail:
            return @"邮箱导入说明";
            break;
        case bpImportFromWechat:
            return @"微信导入说明";
            break;
        case bpImportFromQQ:
            return @"QQ导入说明";
            break;
        case bpImportFromComputer:
            return @"电脑导入说明";
            break;
    }
}

@end
