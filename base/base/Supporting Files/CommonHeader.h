//
//  CommonHeader.h
//  base
//
//  Created by 李松 on 16/9/5.
//  Copyright © 2016年 alongway. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

//该头文件用于存放全局通用的宏定义

#pragma mark -- 设置全局尺寸宏
#define StatusBarHeight                 20
#define NaviBarHeight                   44
#define TabBarHeight                    49

#define KeyboardEngHeight               216
#define KeyboardHansHeight              252

#pragma mark -- 设置全局颜色宏
//下列宏定义，只作为一种设备适配参考方案
#define StatusBarColor                  [UIColor blackColor]
#define NaviBarColor                    [UIColor whiteColor]
#define NaviBarTitleSelectedColor       COLOR(255, 120, 100)
#define NaviBarTitleUnselectedColor     COLOR(100, 100, 100)
#define NaviBarShadowColor              COLOR(230, 230, 230)

#define NaviBarTitleFontSize            ((DeviceIsNotRetina || DeviceIsiPhone4s || DeviceIsiPhone5) ? 17 : 19)

#define NaviBarTitleAttributes          [NSDictionary dictionaryWithObjectsAndKeys:FONTAppliedFixed(NaviBarTitleFontSize),NSFontAttributeName,NaviBarTitleUnselectedColor, NSForegroundColorAttributeName, nil]

#define NaviItemTextFontSize            ((DeviceIsNotRetina || DeviceIsiPhone4s || DeviceIsiPhone5) ? 14 : 16)
#define NaviItemTextGrayColor           COLOR(140, 140, 140)

#define NaviBottomLineColor             NaviBarTitleSelectedColor

#pragma mark -- 字符串本地化宏
#define LocalizedString(String)         NSLocalizedString(String,String)

#pragma mark -- 获取设备宽度和高度
//会随着应用内部横屏和竖屏变化
#define DeviceSize                      [UIScreen mainScreen].bounds.size
#define DeviceWidth                     DeviceSize.width
#define DeviceHeight                    DeviceSize.height

#pragma mark -- 判断是否iPhone4,4s,5,6,plus,iPad
//不会随着应用内部横屏和竖屏变化
#define DeviceCurrentModeSize           [UIScreen mainScreen].currentMode.size
#define DevicePortraitModeSize          (DeviceCurrentModeSize.width < DeviceCurrentModeSize.height ? DeviceCurrentModeSize : CGSizeMake(DeviceCurrentModeSize.height, DeviceCurrentModeSize.width))
#define DeviceIsNotRetina               CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(320, 480))
#define DeviceIsiPhone4s                CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(640, 960))
#define DeviceIsiPhone5                 CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(640, 1136))
//6s与6同尺寸
#define DeviceIsiPhone6                 CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(750, 1334))
//6s Plus 与 6Plus同尺寸(部分机型实际上只有6s的bounds.size)
#define DeviceIsiPhone6plus             (CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(1125, 2001)) || CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(1242, 2208)))
//在模拟器上调试，可能会遇到非Retina分辨率的情况
#define DeviceIsiPad                    (CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(768, 1024)) || CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(1536, 2048)) || CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(DevicePortraitModeSize, CGSizeMake(2048, 2732)))

#pragma mark -- 判断设备操作系统整数版本号
//当前系统版本号取得仍为浮点型
#define DeviceIOSVersion                [[[UIDevice currentDevice] systemVersion] floatValue]
#define DeviceIOSVersionIs(x)           (DeviceIOSVersion >= x && DeviceIOSVersion < x+1 ? YES : NO)
#define DeviceIOSVersionAbove(x)        (DeviceIOSVersion >= x ? YES : NO)

#pragma mark -- 根据设备，计算标注图中当前缩放尺寸(标注图版本：375宽度) iPad以iPhone6为标准显示
//下列宏定义，只作为一种设备适配参考方案
#define ResizeSideBase6(s)              (DeviceIsiPad ? s : (DeviceWidth * s / 375))

#pragma mark -- 只根据设计图(标注图版本：375宽度)的宽度等比缩放
#define ResizeSideBase375(s)            (DeviceWidth * s / 375)

#pragma mark -- 设置自定义字体
#define FontName1                       @"FZY3JW--GB1-0"//方正准圆ttf字体名称
#define FontName2                       @"Helvetica"
#define FontName3                       @"Helvetica-Bold"

//固定字体大小
#define FONTAppliedFixed(n)             [UIFont systemFontOfSize:n]
#define FONTAppliedBoldFixed(n)         [UIFont boldSystemFontOfSize:n]
#define FONTFZZYFixed(n)                [UIFont fontWithName:FontName1 size:n]
#define FONTHelveticaFixed(n)           [UIFont fontWithName:FontName2 size:n]
#define FONTHelveticaBoldFixed(n)       [UIFont fontWithName:FontName3 size:n]

//下列宏定义，只作为一种设备适配参考方案
//根据设备，计算显示字体(标注图版本：375宽度) iPad以iPhone6为标准显示
#define FONTAppliedBase6(n)             (DeviceIsiPhone6plus ? FONTAppliedFixed(n+0.5) : (DeviceIsiPhone6 || DeviceIsiPad ? FONTAppliedFixed(n) : FONTAppliedFixed(n-1)))
#define FONTAppliedBoldBase6(n)         (DeviceIsiPhone6plus ? FONTAppliedBoldFixed(n+0.5) : (DeviceIsiPhone6 || DeviceIsiPad ? FONTAppliedBoldFixed(n) : FONTAppliedBoldFixed(n-1)))

#define FONTHelveticaBase6(n)           (DeviceIsiPhone6plus ? FONTHelveticaFixed(n+0.5) : (DeviceIsiPhone6 || DeviceIsiPad ? FONTHelveticaFixed(n) : FONTHelveticaFixed(n-1)))
#define FONTHelveticaBoldBase6(n)       (DeviceIsiPhone6plus ? FONTHelveticaBoldFixed(n+0.5) : (DeviceIsiPhone6 || DeviceIsiPad ? FONTHelveticaBoldFixed(n) : FONTHelveticaBoldFixed(n-1)))

#pragma mark -- 加载图片宏(下列方法频繁IO，不缓存图片)：
#define LOADIMAGE(name)                 [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]]
#define LOADIMAGEWITHTYPE(name,type)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]]

#pragma mark -- 设置16进制RGB颜色(格式：RRGGBB)
#define COLORWITHRRGGBBA(RRGGBB, A)     [UIColor colorWithRed:((float)((RRGGBB & 0xFF0000) >> 16))/255.0 green:((float)((RRGGBB & 0xFF00) >> 8))/255.0 blue:((float)(RRGGBB & 0xFF))/255.0 alpha:A]
#define COLORWITHRRGGBB(RRGGBB)         COLORWITHRRGGBBA(RRGGBB, 1.0)

#pragma mark -- 设置10进制RGB颜色
#define COLORWITHRGBA(R, G, B, A)       [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define COLOR(R, G, B)                  COLORWITHRGBA(R, G, B, 1.0)

#define COLORWITHIMAGE(name)            [UIColor colorWithPatternImage:LOADIMAGE(name)]

#pragma mark -- 角度弧度转换
#define DegreesToRadian(x)              (M_PI * x / 180.0)
#define RadianToDegrees(radian)         (radian * 180.0 / M_PI)

#pragma mark -- log输出控制宏
#ifdef  DEBUG
#define LOG(...)                        NSLog(__VA_ARGS__);
#define LOG_METHOD                      NSLog(@"%s", __func__);
#else
#define LOG(...)                        ;
#define LOG_METHOD                      ;
#endif

#pragma mark -- 弱引用宏定义
#define WS(weakSelf)                    __weak typeof(self) weakSelf = self;

#endif /* CommonHeader_h */
