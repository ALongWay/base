//
//  EncryptionHelper.h
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptionHelper : NSObject

+ (NSString *)base64EncodeWithString:(NSString *)string;

+ (NSString *)decodeBase64WithString:(NSString *)string;

+ (NSString *)MD2SumWithString:(NSString *)string;

+ (NSString *)MD4SumWithString:(NSString *)string;

+ (NSString *)MD5SumWithString:(NSString *)string;

+ (NSString *)SHA1HashWithString:(NSString *)string;

+ (NSString *)SHA224HashWithString:(NSString *)string;

+ (NSString *)SHA256HashWithString:(NSString *)string;

+ (NSString *)SHA384HashWithString:(NSString *)string;

+ (NSString *)SHA512HashWithString:(NSString *)string;

#pragma mark --【AES和DES加密过程：string -> data -> AES/DES encrypt -> base64 encode -> string;解密过程为逆向
+ (NSString *)AES256EncryptedString:(NSString *)string usingKey:(NSString *)key;

+ (NSString *)decryptedAES256String:(NSString *)string usingKey:(NSString *)key;

+ (NSString *)DESEncryptedString:(NSString *)string usingKey:(NSString *)key;

+ (NSString *)decryptedDESString:(NSString *)string usingKey:(NSString *)key;
#pragma mark --】AES和DES加密过程：string -> data -> AES/DES encrypt -> base64 encode -> string;解密过程为逆向

@end
