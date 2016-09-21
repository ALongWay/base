//
//  UINavigationController+PopGesture.m
//  base
//
//  Created by 李松 on 16/9/21.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UINavigationController+PopGesture.h"
#import <objc/runtime.h>

#pragma mark - NavigationControllerGestureDelegateObject
@interface NavigationControllerGestureDelegateObject : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation NavigationControllerGestureDelegateObject

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //正在转场
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    //在导航控制器的根控制器界面
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    UIViewController *popedController = [self.navigationController.viewControllers lastObject];
    
    if (popedController.base_popGestureDisabled) {
        return NO;
    }
    
    //满足有效手势范围
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat popGestureEffectiveDistanceFromLeftEdge = popedController.base_popGestureEffectiveDistanceFromLeftEdge;
    
    if (popGestureEffectiveDistanceFromLeftEdge > 0
        && beginningLocation.x > popGestureEffectiveDistanceFromLeftEdge) {
        return NO;
    }
    
    //右滑手势
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint transition = [panGesture translationInView:panGesture.view];
    
    if (transition.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - UIViewController (PopGesturePrivate)
typedef void (^ViewControllerViewWillAppearDelayBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (PopGesturePrivate)

/**
 *  是否启用下述block，默认NO
 */
@property (nonatomic, assign) BOOL                                    canUseViewWillAppearDelayBlock;

/**
 *  当canUseViewWillAppearDelayBlock为Yes，才能使用
 */
@property (nonatomic, copy  ) ViewControllerViewWillAppearDelayBlock  viewWillAppearDelayBlock;

@end

@implementation UIViewController (PopGesturePrivate)

#pragma mark -- getter/setter
- (BOOL)canUseViewWillAppearDelayBlock
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    
    self.canUseViewWillAppearDelayBlock = NO;
    return NO;
}

- (void)setCanUseViewWillAppearDelayBlock:(BOOL)canUse
{
    objc_setAssociatedObject(self, @selector(canUseViewWillAppearDelayBlock), @(canUse), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ViewControllerViewWillAppearDelayBlock)viewWillAppearDelayBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewWillAppearDelayBlock:(ViewControllerViewWillAppearDelayBlock)viewWillAppearDelayBlock
{
    objc_setAssociatedObject(self, @selector(viewWillAppearDelayBlock), viewWillAppearDelayBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark - UINavigationController (PopGesture)
@implementation UINavigationController (PopGesture)

+ (void)load
{
    __weak typeof(self) weakSelf = self;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [weakSelf swizzleOriginalSelector:@selector(pushViewController:animated:) withNewSelector:@selector(base_pushViewController:animated:)];
        
        [weakSelf swizzleOriginalSelector:@selector(popViewControllerAnimated:) withNewSelector:@selector(base_popViewControllerAnimated:)];
    });
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Class selfClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method newMethod = class_getInstanceMethod(selfClass, newSelector);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    //先用新的IMP加到原始SEL中
    BOOL addSuccess = class_addMethod(selfClass, originalSelector, newIMP, method_getTypeEncoding(newMethod));
    if (addSuccess) {
        class_replaceMethod(selfClass, newSelector, originalIMP, method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (NavigationControllerGestureDelegateObject *)base_panGestureRecognizerDelegateObject
{
    NavigationControllerGestureDelegateObject *delegateObject = objc_getAssociatedObject(self, _cmd);
    
    if (!delegateObject) {
        delegateObject = [[NavigationControllerGestureDelegateObject alloc] init];
        delegateObject.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegateObject;
}

- (UIPanGestureRecognizer *)base_panGestureRecognizer
{
    UIPanGestureRecognizer* panGesture = objc_getAssociatedObject(self, _cmd);
    
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] init];
        panGesture.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return panGesture;
}

- (void)base_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.base_panGestureRecognizer]) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.base_panGestureRecognizer];
        
        //使用KVC获取私有变量和Api，实现系统原生的pop手势效果
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.base_panGestureRecognizer.delegate = [self base_panGestureRecognizerDelegateObject];
        [self.base_panGestureRecognizer addTarget:internalTarget action:internalAction];
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self base_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    if (![self.viewControllers containsObject:viewController]) {
        [self base_pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)base_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *popedVC = [self base_popViewControllerAnimated:animated];
    
    popedVC.base_isBeingPoped = YES;
    
    return popedVC;
}

//设置视图控制器的导航栏是否显示的block
- (void)base_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController
{
    //如果navigationController不显示导航栏，直接return
    if (self.navigationBarHidden) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    ViewControllerViewWillAppearDelayBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.base_currentNavigationBarHidden animated:animated];
        }
    };
    
    appearingViewController.viewWillAppearDelayBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.viewWillAppearDelayBlock) {
        disappearingViewController.viewWillAppearDelayBlock = block;
    }
}

@end

#pragma mark - UIViewController (PopGesture)
@implementation UIViewController (PopGesture)

+ (void)load
{
    __weak typeof(self) weakSelf = self;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [weakSelf swizzleOriginalSelector:@selector(viewWillAppear:) withNewSelector:@selector(base_viewWillAppear:)];
        
        [weakSelf swizzleOriginalSelector:@selector(viewDidDisappear:) withNewSelector:@selector(base_viewDidDisappear:)];
    });
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Class selfClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method newMethod = class_getInstanceMethod(selfClass, newSelector);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    //先用新的IMP加到原始SEL中
    BOOL addSuccess = class_addMethod(selfClass, originalSelector, newIMP, method_getTypeEncoding(newMethod));
    if (addSuccess) {
        class_replaceMethod(selfClass, newSelector, originalIMP, method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (void)base_viewWillAppear:(BOOL)animated
{
    [self base_viewWillAppear:animated];
    
    if (self.canUseViewWillAppearDelayBlock
        && self.viewWillAppearDelayBlock) {
        self.viewWillAppearDelayBlock(self, animated);
    }
    
    if (self.transitionCoordinator) {
        [self.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if ([context isCancelled]) {
                self.base_isBeingPoped = NO;
            }
        }];
    }
}

- (void)base_viewDidDisappear:(BOOL)animated
{
    [self base_viewDidDisappear:animated];
}

#pragma mark -- getter/setter
- (BOOL)base_currentNavigationBarHidden
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    
    self.canUseViewWillAppearDelayBlock = NO;
    return NO;
}

- (void)setBase_currentNavigationBarHidden:(BOOL)hidden
{
    self.canUseViewWillAppearDelayBlock = YES;
    
    objc_setAssociatedObject(self, @selector(base_currentNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)base_isBeingPoped
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBase_isBeingPoped:(BOOL)isBeingPoped
{
    objc_setAssociatedObject(self, @selector(base_isBeingPoped), @(isBeingPoped), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)base_popGestureDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBase_popGestureDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(base_popGestureDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)base_popGestureEffectiveDistanceFromLeftEdge
{
    CGFloat distance = [objc_getAssociatedObject(self, _cmd) floatValue];
    
    distance = distance > 0 ? distance : [UIScreen mainScreen].bounds.size.width / 2.0;
    
    return distance;
}

- (void)setBase_popGestureEffectiveDistanceFromLeftEdge:(CGFloat)distance
{
    objc_setAssociatedObject(self, @selector(base_popGestureEffectiveDistanceFromLeftEdge), @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
