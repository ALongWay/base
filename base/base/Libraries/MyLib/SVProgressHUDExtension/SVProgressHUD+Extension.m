//
//  SVProgressHUD+Extension.m
//  base
//
//  Created by 李松 on 16/10/12.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "SVProgressHUD+Extension.h"

@implementation SVProgressHUD (Extension)

+ (void)showAppUITransitionAnimation
{
    NSMutableArray *imageArray = [NSMutableArray array];
    
    for (NSUInteger i = 1; i <= 3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [imageArray addObject:image];
    }
    
    [self showAnimationImages:imageArray animationDuration:imageArray.count * 0.1 status:@"卖力加载中..."];
}

+ (void)showAnimationImages:(NSArray<UIImage *> *)images animationDuration:(NSTimeInterval)animationDuration status:(NSString *)status
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    //写在该范围内的代码,都不会被编译器提示上述类型的警告
    SVProgressHUD *sharedProgressHUD = (SVProgressHUD *)[SVProgressHUD performSelector:@selector(sharedView)];
    __weak SVProgressHUD *weakInstance = sharedProgressHUD;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongInstance = weakInstance;
        if(strongInstance){
            // Update / Check view hierarchy to ensure the HUD is visible
//            [strongSelf updateViewHierarchy];
            
            [strongInstance performSelector:@selector(updateViewHierarchy)];
            
            // Reset progress and cancel any running animation
//            strongSelf.progress = SVProgressHUDUndefinedProgress;
//            [strongSelf cancelRingLayerAnimation];
//            [strongSelf cancelIndefiniteAnimatedViewAnimation];
            [strongInstance setValue:@(-1) forKey:@"progress"];
            [strongInstance performSelector:@selector(cancelRingLayerAnimation)];
            [strongInstance performSelector:@selector(cancelIndefiniteAnimatedViewAnimation)];
            
            // Update imageView
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
            UIImageView *imageView = (UIImageView *)[strongInstance valueForKey:@"imageView"];
            [imageView setImage:images[0]];
            [imageView setAnimationImages:images];
            [imageView setAnimationDuration:animationDuration];
            imageView.size = images[0].size;
            imageView.hidden = NO;
            [imageView startAnimating];
            
            // Update text
//            strongSelf.statusLabel.text = status;
            UILabel *statusLabel = (UILabel *)[strongInstance valueForKey:@"statusLabel"];
            statusLabel.text = status;
            
            // Show
//            [strongSelf showStatus:status];
            [strongInstance performSelector:@selector(showStatus:) withObject:status];
            
            // An image will dismissed automatically. Therefore we start a timer
            // which then will call dismiss after the predefined duration
//            strongSelf.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:strongSelf selector:@selector(dismiss) userInfo:nil repeats:NO];
//            [[NSRunLoop mainRunLoop] addTimer:strongSelf.fadeOutTimer forMode:NSRunLoopCommonModes];
            NSTimer *timer = [NSTimer timerWithTimeInterval:100 target:strongInstance selector:@selector(dismiss) userInfo:nil repeats:NO];
            [strongInstance setValue:timer forKey:@"fadeOutTimer"];
        }
    }];
#pragma clang diagnostic pop
}

@end
