//
//  ImageHelper.h
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ImageHelperBlurEffectStyle) {
    ImageHelperBlurEffectStyleExtraLight,
    ImageHelperBlurEffectStyleLight,
    ImageHelperBlurEffectStyleDark
};

@interface ImageHelper : NSObject

/**
 *  根据原始view和毛玻璃样式，获取模糊视图，并自动作为原view的subview（如果不需要作为子视图，自行调用removeFromSuperview）
 *
 *  @param originalView 原始view
 *  @param style        毛玻璃样式
 *
 *  @return 模式视图
 */
+ (UIView *)getBlurEffectViewWithOriginalView:(UIView *)originalView style:(ImageHelperBlurEffectStyle)style;

/**
 *  根据原始图像和毛玻璃样式，获取新图像
 *
 *  @param originalImage 原图像
 *  @param style         毛玻璃样式
 *
 *  @return 新图像
 */
+ (UIImage *)getBlurEffectImageWithOriginalImage:(UIImage *)originalImage style:(ImageHelperBlurEffectStyle)style;

/**
 *  根据原始图像，等比缩放系数，得到新图像
 *
 *  @param originalImage 原始图像
 *  @param scale         等比缩放系数
 *
 *  @return 新图像
 */
+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scale:(CGFloat)scale;

/**
 *  根据原始图像，等比缩放最大尺寸，得到新图像
 *
 *  @param originalImage 原始图像
 *  @param scale         等比缩放最大尺寸
 *
 *  @return 新图像
 */
+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize;

/**
 *  根据原始图像，等比缩放最大尺寸，得到新尺寸
 *
 *  @param originalImage 原始图像
 *  @param scale         等比缩放最大尺寸
 *
 *  @return 新尺寸
 */
+ (CGSize)getImageSizeWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize;

/**
 *  根据原始图像，完全填充尺寸，得到新图像
 *
 *  @param originalImage 原始图像
 *  @param scale         完全填充尺寸
 *
 *  @return 新图像
 */
+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage fillSize:(CGSize)fillSize;

/**
 *  根据原始图像，裁剪区域，得到新图像
 *
 *  @param originalImage 原始图像
 *  @param scale         裁剪区域
 *
 *  @return 新图像
 */
+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage cutFrame:(CGRect)cutFrame;

/**
 *  根据颜色，得到单位尺寸的纯色新图像
 *
 *  @param color 颜色
 *
 *  @return 单位尺寸的纯色新图像
 */
+ (UIImage *)getImageWithColor:(UIColor *)color;

/**
 *  根据view，得到快照
 *
 *  @param view 被截图的视图
 *
 *  @return 快照截图
 */
+ (UIImage *)getSnapshotWithView:(UIView *)view;

/**
 *  全屏截图，但不包括状态栏
 *
 *  @return 全屏截图
 */
+ (UIImage *)getFullScreenSnapshot;

@end
