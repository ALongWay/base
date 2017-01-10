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

+ (UIImage *)getStatusBarSnapshot
{
//    [StringHelper printAllPrivateVariablesAndMethodsWithClassName:@"UIApplication"];

    UIApplication *app = [UIApplication sharedApplication];
    //私有变量得到状态栏
    UIView *statusBar = [app valueForKeyPath:@"statusBar"];

    UIGraphicsBeginImageContextWithOptions(statusBar.bounds.size, NO, 0.0);
    [statusBar.layer renderInContext:UIGraphicsGetCurrentContext()];
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
    UIImage *statusBarImage = [self getStatusBarSnapshot];
    UIImage *bgImage = [self getFullScreenSnapshotWithoutStatusBar];
    
    ImageHelperMergeImage *mergeImage1 = [ImageHelperMergeImage getImageHelperMergeImageWithImage:bgImage];
    ImageHelperMergeImage *mergeImage2 = [ImageHelperMergeImage getImageHelperMergeImageWithImage:statusBarImage];
    
    UIImage *newImage = [self getImageMergedWithOriginalImageArray:@[mergeImage1, mergeImage2]];
    
    return newImage;
}

+ (void)getBinaryzationImageWithOriginalImage:(UIImage *)originalImage completionBlock:(void (^)(UIImage *))completion
{
    return [self getBinaryzationImageWithOriginalImage:originalImage factor:0.5 completionBlock:completion];
}

+ (void)getBinaryzationImageWithOriginalImage:(UIImage *)originalImage factor:(CGFloat)factor completionBlock:(void (^)(UIImage *))completion
{
    if (factor < 0) {
        factor = 0;
    }else if (factor > 1) {
        factor = 1;
    }
    
    CGFloat criticalValue = 256 * factor;
    
    CGImageRef imageRef = originalImage.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            UInt8 *tmp = buffer + y * bytesPerRow + x * 4;
            
            UInt8 red,green,blue;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            
            if (red + green + blue > criticalValue * 3) {
                *(tmp + 0) = 255;
                *(tmp + 1) = 255;
                *(tmp + 2) = 255;
            }else{
                *(tmp + 0) = 0;
                *(tmp + 1) = 0;
                *(tmp + 2) = 0;
            }
            
            //其他处理效果
            //            UInt8 brightness;
            //            switch (type) {
            //                case 1:
            //                    brightness = (77 * red + 28 * green + 151 * blue) / 256;
            //                    *(tmp + 0) = brightness;
            //                    *(tmp + 1) = brightness;
            //                    *(tmp + 2) = brightness;
            //                    break;
            //                case 2:
            //                    *(tmp + 0) = red;
            //                    *(tmp + 1) = green * 0.7;
            //                    *(tmp + 2) = blue * 0.4;
            //                    break;
            //                case 3:
            //                    *(tmp + 0) = 255 - red;
            //                    *(tmp + 1) = 255 - green;
            //                    *(tmp + 2) = 255 - blue;
            //                    break;
            //                default:
            //                    *(tmp + 0) = red;
            //                    *(tmp + 1) = green;
            //                    *(tmp + 2) = blue;
            //                    break;
            //            }
        }
    }
    
    CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    
    CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    CGImageRef effectedCgImage = CGImageCreate(width, height,
                                               bitsPerComponent, bitsPerPixel, bytesPerRow,
                                               colorSpace, bitmapInfo, effectedDataProvider,
                                               NULL, shouldInterpolate, intent);
    
    UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    CGImageRelease(effectedCgImage);
    
    CFRelease(effectedDataProvider);
    
    CFRelease(effectedData);
    
    CFRelease(data);
    
    if (completion) {
        completion(effectedImage);
    }
}

@end
