//
//  HttpHelper.m
//  base
//
//  Created by 李松 on 16/9/29.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "HttpHelper.h"

#define kMaxUploadImageSize         (2 * 1024 * 1024) //2M

//http头部中的User-Agent值
static NSString * const kUserAgent = @"useragent";//示例值

static HttpHelper *instance;

@interface HttpHelper ()

@end

@implementation HttpHelper

- (instancetype)init
{
    return [HttpHelper sharedManager];
}

+ (HttpHelper *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HttpHelper alloc] init];
    });
    
    return instance;
}

+ (AFHTTPSessionManager *)getCustomHttpSessionManager
{
    AFHTTPSessionManager  *manager = [AFHTTPSessionManager manager];
    //增加自定义配置
//    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager.requestSerializer setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return manager;
}

+ (NSString *)getCompletedUrlStringWithApiRoute:(NSString *)apiRoute
{
    NSString *urlString = kURLBaseUrlString;
    urlString = [urlString stringByAppendingPathComponent:apiRoute];
    
    return urlString;
}

+ (AFHTTPSessionManager *)requestWithMethod:(HttpHelperMethod)method
                                   apiRoute:(NSString *)apiRoute
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *progress))progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
{
    return [self requestWithMethod:method urlString:[self getCompletedUrlStringWithApiRoute:apiRoute] parameters:parameters progress:progress success:success failure:failure];
}

+ (AFHTTPSessionManager *)requestWithMethod:(HttpHelperMethod)method
                                  urlString:(NSString *)URLString
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *progress))progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //对参数做统一处理
    //To do
    
    AFHTTPSessionManager *manager = [self getCustomHttpSessionManager];
    
    NSURLSessionDataTask *task;
    
    switch (method) {
        case Get: {
            task = [manager GET:URLString parameters:parameters progress:progress success:success failure:failure];
            break;
        }
        case Post: {
            task = [manager POST:URLString parameters:parameters progress:progress success:success failure:failure];
            break;
        }
        case Put: {
            task = [manager PUT:URLString parameters:parameters success:success failure:success];
            break;
        }
        case Delete: {
            task = [manager DELETE:URLString parameters:parameters success:success failure:failure];
            break;
        }
        case Patch: {
            task = [manager PATCH:URLString parameters:parameters success:success failure:failure];
            break;
        }
        case Head: {
            task = [manager HEAD:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                success(task, nil);
            } failure:failure];
            break;
        }
    }

    return manager;
}

#pragma mark -- 上传图片
NSString * const kUploadImageDataFieldName = @"data";
NSString * const kUploadImageMimeType = @"image/jpeg";

+ (NSString *)getUploadImageFilename:(UIImage *)image
{
    NSString *dateString = [StringHelper getCurrentDateStringWithFormat:@"yyyyMMddHHmmssS"];
    NSString *fileName = [NSString stringWithFormat:@"%@_%ldx%ld", dateString, (long)image.size.width, (long)image.size.height];

    return fileName;
}

+ (NSDictionary *)getUploadImageParameters
{
    //对参数做统一处理
    //To do

    return nil;
}

+ (NSData *)getUploadImageDataWithUploadImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    
    if (data.length > kMaxUploadImageSize) {
        data = UIImageJPEGRepresentation(image, 0.7);//减小图像数据体积
    }

    return data;
}

/**
 *  获取访问图片的地址
 *
 *  @param dic dic description
 *
 *  @return return value description
 */
+ (NSString *)getUploadedImageUrlStringWithDictionary:(NSDictionary *)dic
{
    NSString *imageUrlString = [StringHelper getSafeDecodeStringFromJsonValue:[dic objectForKey:@"url"]];//示例键值

    return imageUrlString;
}

+ (AFHTTPSessionManager *)uploadImage:(UIImage *)image
                             progress:(void (^)(NSProgress *progress))progress
                              success:(void (^)(NSURLSessionDataTask *task, NSString *imageUrlString))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [self getCustomHttpSessionManager];
    
    __weak typeof(self) weakSelf = self;
    [manager POST:kURLUploadImage parameters:[self getUploadImageParameters] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [weakSelf getUploadImageDataWithUploadImage:image];
        NSString *fileName = [weakSelf getUploadImageFilename:image];
        
        [formData appendPartWithFileData:data name:kUploadImageDataFieldName fileName:fileName mimeType:kUploadImageMimeType];
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *imageUrlString = [weakSelf getUploadedImageUrlStringWithDictionary:responseObject];
        success(task, imageUrlString);
    } failure:failure];
    
    return manager;
}

+ (AFHTTPSessionManager *)uploadImages:(NSArray<UIImage*> *)images
                              progress:(void (^)(NSInteger uploadedCount, NSInteger totalCount))progress
                               success:(void (^)(NSArray<NSString*> *uploadedImageUrls, NSArray<UIImage*> *failureImages))success
                               failure:(void (^)(void))failure
{
    __block AFHTTPSessionManager *manager = [self getCustomHttpSessionManager];
    
    NSArray* uploadImagesArray = [NSArray arrayWithArray:images];
    
    if (uploadImagesArray.count > 0) {
        NSMutableArray *successArray = [NSMutableArray array];
    
        for (int i = 0; i < uploadImagesArray.count; i++) {
            [successArray addObject:@" "];
        }
        
        NSMutableArray *failureArray = [NSMutableArray array];
        
        __block NSInteger completedCount = 0;
        
        void (^completionBlock)() = ^{
            for (int i = 0; i < successArray.count; i++) {
                if ([[successArray objectAtIndex:i] isEqualToString:@" "]) {
                    [successArray removeObjectAtIndex:i];
                }
            }
            
            success(successArray,failureArray);
        };
                
        //采用了并发上传
        __weak typeof(self) weakSelf = self;
        
        for (int i = 0; i < uploadImagesArray.count; i++) {
            UIImage *image = [uploadImagesArray objectAtIndex:i];
            
            [manager POST:kURLUploadImage parameters:[self getUploadImageParameters] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSData *data = [weakSelf getUploadImageDataWithUploadImage:image];
                NSString *fileName = [weakSelf getUploadImageFilename:image];
                
                [formData appendPartWithFileData:data name:kUploadImageDataFieldName fileName:fileName mimeType:kUploadImageMimeType];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                //可以增加计算整体的上传百分比逻辑
                //To do
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completedCount++;
                
                progress(completedCount, uploadImagesArray.count);
                
                //保存返回的url
                NSString *imageUrlString = [weakSelf getUploadedImageUrlStringWithDictionary:responseObject];
                [successArray replaceObjectAtIndex:i withObject:imageUrlString];
                
                if (completedCount == uploadImagesArray.count) {
                    completionBlock();
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completedCount++;
                
                [failureArray addObject:[uploadImagesArray objectAtIndex:i]];
                
                if (completedCount == uploadImagesArray.count) {
                    completionBlock();
                }
            }];
        }
    }else{
        failure();
    }
    
    return manager;
}

@end
