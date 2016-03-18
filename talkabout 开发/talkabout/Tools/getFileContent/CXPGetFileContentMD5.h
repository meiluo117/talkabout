//
//  CXPGetFileContentMD5.h
//  talkabout
//
//  Created by 于波 on 16/1/4.
//  Copyright © 2016年 于波. All rights reserved.
//

#define FileHashDefaultChunkSizeForReadingData 1024*8
#import <Foundation/Foundation.h>

@interface CXPGetFileContentMD5 : NSObject

/**得到文件内容md5 传入绝对路径*/
+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
