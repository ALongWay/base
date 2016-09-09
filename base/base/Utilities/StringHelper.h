//
//  StringHelper.h
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelper : NSObject

#pragma mark -- 【计算字符串尺寸
+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes;

+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes maxWidth:(CGFloat)maxWidth;

+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes maxHeight:(CGFloat)maxHeight;

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font paragraphStyle:(NSParagraphStyle *)paragraphStyle maxWidth:(CGFloat)maxWidth;

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font lineHeight:(CGFloat)lineHeight maxWidth:(CGFloat)maxWidth;

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font;

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font maxHeight:(CGFloat)maxHeight;
#pragma mark -- 】计算字符串尺寸

#pragma mark -- 【生成属性字符串
+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineHeight:(CGFloat)lineHeight maxWidth:(CGFloat)maxWidth;

+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color paragraphStyle:(NSParagraphStyle *)paragraphStyle maxWidth:(CGFloat)maxWidth;
#pragma mark -- 】生成属性字符串

@end
