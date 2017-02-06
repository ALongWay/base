//
//  ALWTitleTabBarConfiguration.m
//  base
//
//  Created by 李松 on 2017/1/23.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import "ALWTitleTabBarConfiguration.h"

#define kConfigColorWithRRGGBB(RRGGBB)          [UIColor colorWithRed:((float)((RRGGBB & 0xFF0000) >> 16))/255.0 green:((float)((RRGGBB & 0xFF00) >> 8))/255.0 blue:((float)(RRGGBB & 0xFF))/255.0 alpha:1]

#define kDefaultTitleFont                       [UIFont systemFontOfSize:15]
#define kDefaultTitleNormalColor                kConfigColorWithRRGGBB(0xfa9e94)
#define kDefaultTitleHighlightColor             kConfigColorWithRRGGBB(0xffffff)
#define kDefaultContentViewHorizontalPadding    8
#define kDefaultTitleViewPadding                16
#define kDefaultLineHeight                      3
#define kDefaultLineColor                       kConfigColorWithRRGGBB(0xf97b6b)
#define kDefaultFrameHeight                     29
#define kDefaultFramePadding                    8
#define kDefaultFrameColor                      kConfigColorWithRRGGBB(0xf97b6b)

@implementation ALWTitleTabBarConfiguration

+ (ALWTitleTabBarConfiguration *)getDefaultConfiguration
{
    ALWTitleTabBarConfiguration *config = [[ALWTitleTabBarConfiguration alloc] init];
    config.selectedType = ALWTitleTabBarSelectedTypeFrame;
    config.isCloseSelectedAnimation = (config.selectedType == ALWTitleTabBarSelectedTypeFrame);
    
    if (config.selectedType == ALWTitleTabBarSelectedTypeLine) {
        config.titleHighlightColor = kConfigColorWithRRGGBB(0xffffff);
    }
    
//    config.isCloseTransitionEffect = YES;
    return config;
}

- (UIFont *)titleFont
{
    if (!_titleFont) {
        return kDefaultTitleFont;
    }
    
    return _titleFont;
}

- (UIColor *)titleNormalColor
{
    if (!_titleNormalColor) {
        return kDefaultTitleNormalColor;
    }
    
    return _titleNormalColor;
}

- (UIColor *)titleHighlightColor
{
    if (!_titleHighlightColor) {
        return kDefaultTitleHighlightColor;
    }
    
    return _titleHighlightColor;
}

- (CGFloat)contentViewHorizontalPadding
{
    if (!_contentViewHorizontalPadding) {
        return kDefaultContentViewHorizontalPadding;
    }
    
    return _contentViewHorizontalPadding;
}

- (CGFloat)titleViewPadding
{
    if (!_titleViewPadding) {
        return kDefaultTitleViewPadding;
    }
    
    return _titleViewPadding;
}

- (CGFloat)lineHeight
{
    if (!_lineHeight) {
        return kDefaultLineHeight;
    }
    
    return _lineHeight;
}

- (CGFloat)linePadding
{
    if (!_linePadding) {
        return kDefaultFramePadding;
    }
    
    return _linePadding;
}

- (UIColor *)lineColor
{
    if (!_lineColor) {
        return kDefaultLineColor;
    }

    return _lineColor;
}

- (CGFloat)frameHeight
{
    if (!_frameHeight) {
        return kDefaultFrameHeight;
    }
    
    return _frameHeight;
}

- (CGFloat)framePadding
{
    if (!_framePadding) {
        return kDefaultFramePadding;
    }
    
    return _framePadding;
}

- (CGFloat)frameCorner
{
    if (!_frameCorner) {
        return kDefaultFrameHeight / 2.0;
    }
    
    return _frameCorner;
}

- (UIColor *)frameColor
{
    if (!_frameColor) {
        return kDefaultFrameColor;
    }
    
    return _frameColor;
}

@end
