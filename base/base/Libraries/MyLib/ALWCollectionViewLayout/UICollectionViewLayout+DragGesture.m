//
//  UICollectionViewLayout+DragGesture.m
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UICollectionViewLayout+DragGesture.h"
#import <objc/runtime.h>

static NSString *const kCollectionViewKeyPath = @"collectionView";
static const CGFloat kAutoScrollingSpeed = 300;
static const UIEdgeInsets kAutoScrollingTriggerEdgeInsets = {50, 50, 50, 50};

static CGPoint ALWCGPointAdd(CGPoint a, CGPoint b){
    return CGPointMake(a.x + b.x, a.y + b.y);
}

typedef NS_ENUM(NSInteger, AutoScrollingDirection) {
    AutoScrollingDirectionNone = 0,
    AutoScrollingDirectionUp,
    AutoScrollingDirectionDown,
    AutoScrollingDirectionLeft,
    AutoScrollingDirectionRight
};

#pragma mark -
@interface UICollectionViewLayout (DragGesturePrivate)<UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSIndexPath               *selectedItemIndexPath;
@property (strong, nonatomic) UIView                    *currentView;
@property (assign, nonatomic) CGPoint                   currentViewCenter;
@property (assign, nonatomic) CGPoint                   panTranslationInCollectionView;
@property (strong, nonatomic) CADisplayLink             *displayLink;
@property (assign, nonatomic) AutoScrollingDirection    currentScrollingDirection;

@property (strong, nonatomic) UILongPressGestureRecognizer              *longPressGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer                    *panGestureRecognizer;
@property (assign, nonatomic, readonly) id<ALWCollectionViewDataSource> dataSource;
@property (assign, nonatomic, readonly) id<ALWCollectionViewDelegate>   delegate;

@end

@implementation UICollectionViewLayout (DragGesture)

#pragma mark - swizzle methods
+ (void)load
{
    __weak typeof(self) weakSelf = self;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [weakSelf swizzleOriginalSelector:@selector(init) withNewSelector:@selector(alw_init)];
        [weakSelf swizzleOriginalSelector:@selector(initWithCoder:) withNewSelector:@selector(alw_initWithCoder:)];
        [weakSelf swizzleOriginalSelector:NSSelectorFromString(@"dealloc") withNewSelector:@selector(alw_dealloc)];
        [weakSelf swizzleOriginalSelector:@selector(layoutAttributesForElementsInRect:) withNewSelector:@selector(alw_layoutAttributesForElementsInRect:)];
        [weakSelf swizzleOriginalSelector:@selector(layoutAttributesForItemAtIndexPath:) withNewSelector:@selector(alw_layoutAttributesForItemAtIndexPath:)];
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

#pragma mark - setter/getter
- (NSIndexPath *)selectedItemIndexPath
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectedItemIndexPath:(NSIndexPath *)selectedItemIndexPath
{
    objc_setAssociatedObject(self, @selector(selectedItemIndexPath), selectedItemIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)currentView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurrentView:(UIView *)currentView
{
    objc_setAssociatedObject(self, @selector(currentView), currentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)currentViewCenter
{
    CGPoint center = [objc_getAssociatedObject(self, _cmd) CGPointValue];
    return center;
}

- (void)setCurrentViewCenter:(CGPoint)point
{
    objc_setAssociatedObject(self, @selector(currentViewCenter), [NSValue valueWithCGPoint:point], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)panTranslationInCollectionView
{
    CGPoint center = [objc_getAssociatedObject(self, _cmd) CGPointValue];
    return center;
}

- (void)setPanTranslationInCollectionView:(CGPoint)point
{
    objc_setAssociatedObject(self, @selector(panTranslationInCollectionView), [NSValue valueWithCGPoint:point], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CADisplayLink *)displayLink
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDisplayLink:(CADisplayLink *)displayLink
{
    objc_setAssociatedObject(self, @selector(displayLink), displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AutoScrollingDirection)currentScrollingDirection
{
    AutoScrollingDirection direction = (AutoScrollingDirection)[objc_getAssociatedObject(self, _cmd) intValue];
    return direction;
}

- (void)setCurrentScrollingDirection:(AutoScrollingDirection)direction
{
    objc_setAssociatedObject(self, @selector(currentScrollingDirection), @(direction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture
{
    objc_setAssociatedObject(self, @selector(longPressGestureRecognizer), gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    objc_setAssociatedObject(self, @selector(panGestureRecognizer), gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<ALWCollectionViewDataSource>)dataSource
{
    if ([self.collectionView.delegate conformsToProtocol:@protocol(ALWCollectionViewDataSource)]) {
        return (id<ALWCollectionViewDataSource>)self.collectionView.dataSource;
    }else{
        return nil;
    }
}

- (id<ALWCollectionViewDelegate>)delegate
{
    if ([self.collectionView.delegate conformsToProtocol:@protocol(ALWCollectionViewDelegate)]) {
        return (id<ALWCollectionViewDelegate>)self.collectionView.delegate;
    }else{
        return nil;
    }
}

#pragma mark - life circle
- (instancetype)alw_init
{
    id instance = [self alw_init];
    
    [self addObserver:self forKeyPath:kCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];

    
    return instance;
}

- (instancetype)alw_initWithCoder:(NSCoder *)aDecoder
{
    id instance = [self alw_initWithCoder:aDecoder];
    
    [self addObserver:self forKeyPath:kCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];

    return instance;
}

- (void)setupGestureRecognizer
{
    //未实现协议，不添加如下手势
    if (![self.collectionView.delegate conformsToProtocol:@protocol(ALWCollectionViewDelegate)]) {
        return;
    }
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleLongPressGesture:)];
    self.longPressGestureRecognizer.delegate = self;
    
    // 让自定义的longPress手势先于系统的longPress手势被识别
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
        }
    }
    
    [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePanGesture:)];
    self.panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:self.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeGestureRecognizer
{
    if (self.longPressGestureRecognizer) {
        UIView *view = self.longPressGestureRecognizer.view;
        if (view) {
            [view removeGestureRecognizer:self.longPressGestureRecognizer];
        }
        self.longPressGestureRecognizer.delegate = nil;
        self.longPressGestureRecognizer = nil;
    }
    
    if (self.panGestureRecognizer) {
        UIView *view = self.panGestureRecognizer.view;
        if (view) {
            [view removeGestureRecognizer:self.panGestureRecognizer];
        }
        self.panGestureRecognizer.delegate = nil;
        self.panGestureRecognizer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)setupDisplayLinkWithAutoScrollingDirection:(AutoScrollingDirection)direction
{
    if (!self.displayLink.paused) {
        if (direction == self.currentScrollingDirection) {
            return;
        }
    }
    
    [self invalidateDisplayLink];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll:)];
    self.currentScrollingDirection = direction;
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)invalidateDisplayLink
{
    if (!self.displayLink.paused) {
        [self.displayLink invalidate];
    }
    
    self.displayLink = nil;
}

- (void)alw_dealloc
{
    [self invalidateDisplayLink];
    [self removeGestureRecognizer];
    [self removeObserver:self forKeyPath:kCollectionViewKeyPath];
    
    [self alw_dealloc];
}

#pragma mark - UICollectionViewLayout overridden methods
- (NSArray *)alw_layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributesForElementsInRect = [self alw_layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesForElementsInRect) {
        switch (layoutAttributes.representedElementCategory) {
            case UICollectionElementCategoryCell: {
                [self applyLayoutAttributes:layoutAttributes];
            }
                break;
            default:
                break;
        }
    }
    
    return layoutAttributesForElementsInRect;
}

- (UICollectionViewLayoutAttributes *)alw_layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [self alw_layoutAttributesForItemAtIndexPath:indexPath];
    
    switch (layoutAttributes.representedElementCategory) {
        case UICollectionElementCategoryCell: {
            [self applyLayoutAttributes:layoutAttributes];
        }
            break;
        default:
            break;
    }
    
    return layoutAttributes;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
        return (self.selectedItemIndexPath != nil);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.longPressGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.panGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.longPressGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

#pragma mark - Key-Value Observing methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kCollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupGestureRecognizer];
        } else {
            [self invalidateDisplayLink];
            [self removeGestureRecognizer];
        }
    }
}

#pragma mark - methods
- (void)handleApplicationWillResignActive:(NSNotification *)notification
{
    self.panGestureRecognizer.enabled = NO;// 取消正在响应的自定义pan手势
    self.panGestureRecognizer.enabled = YES;
}

- (void)handleScroll:(CADisplayLink *)displayLink
{
    AutoScrollingDirection direction = self.currentScrollingDirection;
    if (direction == AutoScrollingDirectionNone) {
        return;
    }
    
    CGSize frameSize = self.collectionView.bounds.size;
    CGSize contentSize = self.collectionView.contentSize;
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    
    CGFloat distance = rint(kAutoScrollingSpeed * displayLink.duration);
    CGPoint translation = CGPointZero;
    
    switch(direction) {
        case AutoScrollingDirectionUp: {
            distance = -distance;
            CGFloat minY = 0.0f - contentInset.top;
            
            if ((contentOffset.y + distance) <= minY) {
                distance = -contentOffset.y - contentInset.top;
            }
            
            translation = CGPointMake(0.0f, distance);
        }
            break;
        case AutoScrollingDirectionDown: {
            CGFloat maxY = MAX(contentSize.height, frameSize.height) - frameSize.height + contentInset.bottom;
            
            if ((contentOffset.y + distance) >= maxY) {
                distance = maxY - contentOffset.y;
            }
            
            translation = CGPointMake(0.0f, distance);
        }
            break;
        case AutoScrollingDirectionLeft: {
            distance = -distance;
            CGFloat minX = 0.0f - contentInset.left;
            
            if ((contentOffset.x + distance) <= minX) {
                distance = -contentOffset.x - contentInset.left;
            }
            
            translation = CGPointMake(distance, 0.0f);
        }
            break;
        case AutoScrollingDirectionRight: {
            CGFloat maxX = MAX(contentSize.width, frameSize.width) - frameSize.width + contentInset.right;
            
            if ((contentOffset.x + distance) >= maxX) {
                distance = maxX - contentOffset.x;
            }
            
            translation = CGPointMake(distance, 0.0f);
        }
            break;
        default:
            break;
    }
    
    self.currentViewCenter = ALWCGPointAdd(self.currentViewCenter, translation);
    self.currentView.center = ALWCGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
    self.collectionView.contentOffset = ALWCGPointAdd(contentOffset, translation);
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch(gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];
            
            if ([self.dataSource respondsToSelector:@selector(alw_collectionView:canMoveItemAtIndexPath:)] &&
                ![self.dataSource alw_collectionView:self.collectionView canMoveItemAtIndexPath:currentIndexPath]) {
                return;
            }
            
            self.selectedItemIndexPath = currentIndexPath;
            
            if ([self.delegate respondsToSelector:@selector(alw_collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate alw_collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:self.selectedItemIndexPath];
            }

            UICollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
            
            self.currentView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
            
            collectionViewCell.highlighted = YES;
            [collectionViewCell setNeedsDisplay];
            UIView *highlightedImageView = [collectionViewCell snapshotViewAfterScreenUpdates:NO];
            highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            highlightedImageView.alpha = 1.0f;
            
            collectionViewCell.highlighted = NO;
            [collectionViewCell setNeedsDisplay];
            UIView *imageView = [collectionViewCell snapshotViewAfterScreenUpdates:NO];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.alpha = 0.0f;
            
            [self.currentView addSubview:imageView];
            [self.currentView addSubview:highlightedImageView];
            [self.collectionView addSubview:self.currentView];
            
            self.currentViewCenter = self.currentView.center;
            
            __weak typeof(self) weakSelf = self;
            [UIView
             animateWithDuration:0.3
             delay:0.0
             options:UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf) {
                     strongSelf.currentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     highlightedImageView.alpha = 0.0f;
                     imageView.alpha = 1.0f;
                 }
             }
             completion:^(BOOL finished) {
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf) {
                     [highlightedImageView removeFromSuperview];
                     
                     if ([strongSelf.delegate respondsToSelector:@selector(alw_collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                         [strongSelf.delegate alw_collectionView:self.collectionView layout:strongSelf didBeginDraggingItemAtIndexPath:strongSelf.selectedItemIndexPath];
                     }
                 }
             }];
            
            [self invalidateLayout];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {// 手释放正在操作的cell，相当于拖动操作结束
            NSIndexPath *currentIndexPath = self.selectedItemIndexPath;
            
            if (currentIndexPath) {
                if ([self.delegate respondsToSelector:@selector(alw_collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                    [self.delegate alw_collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentIndexPath];
                }
                
                self.selectedItemIndexPath = nil;
                self.currentViewCenter = CGPointZero;
                
                UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:currentIndexPath];
                
                self.longPressGestureRecognizer.enabled = NO;
                
                __weak typeof(self) weakSelf = self;
                [UIView
                 animateWithDuration:0.3
                 delay:0.0
                 options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf) {
                         strongSelf.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         strongSelf.currentView.center = layoutAttributes.center;
                     }
                 }
                 completion:^(BOOL finished) {
                     self.longPressGestureRecognizer.enabled = YES;
                     
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf) {
                         [strongSelf.currentView removeFromSuperview];
                         strongSelf.currentView = nil;
                         [strongSelf invalidateLayout];
                         
                         if ([strongSelf.delegate respondsToSelector:@selector(alw_collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
                             [strongSelf.delegate alw_collectionView:self.collectionView layout:strongSelf didEndDraggingItemAtIndexPath:currentIndexPath];
                         }
                     }
                 }];
            }
        }
            break;
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            self.panTranslationInCollectionView = [gestureRecognizer translationInView:self.collectionView];
            CGPoint viewCenter = self.currentView.center = ALWCGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
            
            [self updateCollectionViewLayout];
            
            if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
                if (viewCenter.y < (CGRectGetMinY(self.collectionView.bounds) + kAutoScrollingTriggerEdgeInsets.top)) {
                    [self setupDisplayLinkWithAutoScrollingDirection:AutoScrollingDirectionUp];
                } else {
                    if (viewCenter.y > (CGRectGetMaxY(self.collectionView.bounds) - kAutoScrollingTriggerEdgeInsets.bottom)) {
                        [self setupDisplayLinkWithAutoScrollingDirection:AutoScrollingDirectionDown];
                    } else {
                        [self invalidateDisplayLink];
                    }
                }
            }else if (self.collectionView.contentSize.width > self.collectionView.frame.size.width) {
                if (viewCenter.x < (CGRectGetMinX(self.collectionView.bounds) + kAutoScrollingTriggerEdgeInsets.left)) {
                    [self setupDisplayLinkWithAutoScrollingDirection:AutoScrollingDirectionLeft];
                } else {
                    if (viewCenter.x > (CGRectGetMaxX(self.collectionView.bounds) - kAutoScrollingTriggerEdgeInsets.right)) {
                        [self setupDisplayLinkWithAutoScrollingDirection:AutoScrollingDirectionRight];
                    } else {
                        [self invalidateDisplayLink];
                    }
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self invalidateDisplayLink];
        }
            break;
        default:
            break;
    }
}

/** 将当前选中的cell隐藏 */
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
        layoutAttributes.hidden = YES;
    }
}

- (void)updateCollectionViewLayout
{
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
    NSIndexPath *previousIndexPath = self.selectedItemIndexPath;
    
    if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath]) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(alw_collectionView:canMoveItemAtIndexPath:)]) {
        if (![self.dataSource alw_collectionView:self.collectionView canMoveItemAtIndexPath:newIndexPath]) {
            return;
        }
    }
    
    self.selectedItemIndexPath = newIndexPath;
    
    // cell整体有规律的变动就在于下面的  performBatchUpdates 方法
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.collectionView deleteItemsAtIndexPaths:@[previousIndexPath]];
            [strongSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        }
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.dataSource respondsToSelector:@selector(alw_collectionView:moveItemAtIndexPath:toIndexPath:)]) {
            [strongSelf.dataSource alw_collectionView:self.collectionView moveItemAtIndexPath:previousIndexPath toIndexPath:self.selectedItemIndexPath];
        }
    }];
}

@end
