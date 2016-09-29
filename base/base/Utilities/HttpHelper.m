//
//  HttpHelper.m
//  base
//
//  Created by 李松 on 16/9/29.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "HttpHelper.h"

static HttpHelper *instance;

@implementation HttpHelper

+ (HttpHelper *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HttpHelper alloc] init];
    });
    
    return instance;
}

+ (NSURLSessionDataTask *)requestWithMethod:(HttpHelperMethod)method
                            urlString:(NSString *)URLString
                             parameters:(id)parameters
                               progress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    switch (method) {
        case Get: {
            
            break;
        }
        case Post: {
            
            break;
        }
        case Put: {
            
            break;
        }
        case Delete: {
            
            break;
        }
        case Patch: {
            
            break;
        }
        case Head: {
            
            break;
        }
    }

    return nil;
}

@end
