//
//  UINavigationController+PopOperation.m
//  base
//
//  Created by 李松 on 16/9/22.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UINavigationController+PopOperation.h"
#import <objc/runtime.h>

#pragma mark - PopAnimation真正实现动画内容的对象
@interface PopAnimation ()

@property (nonatomic, weak, readwrite) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation PopAnimation

- (instancetype)init
{
    return [self initWithTransitionDuration:0.25 popAnimationType:PopAnimationTranslation];
}

- (instancetype)initWithTransitionDuration:(CGFloat)duration popAnimationType:(PopAnimationType)popAnimationType
{
    self = [super init];
    if (self) {
        _transitionDuration = duration;
        _popAnimationType = popAnimationType;
    }
    
    return self;
}

/**
 *  返回动画执行的时间
 *
 *  @param transitionContext transitionContext description
 *
 *  @return return value description
 */
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return _transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;

    //当前控制器
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //动画结束显示的控制器
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //执行交互动画的容器view
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    switch (_popAnimationType) {
        case PopAnimationTranslation: {
            CGFloat containerWidth = containerView.frame.size.width;
            toViewController.view.transform = CGAffineTransformMakeTranslation(-containerWidth / 4.0, 0);

            [UIView animateWithDuration:duration animations:^{
                toViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                fromViewController.view.transform = CGAffineTransformMakeTranslation(containerWidth, 0);
            }completion:^(BOOL finished) {
                //动画结束，必须调用此方法
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];

            break;
        }
        case PopAnimationFlip: {
            [UIView beginAnimations:@"View Flip" context:nil];
            [UIView setAnimationDuration:duration];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:containerView cache:YES];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
            [UIView commitAnimations];
            [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];

            break;
        }
        case PopAnimationCube: {
            CATransition *transiton = [CATransition animation];
            transiton.type = @"cube";
            transiton.subtype = @"fromLeft";
            transiton.duration = duration;
            transiton.removedOnCompletion = NO;
            transiton.fillMode = kCAFillModeForwards;
            transiton.delegate = self;
            [containerView.layer addAnimation:transiton forKey:nil];
            [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];

            break;
        }
    }
}

- (void)animationDidStop:(CATransition *)anim finished:(BOOL)flag {
    [_transitionContext completeTransition:!_transitionContext.transitionWasCancelled];
}

@end

#pragma mark - NavigationControllerDelegateObject
static NavigationControllerDelegateObject *naviControllerDelegateObject;

@interface NavigationControllerDelegateObject ()

@property (nonatomic, weak             ) UINavigationController                *naviController;

@property (nonatomic, strong, readwrite) UIPercentDrivenInteractiveTransition  *interactivePopTransition;

@end

@implementation NavigationControllerDelegateObject

- (instancetype)initWithUINavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        _naviController = navigationController;
        _naviController.delegate = self;

        _popAnimation = [[PopAnimation alloc] init];
    }
    
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if ([animationController isKindOfClass:[PopAnimation class]])
        return _interactivePopTransition;
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop)
        return _popAnimation;
    
    return nil;
}

- (void)handlePopGestureOperation:(UIPanGestureRecognizer *)recognizer{
    //将手指在屏幕上的移动距离与屏幕宽度比例作为动画的进度
    CGPoint translationInScreen = [recognizer translationInView:[UIApplication sharedApplication].keyWindow];
    CGFloat progress = translationInScreen.x / [UIScreen mainScreen].bounds.size.width;
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //新建手势交互对象
        _interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];

        //开始执行pop动画
        [_naviController popViewControllerAnimated:YES];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
         //更新进度
        [_interactivePopTransition updateInteractiveTransition:progress];
    }else if (recognizer.state == UIGestureRecognizerStateEnded
              || recognizer.state == UIGestureRecognizerStateCancelled) {
        //手势结束时如果进度大于一半，那么就完成pop操作，否则取消
        if (progress > 0.5) {
            [_interactivePopTransition finishInteractiveTransition];
        }else {
            [_interactivePopTransition cancelInteractiveTransition];
        }
        
        //手势交互结束，清理对象
        _interactivePopTransition = nil;
    }
}

@end

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

#pragma mark - UIViewController (PopOperationPrivate)
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

#pragma mark - UINavigationController (PopOperation)
@implementation UINavigationController (PopOperation)

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

- (NavigationControllerDelegateObject *)base_currentDelegateObject
{
    NavigationControllerDelegateObject *delegateObject = objc_getAssociatedObject(self, _cmd);
    
    return delegateObject;
}

- (void)setBase_currentDelegateObject:(NavigationControllerDelegateObject *)delegateObject
{
    objc_setAssociatedObject(self, @selector(base_currentDelegateObject), delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        
        self.base_panGestureRecognizer.delegate = [self base_panGestureRecognizerDelegateObject];
        
        self.base_currentDelegateObject = [[NavigationControllerDelegateObject alloc] initWithUINavigationController:self];
        
        [self.base_panGestureRecognizer addTarget:self.base_currentDelegateObject action:@selector(handlePopGestureOperation:)];
        
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

#pragma mark - UIViewController (PopOperation)
@implementation UIViewController (PopOperation)

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
