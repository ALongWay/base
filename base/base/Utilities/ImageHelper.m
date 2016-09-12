//
//  ImageHelper.m
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scale:(CGFloat)scale
{
    CGSize newSize = CGSizeMake(originalImage.size.width * scale, originalImage.size.height * scale);
    
    UIGraphicsBeginImageContext(newSize);
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
    UIGraphicsBeginImageContext(fillSize);
    [originalImage drawInRect:CGRectMake(0, 0, fillSize.width, fillSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage cutFrame:(CGRect)cutFrame
{
    CGSize newSize = cutFrame.size;
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(-cutFrame.origin.x, -cutFrame.origin.y, cutFrame.size.width, cutFrame.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getSnapshotWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getFullScreenSnapShot
{
    return [self getSnapshotWithView:[UIApplication sharedApplication].keyWindow];
}

@end
