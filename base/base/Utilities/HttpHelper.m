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
static NSString * const userAgent = @"useragent";//示例值

static HttpHelper *instance;

@interface HttpHelper ()

@property (nonatomic, strong, readwrite) AFHTTPSessionManager *currentHttpSessionManager;

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
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [HttpHelper sharedManager].currentHttpSessionManager = manager;
    
    return manager;
}

+ (NSString *)getCompletedUrlStringWithApiRoute:(NSString *)apiRoute
{
    NSString *urlString = kURLBaseUrlString;
    urlString = [urlString stringByAppendingPathComponent:apiRoute];
    
    return urlString;
}

+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                                   apiRoute:(NSString *)apiRoute
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *))progress
                                    success:(void (^)(NSURLSessionDataTask *, id))success
                                    failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self requestWithMethod:method urlString:[self getCompletedUrlStringWithApiRoute:apiRoute] parameters:parameters progress:progress success:success failure:failure];
}

+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                                  urlString:(NSString *)URLString
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *progress))progress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //对参数做统一处理
    //To do
    
    NSURLSessionDataTask *task;
    
    switch (method) {
        case Get: {
            task = [[self getCustomHttpSessionManager] GET:URLString parameters:parameters progress:progress success:success failure:failure];
            break;
        }
        case Post: {
            task = [[self getCustomHttpSessionManager] POST:URLString parameters:parameters progress:progress success:success failure:failure];
            break;
        }
        case Put: {
            task = [[self getCustomHttpSessionManager] PUT:URLString parameters:parameters success:success failure:success];
            break;
        }
        case Delete: {
            task = [[self getCustomHttpSessionManager] DELETE:URLString parameters:parameters success:success failure:failure];
            break;
        }
        case Patch: {
            task = [[self getCustomHttpSessionManager] PATCH:URLString parameters:parameters success:success failure:failure];
            break;
        }
        case Head: {
            task = [[self getCustomHttpSessionManager] HEAD:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                success(task, nil);
            } failure:failure];
            break;
        }
    }

    return task;
}

+ (NSURLSessionDataTask *)uploadImage:(UIImage *)image
                             progress:(void (^)(NSProgress *progress))progress
                              success:(void (^)(NSURLSessionDataTask *task, NSString *imageUrlString))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //增加参数
    //To do
    
    NSString *uploadImageUrlString = kURLUploadImage;
    
    NSURLSessionDataTask *manager = [[self getCustomHttpSessionManager] POST:uploadImageUrlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(image, 1);
        
        if (data.length > kMaxUploadImageSize) {
            data = UIImageJPEGRepresentation(image, 0.7);//减小图像数据体积
        }
        
        NSString *dateString = [StringHelper getCurrentDateStringWithFormat:@"yyyyMMddHHmmssS"];
        NSString *fileName = [NSString stringWithFormat:@"%@_%ldx%ld", dateString, (long)image.size.width, (long)image.size.height];
        
        [formData appendPartWithFileData:data name:@"data" fileName:fileName mimeType:@"image/jpeg"];
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //获取访问图片的地址
        NSString *imageUrlString = [StringHelper getSafeDecodeStringFromJsonValue:[responseObject objectForKey:@"url"]];//示例键值
        success(task, imageUrlString);
    } failure:failure];
    
    return manager;
}

+ (void)uploadImages:(NSArray<UIImage*> *)images
                              progress:(void (^)(NSInteger uploadedCount, NSInteger totalCount))progress
                                success:(void (^)(NSArray<NSString*> *uploadedImageUrls, NSArray<UIImage*> *failureImages))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
{    
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
//        for (int i = 0; i < uploadImagesArray.count; i++) {
//            [self uploadImage:[uploadImagesArray objectAtIndex:i] progress:^(NSProgress *uploadProgress) {
//                //可以增加计算整体的上传百分比逻辑
//                //To do
//            } success:^(NSURLSessionDataTask *task, NSString *imageUrlString) {
//                completedCount++;
//
//                progress(completedCount, uploadImagesArray.count);
//                
//                //保存返回的url
//                [successArray replaceObjectAtIndex:i withObject:imageUrlString];
//                
//                if (completedCount == uploadImagesArray.count) {
//                    completionBlock();
//                }
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                completedCount++;
//
//                [failureArray addObject:[uploadImagesArray objectAtIndex:i]];
//                
//                if (completedCount == uploadImagesArray.count) {
//                    completionBlock();
//                }
//            }];
//        }
        
        //=======================================
        //使用GCD
        dispatch_group_t uploadGroup = dispatch_group_create();
        dispatch_queue_t uploadQueue = dispatch_queue_create("uploadimagesqueue", DISPATCH_QUEUE_CONCURRENT);
        
        WeakSelf(weakSelf);
        
        for (int i = 0; i < uploadImagesArray.count; i++) {
            dispatch_group_async(uploadGroup, uploadQueue, ^{
                [weakSelf uploadImage:[uploadImagesArray objectAtIndex:i] progress:^(NSProgress *uploadProgress) {
                    //可以增加计算整体的上传百分比逻辑
                    //To do
                } success:^(NSURLSessionDataTask *task, NSString *imageUrlString) {
                    completedCount++;
                    
                    progress(completedCount, uploadImagesArray.count);
                    
                    //保存返回的url
                    [successArray replaceObjectAtIndex:i withObject:imageUrlString];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    completedCount++;
                    
                    [failureArray addObject:[uploadImagesArray objectAtIndex:i]];
                }];
            });
        }
        
        dispatch_group_notify(uploadGroup, uploadQueue, ^{
            completionBlock();
        });
    }else{
        failure(nil, nil);
    }
}

@end
