//
//  SVProgressHUD+Extension.h
//  base
//
//  Created by 李松 on 16/10/12.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "SVProgressHUD.h"

@interface SVProgressHUD (Extension)

/**
 *  显示应用界面的过场动画
 */
+ (void)showAppUITransitionAnimation;

/**
 *  显示帧动画的过渡视图
 *
 *  @param images            图像数组
 *  @param animationDuration 动画周期
 *  @param status            文字提示
 */
+ (void)showAnimationImages:(NSArray<UIImage *> *)images animationDuration:(NSTimeInterval)animationDuration status:(NSString *)status;

@end
