//
//  StringHelper.m
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "StringHelper.h"
#import "sys/utsname.h"

const static NSLineBreakMode commonLineBreakMode = NSLineBreakByCharWrapping;
const static NSTextAlignment commonTextAlignment = NSTextAlignmentLeft;
static NSString *commonDateFormat = @"yyyy-MM-dd HH:mm:ss";

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
    CGFloat lineSpacing = (lineHeight - perLineHeight)/2.5;//2.5是在实际应用中，调校的值
    perLineHeight = lineHeight - lineSpacing;
    
    //设置文字段落
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
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

+ (NSString *)getCurrentDateString
{
    return [self getCurrentDateStringWithFormat:commonDateFormat];
}

+ (NSString *)getCurrentDateStringWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    return currentDateString;
}

+ (NSString *)getDateStringWithTimeInterval:(NSTimeInterval)timeInterval
{
    return [self getDateStringWithTimeInterval:timeInterval dateFormat:commonDateFormat];
}

+ (NSString *)getDateStringWithTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSTimeInterval)getTimeIntervalWithDateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:commonDateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    return timeInterval;
}

+ (NSDateComponents *)getDateComponentsWithDateString:(NSString *)dateString
{
    NSTimeInterval timeInterval = [self getTimeIntervalWithDateString:dateString];
    
    return [self getDateComponentsWithTimeInterval:timeInterval];
}

+ (NSDateComponents *)getDateComponentsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth  | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    return components;
}

+ (NSString *)getContentPublishedTimeStringWithDateString:(NSString *)dateString
{
    //    1分钟内显示“刚刚”
    //    1分钟-59分钟显示“几分钟内”
    //    1小时-24小时内显示“几小时内”
    //    24小时以上时间显示commonDateFormat
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:commonDateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    timeInterval = (timeInterval < 0) ? -timeInterval : timeInterval;
    
    CGFloat temp = 0;
    
    if (timeInterval < 60) {
        NSString *result = [NSString stringWithFormat:@"刚刚"];
        return result;
    }
    
    if((temp = timeInterval / 60) < 60){
        NSString *result = [NSString stringWithFormat:@"%d分钟内",(int)temp];
        return  result;
    }
    
    if((temp = temp / 60) < 24){
        NSString *result = [NSString stringWithFormat:@"%d小时内",(int)temp];
        return  result;
    }
    
    return dateString;
}
#pragma mark -- 】处理时间字符串

#pragma mark -- 【处理网络请求相关字符串
+ (NSString *)getSafeDecodeStringFromJsonValue:(NSString *)jsonValue
{
    if ([jsonValue isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if (!jsonValue) {
        return @"";
    }
    
    if ([jsonValue isEqualToString:@""]) {
        return @"";
    }
    
    NSString *string = [jsonValue stringByRemovingPercentEncoding];
    
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    if (string) {
        return string;
    } else {
        return jsonValue;
    }
}

+ (NSDictionary *)getParametersDictionaryWithUrlString:(NSString *)urlString
{
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionary];
    
    @try {
        NSArray *array = [NSArray arrayWithArray:[urlString componentsSeparatedByString:@"?"]];
        
        if (array.count == 2) {
            NSString *paraPart = [array objectAtIndex:1];
            NSArray *paraArray = [NSArray arrayWithArray:[paraPart componentsSeparatedByString:@"&"]];
            
            if (paraArray.count) {
                for (NSString *para in paraArray) {
                    NSArray *onePara = [NSArray arrayWithArray:[para componentsSeparatedByString:@"="]];
                    if (onePara.count == 2) {
                        [paraDic setObject:onePara[1] forKey:onePara[0]];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return paraDic;
}

+ (CGSize)getImageOriginalSizeWithUrlString:(NSString *)urlString
{
    CGSize size = CGSizeZero;
    
    @try {
        NSString *imageName = [[urlString lastPathComponent] stringByDeletingPathExtension];
        NSArray *array = [imageName componentsSeparatedByString:@"_"];
        NSArray *sizeArray = [array[1] componentsSeparatedByString:@"x"];
        
        CGFloat width = [sizeArray[0] floatValue];
        CGFloat height = [sizeArray[1] floatValue];
        
        size = CGSizeMake(width, height);
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return size;
}

+ (CGSize)getImageShowSizeWithUrlString:(NSString *)urlString maxWidth:(NSInteger)maxWidth
{
    CGSize originalSize = [self getImageOriginalSizeWithUrlString:urlString];
    CGSize newSize = originalSize;
    
    if (originalSize.width) {
        newSize.width = maxWidth;
        newSize.height = originalSize.height * maxWidth / originalSize.width;
    }
    
    return newSize;
}

+ (NSString *)getImageResizedUrlStringWithOriginalUrlString:(NSString *)originalUrlString newWidth:(NSInteger)newWidth
{
    if ([originalUrlString isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSString *urlString = originalUrlString;
    NSString *suffix = [NSString stringWithFormat:@"?act=resize&x=%d", (int)newWidth];
    urlString = [urlString stringByAppendingString:suffix];
    
    return urlString;
}
#pragma mark -- 】处理网络请求相关字符串

#pragma mark -- 其他功能方法
+ (NSInteger)getBytesLengthWithString:(NSString *)string
{
    NSInteger addedCount = 0;
    
    for(int i = 0; i < string.length; i++){
        int a = [string characterAtIndex:i];
        if( a >= 0x4e00 && a <= 0x9fff)
            addedCount++;
    }
    
    NSInteger length = string.length + addedCount;
    
    return length;
}

+ (BOOL)isValidatedMobliePhoneNum:(NSString *)phoneNum
{
    NSString* regEx = @"^[1][3578]\\d{9}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    return [predicate evaluateWithObject:phoneNum];
}

+ (void)printAllCurrentSupportedFonts
{
    for (NSString *familyName in [UIFont familyNames]) {
        LOG(@"familyName : %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            LOG(@"fontName : %@", fontName);
        }
    }
}

+ (NSString *)getDeviceVersion
{
    //需要引用头文件"sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"]
        || [deviceString isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"]
        || [deviceString isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";

    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])    return @"iPad mini 2";

    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])    return @"iPad mini 3";
    
    if ([deviceString isEqualToString:@"iPad5,1"]
        ||[deviceString isEqualToString:@"iPad5,2"])    return @"iPad mini 4";
    
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([deviceString isEqualToString:@"iPad6,3"]
        || [deviceString isEqualToString:@"iPad6,4"])   return @"iPad Pro (9.7 inch)";
    
    if ([deviceString isEqualToString:@"iPad6,7"]
        || [deviceString isEqualToString:@"iPad6,8"])   return @"iPad Pro (12.9 inch)";
    
    return deviceString;
}

+ (NSString *)getAppShortVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    return currentVersion;
}

+ (NSString *)getAppBundleVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    return currentVersion;
}

@end
