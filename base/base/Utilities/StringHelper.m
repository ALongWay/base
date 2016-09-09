//
//  StringHelper.m
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "StringHelper.h"

const static NSLineBreakMode commonLineBreakMode = NSLineBreakByCharWrapping;
const static NSTextAlignment commonTextAlignment = NSTextAlignmentLeft;

@implementation StringHelper

#pragma mark -- 【计算字符串尺寸
+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes
{
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return size;
}

+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes maxWidth:(CGFloat)maxWidth
{
    CGSize size = [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return size;
}

+ (CGSize)getStringSizeWith:(NSString *)string attributes:(NSDictionary *)attributes maxHeight:(CGFloat)maxHeight
{
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return size;
}

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font paragraphStyle:(NSParagraphStyle *)paragraphStyle maxWidth:(CGFloat)maxWidth
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:font forKey:NSFontAttributeName];
    [dic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    return [self getStringSizeWith:string attributes:dic maxWidth:maxWidth];
}

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font lineHeight:(CGFloat)lineHeight maxWidth:(CGFloat)maxWidth
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = commonLineBreakMode;
    paragraphStyle.lineSpacing = 0;//行间距
    paragraphStyle.paragraphSpacing = 0;//段间距
    paragraphStyle.alignment = commonTextAlignment;
    
    return [self getStringSizeWith:string font:font paragraphStyle:paragraphStyle maxWidth:maxWidth];
}

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];

    return [self getStringSizeWith:string attributes:dic];
}

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    return [self getStringSizeWith:string attributes:dic maxWidth:maxWidth];
}

+ (CGSize)getStringSizeWith:(NSString *)string font:(UIFont *)font maxHeight:(CGFloat)maxHeight
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    return [self getStringSizeWith:string attributes:dic maxHeight:maxHeight];
}
#pragma mark -- 】计算字符串尺寸

#pragma mark -- 【生成属性字符串
+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineHeight:(CGFloat)lineHeight maxWidth:(CGFloat)maxWidth
{
    CGFloat perLineHeight = [StringHelper getStringSizeWith:@"内容" font:font].height;
    
    CGFloat lineSpacing = 0;
    
    if (/* DISABLES CODE */ (YES)) {
        lineSpacing = (lineHeight - perLineHeight)/2.5;
        perLineHeight = lineHeight - lineSpacing;
    }else{
        lineSpacing = lineHeight - perLineHeight;
    }
    
    //设置文字段落
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = perLineHeight;
    paragraphStyle.maximumLineHeight = perLineHeight;
    paragraphStyle.minimumLineHeight = perLineHeight;
    paragraphStyle.lineBreakMode = commonLineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;//行间距
    paragraphStyle.paragraphSpacing = 0;//段间距
    paragraphStyle.alignment = commonTextAlignment;

    return [self getAttributedStringWithString:string font:font color:color paragraphStyle:paragraphStyle maxWidth:maxWidth];
}

+ (NSAttributedString *)getAttributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color paragraphStyle:(NSParagraphStyle *)paragraphStyle maxWidth:(CGFloat)maxWidth
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:font forKey:NSFontAttributeName];
    [dic setObject:color forKey:NSForegroundColorAttributeName];
    [dic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    NSAttributedString* attributedString;
    
    if (string == nil) {
        attributedString = [[NSAttributedString alloc] initWithString:@" " attributes:dic];
    }else{
        attributedString = [[NSAttributedString alloc] initWithString:string attributes:dic];
    }
    
    return attributedString;
}
#pragma mark -- 】生成属性字符串

@end
