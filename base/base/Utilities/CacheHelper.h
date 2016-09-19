//
//  CacheHelper.h
//  base
//
//  Created by 李松 on 16/9/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^archiveSuccessBlock)(void);

#define AppArchivedFilesRootFile            @"appArchivedFiles"

#define PersonalInfoArchivedFileName        @"personalInfo.archiver"

@interface CacheHelper : NSObject

/**
 *  获取归档文件根目录路径
 *
 *  @return 路径
 */
+ (NSString *)getAppArchivedFilesRootPath;

/**
 *  根据归档文件名称，获取文件路径
 *
 *  @param filename 文件名
 *
 *  @return 路径
 */
+ (NSString *)getAppArchivedFileFullPathWithName:(NSString *)filename;

/**
 *  创建归档根文件目录
 */
+ (void)createArchivedRootFile;

/**
 *  清除全部归档
 */
+ (void)clearAllArchivedFiles;

/**
 *  根据归档文件名，清除归档文件
 *
 *  @param filename 文件名
 */
+ (void)clearArchivedFileWithName:(NSString *)filename;

/**
 *  归档文件
 *
 *  @param dic      字典数据
 *  @param filename 文件名
 *  @param archiveSuccessBlock archiveSuccessBlock
 */
+ (void)archiveDataWithDictionary:(NSDictionary *)dic filename:(NSString *)filename archiveSuccessBlock:(archiveSuccessBlock)archiveSuccessBlock;

/**
 *  解档文件
 *
 *  @param filename 文件名
 *
 *  @return 字典数据
 */
+ (NSDictionary *)unarchiveDataWithFilename:(NSString *)filename;

@end
