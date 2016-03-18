//
//  CXPMD5.m
//  pickerView练习
//
//  Created by 于波 on 15/12/4.
//  Copyright © 2015年 于波. All rights reserved.
//

#import "CXPMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CXPMD5

+(NSString *)md5:(NSString *)inPutText
{
    const char *original_str = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
