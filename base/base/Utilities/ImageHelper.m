//
//  ImageHelper.m
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ImageHelper.h"

#pragma mark - ImageHelperMergeImage
@implementation ImageHelperMergeImage

+ (ImageHelperMergeImage *)getImageHelperMergeImageWithImage:(UIImage *)image
{
    return [self getImageHelperMergeImageWithImage:image mergeRect:CGRectMake(0, 0, image.size.width, image.size.height)];
}

+ (ImageHelperMergeImage *)getImageHelperMergeImageWithImage:(UIImage *)image mergeRect:(CGRect)mergeRect
{
    ImageHelperMergeImage *model = [[ImageHelperMergeImage alloc] init];
    model.image = image;
    model.mergeRect = mergeRect;
    
    return model;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _mergeRect = CGRectMake(0, 0, image.size.width, image.size.height);
}

@end

#pragma mark - ImageHelper
@implementation ImageHelper

+ (UIImage *)getImageMergedWithOriginalImageArray:(NSArray<ImageHelperMergeImage *> *)imageArray
{
    if (!imageArray
        || imageArray.count == 0) {
        return nil;
    }
    
    ImageHelperMergeImage *firstMergeImage = [imageArray firstObject];
    
    //将第一张图作为背景放置
    CGRect firstMergeRect = firstMergeImage.mergeRect;
    firstMergeRect.origin = CGPointZero;
    firstMergeImage.mergeRect = firstMergeRect;
    
    UIGraphicsBeginImageContextWithOptions(firstMergeImage.mergeRect.size, NO, 0.0);
    
    for (ImageHelperMergeImage *mergeImage in imageArray) {
        [mergeImage.image drawInRect:mergeImage.mergeRect];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIView *)getBlurEffectViewWithOriginalView:(UIView *)originalView style:(ImageHelperBlurEffectStyle)style
{
    if (DeviceIOSVersionAbove(8)) {
        UIBlurEffectStyle blurStyle;
        
        switch (style) {
            case ImageHelperBlurEffectStyleExtraLight: {
                blurStyle = UIBlurEffectStyleExtraLight;
                break;
            }
            case ImageHelperBlurEffectStyleLight: {
                blurStyle = UIBlurEffectStyleLight;
                break;
            }
            case ImageHelperBlurEffectStyleDark: {
                blurStyle = UIBlurEffectStyleDark;
                break;
            }
        }
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:blurStyle];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = originalView.bounds;
        [originalView addSubview:effectView];

        return effectView;
    } else {
        UIImage *originalImage = [self getSnapshotWithView:originalView];
        UIImage *blurImage = [self getBlurEffectImageWithOriginalImage:originalImage style:style];
        
        UIImageView *effectView = [[UIImageView alloc] initWithFrame:originalView.bounds];
        [effectView setImage:blurImage];
        
        [originalView addSubview:effectView];
        
        return effectView;
    }
}

+ (UIImage *)getBlurEffectImageWithOriginalImage:(UIImage *)originalImage style:(ImageHelperBlurEffectStyle)style
{
    UIImage *newImage;
    
    switch (style) {
        case ImageHelperBlurEffectStyleExtraLight: {
            newImage = [originalImage applyExtraLightEffect];
            break;
        }
        case ImageHelperBlurEffectStyleLight: {
            newImage = [originalImage applyLightEffect];
            break;
        }
        case ImageHelperBlurEffectStyleDark: {
            newImage = [originalImage applyDarkEffect];
            break;
        }
    }
    
    return newImage;
}

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scale:(CGFloat)scale
{
    CGSize newSize = CGSizeMake(originalImage.size.width * scale, originalImage.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize
{
    CGSize newSize = [self getImageSizeWithOriginalImage:originalImage scaleMaxSize:scaleMaxSize];
    
    return [self getImageWithOriginalImage:originalImage scale:newSize.width / originalImage.size.width];
}

+ (CGSize)getImageSizeWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize
{
    CGSize imageSize = originalImage.size;
    
    CGFloat scale = scaleMaxSize.width / imageSize.width;
    CGFloat newWidth = scaleMaxSize.width;
    CGFloat newHeight = scale * imageSize.height;
    
    if (newHeight > scaleMaxSize.height) {
        scale = scaleMaxSize.height / imageSize.height;
        newHeight = scaleMaxSize.height;
        newWidth = scale * imageSize.width;
    }
    
    return CGSizeMake(newWidth, newHeight);
}

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage fillSize:(CGSize)fillSize
{
    UIGraphicsBeginImageContextWithOptions(fillSize, NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, fillSize.width, fillSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage cutFrame:(CGRect)cutFrame
{
    CGImageRef cgimageRef = CGImageCreateWithImageInRect(originalImage.CGImage, cutFrame);
    UIImage *newImage = [UIImage imageWithCGImage:cgimageRef];
    CGImageRelease(cgimageRef);
    
    return newImage;
}

+ (UIImage *)getImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getSnapshotWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getFullScreenSnapshotWithoutStatusBar
{
    return [self getSnapshotWithView:[UIApplication sharedApplication].keyWindow];
}

+ (UIImage *)getFullScreenSnapshotWithStatusBar
{
//    [StringHelper printAllPrivateVariablesAndMethodsWithClassName:@"UIApplication"];
    
    UIApplication *app = [UIApplication sharedApplication];
    //私有变量得到状态栏
    UIView *statusBar = [app valueForKeyPath:@"statusBar"];
    
    UIImage *statusBarImage = [self getSnapshotWithView:statusBar];
    UIImage *bgImage = [self getFullScreenSnapshotWithoutStatusBar];
    
    ImageHelperMergeImage *mergeImage1 = [ImageHelperMergeImage getImageHelperMergeImageWithImage:bgImage];
    ImageHelperMergeImage *mergeImage2 = [ImageHelperMergeImage getImageHelperMergeImageWithImage:statusBarImage];
    
    UIImage *newImage = [self getImageMergedWithOriginalImageArray:@[mergeImage1, mergeImage2]];
    
    return newImage;
}

@end
