//
//  SVProgressHUD+Extension.m
//  base
//
//  Created by 李松 on 16/10/12.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "SVProgressHUD+Extension.h"

@implementation SVProgressHUD (Extension)

+ (void)showImages:(NSArray<UIImage *> *)images status:(NSString *)status
{
//    __weak typeof(self) weakSelf = self;
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        __strong typeof([SVProgressHUD class]) strongSelf = weakSelf;
//        if(strongSelf){
//            // Update / Check view hierarchy to ensure the HUD is visible
////            [strongSelf updateViewHierarchy];
//            [strongSelf performSelector:@selector(updateViewHierarchy)];
//            
//            // Reset progress and cancel any running animation
////            strongSelf.progress = SVProgressHUDUndefinedProgress;
////            [strongSelf cancelRingLayerAnimation];
////            [strongSelf cancelIndefiniteAnimatedViewAnimation];
//            [strongSelf setValue:@(-1) forKey:@"progress"];
//            [strongSelf performSelector:@selector(cancelRingLayerAnimation)];
//            [strongSelf performSelector:@selector(cancelIndefiniteAnimatedViewAnimation)];
//            
//            // Update imageView
//            UIColor *tintColor = strongSelf.foregroundColorForStyle;
//            UIImage *tintedImage = image;
//            if([strongSelf.imageView respondsToSelector:@selector(setTintColor:)]) {
//                if (tintedImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
//                    tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                }
//                strongSelf.imageView.tintColor = tintColor;
//            } else {
//                tintedImage = [strongSelf image:image withTintColor:tintColor];
//            }
//            strongSelf.imageView.image = tintedImage;
//            strongSelf.imageView.hidden = NO;
//            
//            // Update text
//            strongSelf.statusLabel.text = status;
//            
//            // Show
//            [strongSelf showStatus:status];
//            
//            // An image will dismissed automatically. Therefore we start a timer
//            // which then will call dismiss after the predefined duration
//            strongSelf.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:strongSelf selector:@selector(dismiss) userInfo:nil repeats:NO];
//            [[NSRunLoop mainRunLoop] addTimer:strongSelf.fadeOutTimer forMode:NSRunLoopCommonModes];
//        }
//    }];
}

@end
