//
//  ALWPageControl.m
//  base
//
//  Created by 李松 on 2017/1/16.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import "ALWPageControl.h"

static const CGFloat kPointMidInset = 6;
static const CGFloat kPointBorderWidth = 1;

#define kPointSize              CGSizeMake(9, 9)
#define kPointBorderColor       [UIColor whiteColor]
#define kPointNormalColor       [UIColor clearColor]
#define kPointSelectedColor     [UIColor whiteColor]

@interface ALWPageControl (){
    NSMutableArray<UIView*>     *_pointsArray;
    
    BOOL                        _useCustomBorderWidth;
}

@end

@implementation ALWPageControl
@synthesize pointBorderWidth = _pointBorderWidth;
@synthesize currentPageIndex = _currentPageIndex;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

#pragma mark -- Getter/Setter
- (UIEdgeInsets)paddingInsets
{
    return _paddingInsets;
}

- (CGFloat)pointMidInset
{
    if (_pointMidInset) {
        return _pointMidInset;
    }
    
    return kPointMidInset;
}

- (CGSize)pointSize
{
    if (CGSizeEqualToSize(_pointSize, CGSizeZero)) {
        return kPointSize;
    }
    
    return _pointSize;
}

- (CGFloat)pointCorner
{
    if (_pointCorner) {
        return _pointCorner;
    }
    
    return self.pointSize.width / 2.0;
}

- (CGFloat)pointBorderWidth
{
    if (_useCustomBorderWidth) {
        return _pointBorderWidth;
    } else {
        if (_pointBorderWidth) {
            return _pointBorderWidth;
        }
        
        return kPointBorderWidth;
    }
}

- (void)setPointBorderWidth:(CGFloat)pointBorderWidth
{
    _pointBorderWidth = pointBorderWidth;
 
    _useCustomBorderWidth = YES;
}

- (UIColor *)pointBorderColor
{
    if (_pointBorderColor) {
        return _pointBorderColor;
    }
    
    return kPointBorderColor;
}

- (UIColor *)pointNormalColor
{
    if (_pointNormalColor) {
        return _pointNormalColor;
    }
    
    return kPointNormalColor;
}

- (UIColor *)pointSelectedColor
{
    if (_pointSelectedColor) {
        return _pointSelectedColor;
    }
    
    return kPointSelectedColor;
}

- (NSInteger)currentPageIndex
{
    return _currentPageIndex;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    
    //修改选中point
    [self changeSelectedPoint];
}

#pragma mark -- Public methods
- (void)resetPageControlWithCount:(NSInteger)count
{
    _pointsArray = [NSMutableArray arrayWithCapacity:count];
    
    UIView *bgView = [[UIView alloc] init];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:bgView];
    
    CGFloat offsetX = 0;
    
    for (int i = 0; i < count; i++) {
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, self.pointSize.width, self.pointSize.height)];
        [pointView setBackgroundColor:self.pointNormalColor];
        [pointView.layer setMasksToBounds:YES];
        [pointView.layer setBorderColor:self.pointBorderColor.CGColor];
        [pointView.layer setBorderWidth:self.pointBorderWidth];
        [pointView.layer setCornerRadius:self.pointCorner];
        [bgView addSubview:pointView];
        
        [_pointsArray addObject:pointView];
        
        offsetX = CGRectGetMaxX(pointView.frame) + self.pointMidInset;
    }
    
    offsetX -= self.pointMidInset;
    
    bgView.frame = CGRectMake(self.paddingInsets.left, self.paddingInsets.top, offsetX, self.pointSize.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetMaxX(bgView.frame) + self.paddingInsets.right, CGRectGetMaxY(bgView.frame) + self.paddingInsets.bottom);
    
    self.currentPageIndex = 0;
}

#pragma mark -- Private methods
- (void)changeSelectedPoint
{
    if (_pointsArray.count == 0) {
        return;
    }
    
    [_pointsArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == _currentPageIndex) {
            [obj setBackgroundColor:self.pointSelectedColor];
        } else {
            [obj setBackgroundColor:self.pointNormalColor];
        }
    }];
}

@end
