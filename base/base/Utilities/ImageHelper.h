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

#pragma mark - ImageHelperMergeImage
@interface ImageHelperMergeImage : NSObject

/**
 *  合并的图像
 */
@property (nonatomic, strong)   UIImage     *image;

/**
 *  合并的位置，设置image后默认使用CGRectMake(0, 0, image.size.width, image.size.height)
 */
@property (nonatomic, assign)   CGRect      mergeRect;

/**
 *  生成图像的合并对象，合并的rect默认使用CGRectMake(0, 0, image.size.width, image.size.height)
 *
 *  @param image 图像
 *
 *  @return 合并对象
 */
+ (ImageHelperMergeImage *)getImageHelperMergeImageWithImage:(UIImage *)image;

/**
 *  根据合并的rect，来生成图像的合并对象
 *
 *  @param image     图像
 *  @param mergeRect 合并的rect
 *
 *  @return 合并对象
 */
+ (ImageHelperMergeImage *)getImageHelperMergeImageWithImage:(UIImage *)image mergeRect:(CGRect)mergeRect;

@end

#pragma mark - ImageHelper
@interface ImageHelper : NSObject

/**
 *  依据图像数组，依次合并为新图像
 *
 *  @param imageArray 图像数组
 *
 *  @return 新的图像
 */
+ (UIImage *)getImageMergedWithOriginalImageArray:(NSArray<ImageHelperMergeImage *> *)imageArray;

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
 *  获取状态栏的单独截图
 *
 *  @return 状态栏截图
 */
+ (UIImage *)getStatusBarSnapshot;

/**
 *  全屏截图，但不包括状态栏
 *
 *  @return 全屏截图
 */
+ (UIImage *)getFullScreenSnapshotWithoutStatusBar;

/**
 *  全屏截图，包括状态栏
 *
 *  @return 全屏截图
 */
+ (UIImage *)getFullScreenSnapshotWithStatusBar;

/**
 根据原图得到二值化（黑白）图像，系数为0.5
 
 @param originalImage originalImage description
 @param completion completion description
 */
+ (void)getBinaryzationImageWithOriginalImage:(UIImage *)originalImage completionBlock:(void (^)(UIImage *))completion;

/**
 根据原图得到二值化（黑白）图像
 
 @param originalImage originalImage description
 @param factor 二值化系数，在（0， 1）区间取值，值越大，黑色区域更多
 @param completion completion description
 */
+ (void)getBinaryzationImageWithOriginalImage:(UIImage *)originalImage factor:(CGFloat)factor completionBlock:(void (^)(UIImage *))completion;


@end
