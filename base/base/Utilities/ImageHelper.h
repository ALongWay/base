//
//  ImageHelper.h
//  base
//
//  Created by 李松 on 16/9/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scale:(CGFloat)scale;

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize;

+ (CGSize)getImageSizeWithOriginalImage:(UIImage *)originalImage scaleMaxSize:(CGSize)scaleMaxSize;

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage fillSize:(CGSize)fillSize;

+ (UIImage *)getImageWithOriginalImage:(UIImage *)originalImage cutFrame:(CGRect)cutFrame;

+ (UIImage *)getSnapshotWithView:(UIView *)view;

+ (UIImage *)getFullScreenSnapShot;

@end
