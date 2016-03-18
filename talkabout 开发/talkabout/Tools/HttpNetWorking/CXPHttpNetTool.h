//
//  CXPHttpNetTool.h
//  pickerView练习
//
//  Created by 于波 on 15/12/13.
//  Copyright © 2015年 于波. All rights reserved.
//

@interface CXPHttpNetTool : NSObject

/**
 *  发送GET请求
 *
 *  @param url     请求链接
 *  @param params  请求参数
 *  @param success 请求成功
 *  @param failure 请求失败
 */
+ (void)get:(NSString *)url
     params:(NSDictionary *)params
    success:(void (^)(id json))success
    failure:(void (^)(NSError *error))failure;

/**
 *  发送POST请求
 */
+ (void)post:(NSString *)url
      params:(NSDictionary *)params
     success:(void (^)(id json))success
     failure:(void (^)(NSError *error))failure;

/**
 *  添加进度条
 */
+ (void)post:(NSString *)url
      params:(NSDictionary *)params
     success:(void (^)(id json))success
     failure:(void (^)(NSError *error))failure view:(UIView*)view;

/**
 *  发送POST请求(带文件参数)
 */
+ (void)post:(NSString *)url
      params:(NSDictionary *)params
        data:(NSData *)data
        name:(NSString*)name
    fileName:(NSString*)fileName
    mimeType:(NSString*)mimeType
     success:(void (^)(id json))success
     failure:(void (^)(NSError *error))failure;

@end
