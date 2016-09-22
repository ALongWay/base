//
//  UINavigationController+PopOperation.h
//  base
//
//  Created by 李松 on 16/9/22.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopAnimationType) {
    PopAnimationTranslation = 0,
    PopAnimationFlip,
    PopAnimationCube,
};

#pragma mark - PopAnimation真正实现动画内容的对象
@interface PopAnimation : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  采用默认动画时间0.25，默认动画PopAnimationTranslation
 *
 *  @return return value description
 */
- (instancetype)init;

/**
 *  初始化自定义的动画效果
 *
 *  @param duration         周期
 *  @param popAnimationType 类型
 *
 *  @return return value description
 */
- (instancetype)initWithTransitionDuration:(CGFloat)duration popAnimationType:(PopAnimationType)popAnimationType;

/**
 *  用来获取一系列动画执行相关的对象，并且通知系统动画是否完成
 */
@property (nonatomic, weak, readonly) id<UIViewControllerContextTransitioning>  transitionContext;

/**
 *  动画执行时间
 */
@property (nonatomic, assign) CGFloat           transitionDuration;

/**
 *  动画类型
 */
@property (nonatomic, assign) PopAnimationType  popAnimationType;

@end

#pragma mark - 实现导航控制器代理方法的对象
@interface NavigationControllerDelegateObject : NSObject <UINavigationControllerDelegate>

/**
 *  自定义的实现UIViewControllerAnimatedTransitioning协议的对象
 */
@property (nonatomic, strong, readwrite) PopAnimation                          *popAnimation;

/**
 *  系统框架提供的实现UIViewControllerInteractiveTransitioning协议的对象
 */
@property (nonatomic, strong, readonly ) UIPercentDrivenInteractiveTransition  *interactivePopTransition;

- (instancetype)initWithUINavigationController:(UINavigationController *)navigationController;

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController;

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;

- (void)handlePopGestureOperation:(UIPanGestureRecognizer *)recognizer;

@end

@interface UINavigationController (PopOperation)

@property (nonatomic, strong          ) NavigationControllerDelegateObject  *base_currentDelegateObject;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer              *base_panGestureRecognizer;

@end

@interface UIViewController (PopOperation)
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
