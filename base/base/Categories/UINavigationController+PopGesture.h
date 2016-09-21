//
//  UINavigationController+PopGesture.h
//  base
//
//  Created by 李松 on 16/9/21.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PopGesture)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer  *base_panGestureRecognizer;

@end

@interface UIViewController (PopGesture)

/**
 *  当前视图控制器的导航栏是否隐藏，如果不设置，则忽略此属性的任何值
 */
@property (nonatomic, assign) BOOL     base_currentNavigationBarHidden;

/**
 *  标记是否正在被pop出栈，在viewDidDisappear方法中，可以根据此属性，进行一些逻辑处理
 */
@property (nonatomic, assign) BOOL     base_isBeingPoped;

/**
 *  是否禁用pop手势,默认NO
 */
@property (nonatomic, assign) BOOL     base_popGestureDisabled;

/**
 *  从左屏幕起pop手势有效的距离，默认屏幕宽度的1/2
 */
@property (nonatomic, assign) CGFloat  base_popGestureEffectiveDistanceFromLeftEdge;

@end