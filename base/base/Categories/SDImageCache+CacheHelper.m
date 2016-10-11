//
//  SDImageCache+CacheHelper.m
//  base
//
//  Created by lisong on 16/10/11.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "SDImageCache+CacheHelper.h"
#import <objc/runtime.h>

@implementation SDImageCache (CacheHelper)

+ (void)load
{
    __weak typeof(self) weakSelf = self;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [weakSelf swizzleOriginalSelector:@selector(init) withNewSelector:@selector(base_init)];
    });
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Class selfClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method newMethod = class_getInstanceMethod(selfClass, newSelector);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    //先用新的IMP加到原始SEL中
    BOOL addSuccess = class_addMethod(selfClass, originalSelector, newIMP, method_getTypeEncoding(newMethod));
    if (addSuccess) {
        class_replaceMethod(selfClass, newSelector, originalIMP, method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (instancetype)base_init
{
    id instance = [self base_init];
    
    [self resetCustomImageCachePath];
    
    return instance;
}

/**
 *  自定义图片缓存路径
 */
- (void)resetCustomImageCachePath {
    //reset the memory cache
    NSString *rootDirectory = kAppImageCacheRootDirectory;
    NSCache *memCache = (NSCache *)[self valueForKey:@"memCache"];
    memCache.name = rootDirectory;
    
    //reset the disk cache
    NSString *path = [self makeDiskCachePath:rootDirectory];
    [self setValue:path forKey:@"diskCachePath"];
}
@end
