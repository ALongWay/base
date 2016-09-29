//
//  HttpHelper.h
//  base
//
//  Created by 李松 on 16/9/29.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HttpHelperMethod){
    Get,
    Post,
    Put,
    Delete,
    Patch,
    Head,
};

@interface HttpHelper : NSObject

/**
 *  当前保留的manager
 */
@property (nonatomic, strong, readonly) AFHTTPSessionManager *currentHttpSessionManager;

+ (HttpHelper *)sharedManager;

/**
 *  网络请求自动调用该方法，每次调用，创建新的自定义的httpSessionManager，刷新currentHttpSessionManager
 *  该方法也可用于自行调用AFHTTPSessionManager的方法
 *
 *  @return return value description
 */
+ (AFHTTPSessionManager *)getCustomHttpSessionManager;

/**
 *  在baseUrl基础上，拼接接口路由名称，得到完整url字符串
 *
 *  @param apiRoute 接口路由名称
 *
 *  @return return value description
 */
+ (NSString *)getCompletedUrlStringWithApiRoute:(NSString *)apiRoute;

/**
 *  通用的网络请求方法，只有get和post方法具有progress块，并且可为nil
 *
 *  @param method     method description
 *  @param apiRoute   接口路由名称
 *  @param parameters parameters description
 *  @param progress   progress description
 *  @param success    success description
 *  @param failure    failure description
 *
 *  @return return value description
 */
+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                                  apiRoute:(NSString *)apiRoute
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *progress))progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  通用的网络请求方法，只有get和post方法具有progress块，并且可为nil
 *
 *  @param method     method description
 *  @param URLString  完整url字符串
 *  @param parameters parameters description
 *  @param progress   progress description
 *  @param success    success description
 *  @param failure    failure description
 *
 *  @return return value description
 */
+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                                  urlString:(NSString *)URLString
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *progress))progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  上传单个图像
 *
 *  @param image          image description
 *  @param uploadProgress uploadProgress description
 *  @param success        success description
 *  @param failure        failure description
 *
 *  @return return value description
 */
+ (NSURLSessionDataTask *)uploadImage:(UIImage *)image
                              progress:(void (^)(NSProgress *uploadProgress))uploadProgress
                               success:(void (^)(NSURLSessionDataTask *task, NSString *imageUrlString))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  上传多个图像
 *
 *  @param images   图像数组
 *  @param progress 进度
 *  @param success  success description
 *  @param failure  failure description
 */
+ (void)uploadImages:(NSArray<UIImage*> *)images
                              progress:(void (^)(NSInteger uploadedCount, NSInteger totalCount))progress
                                success:(void (^)(NSArray<NSString*> *uploadedImageUrls, NSArray<UIImage*> *failureImages))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
