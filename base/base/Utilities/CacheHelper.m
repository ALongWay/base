//
//  CacheHelper.m
//  base
//
//  Created by 李松 on 16/9/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "CacheHelper.h"

@implementation CacheHelper

+ (NSString *)getAppArchivedFilesRootPath
{
    NSString *filename = AppArchivedFilesRootFile;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [paths[0] stringByAppendingPathComponent:filename];
    
    return rootPath;
}

+ (NSString *)getAppArchivedFileFullPathWithName:(NSString *)filename
{
    NSString *rootPath = [self getAppArchivedFilesRootPath];
    NSString *fullPath = [rootPath stringByAppendingPathComponent:filename];
    
    return fullPath;
}

+ (void)createArchivedRootFile
{
    NSString *rootPath = [self getAppArchivedFilesRootPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)clearAllArchivedFiles
{
    NSString *rootPath = [self getAppArchivedFilesRootPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self getAppArchivedFilesRootPath] error:nil];
    }
    
    [self createArchivedRootFile];
}

+ (void)clearArchivedFileWithName:(NSString *)filename
{
    NSString *rootPath = [self getAppArchivedFilesRootPath];
    NSString *fullPath = [rootPath stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
}

+ (void)archiveDataWithDictionary:(NSDictionary *)dic filename:(NSString *)filename archiveSuccessBlock:(archiveSuccessBlock)archiveSuccessBlock
{
    NSString *fullPath = [self getAppArchivedFileFullPathWithName:filename];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        
        NSArray *keyArray = [NSArray arrayWithArray:[dic allKeys]];
        [archiver encodeObject:keyArray forKey:filename];
        
        for (NSString *key in keyArray) {
            NSObject *object = [dic objectForKey:key];
            [archiver encodeObject:object forKey:key];
        }
        
        [archiver finishEncoding];
        [data writeToFile:fullPath atomically:YES];
        
        if (archiveSuccessBlock) {
            archiveSuccessBlock();
        }
    });
}

+ (NSDictionary *)unarchiveDataWithFilename:(NSString *)filename
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self getAppArchivedFileFullPathWithName:filename]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSArray *keyArray = [NSArray arrayWithArray:[unarchiver decodeObjectForKey:filename]];
    
    for (NSString *key in keyArray) {
        NSObject *object = [unarchiver decodeObjectForKey:key];
        [dic setObject:object forKey:key];
    }
    
    [unarchiver finishDecoding];

    return dic;
}

@end
