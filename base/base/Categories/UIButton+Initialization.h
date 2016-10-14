//
//  UIButton+Initialization.h
//  base
//
//  Created by 李松 on 16/9/14.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonImageLocation) {
    ButtonImageLocationUp,
    ButtonImageLocationLeft,
    ButtonImageLocationDown,
    ButtonImageLocationRight
};

@interface UIButton (Initialization)

/**
 *  生成导航栏上红色的文字按钮
 *
 *  @param text 按钮文字
 *
 *  @return 按钮
 */
+ (UIButton *)createNavigationBarRedTextButtonWithText:(NSString *)text;

/**
 *  生成导航栏上灰色的文字按钮
 *
 *  @param text 按钮文字
 *
 *  @return 按钮
 */
+ (UIButton *)createNavigationBarGrayTextButtonWithText:(NSString *)text;

/**
 *  生成导航栏上图片按钮
 *
 *  @param image 图像
 *
 *  @return 按钮
 */
+ (UIButton *)createNavigationBarImageButtonWithImage:(UIImage *)image;

#pragma mark -
/**
 *  设置常用按钮，半径5，背景nor/disabled（255，120，100）背景highlight（235，109，88）
 *  文字nor/highlight(255,255,255) disabled(255,195,188) 字体：16号
 *
 *  @param text 按钮文字
 *
 *  @return return value description
 */
- (void)setCommonButtonWithText:(NSString *)text;

/**
 *  设置按钮各种状态的显示图片
 *
 *  @param normalImg    常规图片
 *  @param highlightImg 高亮图片
 */
- (void)setButtonImageWithNormalImage:(UIImage *)normalImg highlightImage:(UIImage *)highlightImg;

/**
 *  设置按钮各种状态的背景图片
 *
 *  @param normalBgImg    normalBgImg
 *  @param highlightBgImg highlightBgImg
 */
- (void)setButtonBgImageWithNormalBgImage:(UIImage *)normalBgImg highlightBgImage:(UIImage *)highlightBgImg;

/**
 *  设置某状态的按钮标题文字
 *
 *  @param text  text description
 *  @param color color description
 *  @param font  font description
 *  @param state state description
 */
- (void)setButtonTitleWithText:(NSString*)text textColor:(UIColor*)color font:(UIFont *)font forState:(UIControlState)state;

/**
 *  设置按钮的各种状态的标题文字
 *
 *  @param text           text description
 *  @param font           font description
 *  @param normalColor    normalColor description
 *  @param highlightColor highlightColor description
 */
- (void)setButtonTitleWithText:(NSString *)text font:(UIFont *)font normalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor;

/**
 *  设置按钮的边框和圆角
 *
 *  @param color  边框颜色
 *  @param width  边框宽度
 *  @param radius 圆角半径
 */
- (void)setButtonBorderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius;

/**
 *  当同时存在title和Image时候，用于调整两者的布局
 *
 *  @param midInset      中间间距
 *  @param imageLocation 图片相对方位
 */
- (void)resetButtonTitleAndImageLayoutWithMidInset:(CGFloat)midInset imageLocation:(ButtonImageLocation)imageLocation;

@end
