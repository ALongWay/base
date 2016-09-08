//
//  EncryptionHelper.m
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "EncryptionHelper.h"
#import "GTMBase64.h"
#import "NSData+CommonCrypto.h"

@implementation EncryptionHelper

+ (NSString *)base64EncodeWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [GTMBase64 stringByEncodingData:data];
    
    return result;
}

+ (NSString *)decodeBase64WithString:(NSString *)string
{
    NSData *data = [GTMBase64 decodeString:string];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

+ (NSString *)MD2SumWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_MD2_DIGEST_LENGTH];
    
    CC_MD2(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD2_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD2_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)MD4SumWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_MD4_DIGEST_LENGTH];
    
    CC_MD4(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD4_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD4_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)MD5SumWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(data.bytes, (CC_LONG)data.length, buffer);
    
    //如下注释代码与上述加密代码等效
//    data = [data MD5Sum];
//    Byte *buffer = (Byte *)data.bytes;
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)SHA1HashWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t buffer[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }

    return result;
}

+ (NSString *)SHA224HashWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_SHA224_DIGEST_LENGTH];
    
    CC_SHA224(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA224_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA224_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)SHA256HashWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)SHA384HashWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_SHA384_DIGEST_LENGTH];
    
    CC_SHA384(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA384_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

+ (NSString *)SHA512HashWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", buffer[i]];
    }
    
    return result;
}

#pragma mark --【AES和DES加密过程：string -> data -> AES/DES encrypt -> base64 encode -> string;解密过程为逆向
+ (NSString *)AES256EncryptedString:(NSString *)string usingKey:(NSString *)key
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data AES256EncryptedDataUsingKey:key error:nil];
    NSData *base64Data = [GTMBase64 encodeData:encryptedData];
    
    NSString *result = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
//    const char *buffer = (char *)base64Data.bytes;
//    result = [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
//    result = [[NSString alloc] initWithBytes:base64Data.bytes length:base64Data.length encoding:NSUTF8StringEncoding];
  
    return result;
}

+ (NSString *)decryptedAES256String:(NSString *)string usingKey:(NSString *)key
{
    NSData *base64Data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = [GTMBase64 decodeData:base64Data];
    NSData *data = [decryptedData decryptedAES256DataUsingKey:key error:nil];
    
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

+ (NSString *)DESEncryptedString:(NSString *)string usingKey:(NSString *)key
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data DESEncryptedDataUsingKey:key error:nil];
    NSData *base64Data = [GTMBase64 encodeData:encryptedData];
    
    NSString *result = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return result;
}

+ (NSString *)decryptedDESString:(NSString *)string usingKey:(NSString *)key
{
    NSData *base64Data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = [GTMBase64 decodeData:base64Data];
    NSData *data = [decryptedData decryptedDESDataUsingKey:key error:nil];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}
#pragma mark --】AES和DES加密过程：string -> data -> AES/DES encrypt -> base64 encode -> string;解密过程为逆向

@end
