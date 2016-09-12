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

#pragma mark -- 【处理时间字符串
#pragma mark -- 时间格式占位符
//G:        公元时代，例如AD公元
//yy:       年的后2位
//yyyy:     完整年
//MM:       月，显示为1-12,带前置0
//MMM:      月，显示为英文月份简写,如 Jan
//MMMM:     月，显示为英文月份全称，如 Janualy
//dd:       日，2位数表示，如02
//d:        日，1-2位显示，如2，无前置0
//EEE:      简写星期几，如Sun
//EEEE:     全写星期几，如Sunday
//aa:       上下午，AM/PM
//H:        时，24小时制，0-23
//HH:       时，24小时制，带前置0
//h:        时，12小时制，无前置0
//hh:       时，12小时制，带前置0
//m:        分，1-2位
//mm:       分，2位，带前置0
//s:        秒，1-2位
//ss:       秒，2位，带前置0
//S:        毫秒
//Z:        GMT（时区）

/**
 *  默认返回如下格式的日期字符串：yyyy-MM-dd HH:mm:ss
 *
 *  @return return value description
 */
+ (NSString *)getCurrentDateString;

+ (NSString *)getCurrentDateStringWithFormat:(NSString *)dateFormat;

+ (NSString *)getDateStringWithTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)getDateStringWithTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat;

+ (NSTimeInterval)getTimeIntervalWithDateString:(NSString *)dateString;

+ (NSDateComponents *)getDateComponentsWithDateString:(NSString *)dateString;

+ (NSDateComponents *)getDateComponentsWithTimeInterval:(NSTimeInterval)timeInterval;

+ (NSString *)getContentPublishedTimeStringWithDateString:(NSString *)dateString;
#pragma mark -- 】处理时间字符串

#pragma mark -- 【处理网络请求相关字符串
+ (NSString *)getSafeDecodeStringFromJsonValue:(NSString *)jsonValue;

/**
 *  被解析的url字符串格式为：xxxxxx?a=xxx&b=xxx
 *
 *  @param urlString urlString description
 *
 *  @return return value description
 */
+ (NSDictionary *)getParametersDictionaryWithUrlString:(NSString *)urlString;

/**
 *  被解析的url字符串格式为：xxxxxx/realname_320x640.png(/jpg)
 *
 *  @param urlString urlString description
 *
 *  @return return value description
 */
+ (CGSize)getImageOriginalSizeWithUrlString:(NSString *)urlString;

+ (CGSize)getImageShowSizeWithUrlString:(NSString *)urlString maxWidth:(NSInteger)maxWidth;

/**
 *  被解析的url字符串格式为：xxxxxx/realname_320x640.png(/jpg)
 *
 *  @param originalUrlString originalUrlString description
 *  @param newWidth          newWidth description
 *
 *  @return 在原urlString后增加类似"?act=resize&x=320"，用于服务器裁剪尺寸
 */
+ (NSString *)getImageResizedUrlStringWithOriginalUrlString:(NSString *)originalUrlString newWidth:(NSInteger)newWidth;
#pragma mark -- 】处理网络请求相关字符串

#pragma mark -- 其他功能方法
/**
 *  获取字符串的字节长度（一个汉字占两个字节长度）
 *
 *  @param string string description
 *
 *  @return return value description
 */
+ (NSInteger)getBytesLengthWithString:(NSString *)string;

/**
 *  验证手机号是否合理
 *
 *  @param phoneNum phoneNum description
 *
 *  @return return value description
 */
+ (BOOL)isValidatedMobliePhoneNum:(NSString *)phoneNum;

+ (void)printAllCurrentSupportedFonts;

+ (NSString *)getDeviceVersion;

+ (NSString *)getAppShortVersion;

+ (NSString *)getAppBundleVersion;

@end
