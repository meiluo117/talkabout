//
//  CXPBPFileTypeStatusColor.m
//  talkabout
//
//  Created by 于波 on 15/12/24.
//  Copyright © 2015年 于波. All rights reserved.
//

typedef NS_ENUM(NSInteger, bpStatusType) {
    bpStatusTypeUnknow      = 0,   //错误
    bpStatusTypeStart       = 1,   //开始
    bpStatusTypeTouch       = 2,   //约谈
    bpStatusTypeIntention   = 3,   //意向
    bpStatusTypeJinDiao     = 4,   //尽调
    bpStatusTypeSigned      = 5,   //签约
    bpStatusTypePay         = 6,   //打款
    bpStatusTypeStock       = 7,   //变更
    bpStatusTypeEnd         = 8,   //结束
    bpStatusTypeGiveUp      = 9    //放弃
};

//typedef NS_ENUM(NSInteger, bpFileType) {
//    bpFileTypeUnknow    = 0,
//    bpFileTypePDF       = 1,
//    bpFileTypePPT       = 2,
//    bpFileTypeWORD      = 3
//};

#import "CXPBPFileTypeStatusColor.h"

@implementation CXPBPFileTypeStatusColor

+ (UIImage *)bpFileTypeStr:(NSString *)fileTypeStr{
    
    if ([fileTypeStr isEqualToString:@"doc"] || [fileTypeStr isEqualToString:@"docx"]) {

        return [UIImage imageNamed:@"word"];
        
    }else if ([fileTypeStr isEqualToString:@"ppt"] || [fileTypeStr isEqualToString:@"pptx"]){
        
        return [UIImage imageNamed:@"PPT"];
        
    }else if ([fileTypeStr isEqualToString:@"pdf"]){
        
        return [UIImage imageNamed:@"PDF"];
    }else{
        
        return nil;
    }

}

+ (UIImage *)bpStatusColor:(bpStatusType)statusType{
    switch (statusType) {
        case bpStatusTypeUnknow:
            return [UIImage imageNamed:@"typeStart"];
            break;
        case bpStatusTypeStart:
            return [UIImage imageNamed:@"typeStart"];
            break;
        case bpStatusTypeTouch:
            return [UIImage imageNamed:@"typeTouch"];
            break;
        case bpStatusTypeIntention:
            return [UIImage imageNamed:@"typeIntention"];
            break;
        case bpStatusTypeJinDiao:
            return [UIImage imageNamed:@"typeJinDiao"];
            break;
        case bpStatusTypeSigned:
            return [UIImage imageNamed:@"typeSigned"];
            break;
        case bpStatusTypePay:
            return [UIImage imageNamed:@"typePay"];
            break;
        case bpStatusTypeStock:
            return [UIImage imageNamed:@"typeStock"];
            break;
        case bpStatusTypeEnd:
            return [UIImage imageNamed:@"typeEnd"];
            break;
        case bpStatusTypeGiveUp:
            return [UIImage imageNamed:@"typeGiveUp"];
            break;
    }
}

@end
