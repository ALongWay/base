//
//  LevelDBHelper.h
//  base
//
//  Created by 李松 on 16/9/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelDB.h"

@interface LevelDBHelper : NSObject

/**
 *  根据名称获取levelDB对象，如果直接对db对象直接操作，最后务必手动关闭db
 *
 *  @param name 名称
 *
 *  @return return value description
 */
+ (LevelDB *)getLevelDBWithName:(NSString *)name;

/**
 *  获取某leveldb的key-value
 *
 *  @param key  key
 *  @param name db名称
 *
 *  @return value
 */
+ (id)objectForKey:(NSString *)key withName:(NSString *)name;

/**
 *  保存某对象到某leveldb的key下
 *
 *  @param object object description
 *  @param key    key description
 *  @param name   name description
 */
+ (void)setObject:(id)object forKey:(NSString *)key withName:(NSString *)name;

/**
 *  移除key对应的对象
 *
 *  @param object object description
 *  @param key    key description
 *  @param name   name description
 */
+ (void)removeObject:(id)object forKey:(NSString *)key withName:(NSString *)name;

/**
 *  清除全部levelDB缓存数据
 */
+ (void)clearAllLevelDBFileCache;

/**
 *  清除特定名字的levelDB文件
 *
 *  @param name levelDB文件名
 */
+ (void)clearLevelDBFileCacheWithName:(NSString *)name;

@end
