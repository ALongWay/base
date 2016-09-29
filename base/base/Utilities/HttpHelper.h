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

+ (HttpHelper *)sharedManager;

+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                                urlString:(NSString *)URLString
                                 parameters:(id)parameters
                                   progress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
