//
//  LevelDBHelper.m
//  base
//
//  Created by 李松 on 16/9/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "LevelDBHelper.h"

@implementation LevelDBHelper

+ (LevelDB *)getLevelDBWithName:(NSString *)name
{
    LevelDB *ldb = [LevelDB databaseInDocumentWithName:name];
    
    ldb.encoder = ^NSData* (LevelDBKey * key, id object){
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:[NSString stringWithUTF8String:key->data]];
        [archiver finishEncoding];
        archiver = nil;
        return data;
    };
    
    ldb.decoder = ^ id (LevelDBKey *key, NSData * data) {
        // return an object, given some data
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        id object = [unarchiver decodeObjectForKey:[NSString stringWithUTF8String:key->data]];
        [unarchiver finishDecoding];
        unarchiver = nil;
        return object;
    };
    
    return ldb;
}

+ (id)objectForKey:(NSString *)key withName:(NSString *)name
{
    LevelDB *db = [self getLevelDBWithName:name];
    id object = [db objectForKey:key];
    [db close];
    
    return object;
}

+ (void)setObject:(id)object forKey:(NSString *)key withName:(NSString *)name
{
    LevelDB *db = [self getLevelDBWithName:name];
    [db setObject:object forKey:key];
    [db close];
}

+ (void)removeObject:(id)object forKey:(NSString *)key withName:(NSString *)name
{
    LevelDB *db = [self getLevelDBWithName:name];
    [db removeObjectForKey:key];
    [db close];
}

+ (void)clearAllLevelDBFileCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:LevelDBRootFile];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:rootPath error:nil];
    }
}

+ (void)clearLevelDBFileCacheWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:LevelDBRootFile];
    NSString *filePath = [rootPath stringByAppendingString:name];
 
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
