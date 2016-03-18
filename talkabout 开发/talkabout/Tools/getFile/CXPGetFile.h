//
//  CXPGetFile.h
//  talkabout
//
//  Created by 于波 on 15/12/25.
//  Copyright © 2015年 于波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXPGetFile : NSObject
/**
 *  @brief  获得指定目录下，指定后缀名的文件列表
 *
 *  @param  type    文件后缀名
 *  @param  dirPath     指定目录
 *
 *  @return 文件名列表
 */
+(NSArray *) getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;


/**获取单个文件大小*/
+ (float) fileSizeAtPath:(NSString*) filePath;

@end
