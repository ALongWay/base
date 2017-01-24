//
//  ALWTitleTabBar.m
//  base
//
//  Created by 李松 on 2017/1/23.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import "ALWTitleTabBar.h"

#define kConfigColorWithRRGGBB(RRGGBB)  [UIColor colorWithRed:((float)((RRGGBB & 0xFF0000) >> 16))/255.0 green:((float)((RRGGBB & 0xFF00) >> 8))/255.0 blue:((float)(RRGGBB & 0xFF))/255.0 alpha:1]

#define kDefaultTitleTabBarSize         CGSizeMake([UIScreen mainScreen].bounds.size.width, 52)
#define kDefaultTitleTabBarBgColor      kConfigColorWithRRGGBB(0xfff5f4)

#define kDefaultAnimationDuration       0.2

#pragma mark - ALWTitleTabBar
@interface ALWTitleTabBar (){
    UIScrollView        *_scrollView;
    NSArray<UILabel*>   *_bottomLabelArray;
    UIView              *_frameView;
    UIView              *_lineView;
    UIView              *_maskView;
    NSArray<UILabel*>   *_topLabelArray;
    
    NSArray<NSNumber*>  *_titleWidthArray;
    CGFloat             _labelTotalWidth;
    CGFloat             _labelMaxWidth;
    
    CAShapeLayer        *_showLayer;
    
    ALWTitleTabBarConfiguration     *_configuration;
}

@property (nonatomic, assign, readwrite) NSInteger  currentSelectedIndex;

@end

@implementation ALWTitleTabBar

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, kDefaultTitleTabBarSize.width, kDefaultTitleTabBarSize.height)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:kDefaultTitleTabBarBgColor];
    }
    
    return self;
}

- (void)resetTitleTabBarWithTitleArray:(NSArray<NSString *> *)titleArray
{
    [self resetTitleTabBarWithTitleArray:titleArray configuration:[ALWTitleTabBarConfiguration getDefaultConfiguration]];
}

- (void)resetTitleTabBarWithTitleArray:(NSArray<NSString *> *)titleArray configuration:(ALWTitleTabBarConfiguration *)configuration
{
    _configuration = configuration;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (_scrollView) {
        [_scrollView removeFromSuperview];
        _scrollView = nil;
    }

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setBounces:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [self addSubview:_scrollView];
    
    [self generateLabelArrayWithTitleArray:titleArray configuration:configuration];
    
    //添加视图到容器view上
    //frame
    _frameView = [[UIView alloc] initWithFrame:CGRectMake(0, (height - configuration.frameHeight) / 2.0, 0, configuration.frameHeight)];
    [_frameView setBackgroundColor:configuration.frameColor];
    [_frameView.layer setMasksToBounds:YES];
    [_frameView.layer setCornerRadius:configuration.frameCorner];
    [_scrollView addSubview:_frameView];
    
    _maskView = [[UIView alloc] initWithFrame:CGRectZero];
    [_maskView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = configuration.contentViewHorizontalPadding;
    
    for (int i = 0; i < _bottomLabelArray.count; i++) {
        UILabel *bottomLabel = _bottomLabelArray[i];
        UILabel *topLabel = _topLabelArray[i];
        
        CGRect rect = bottomLabel.frame;
        rect.origin.x = originX;
        
        //如果等宽，修改宽度
        if (configuration.isEqualTitleViewWidth) {
            if (_labelTotalWidth < width) {
                //每个label平分容器宽度
                CGFloat equalWidth = width / titleArray.count;
                rect.size.width = equalWidth;
            }
        }else{
            if (_labelTotalWidth < width) {
                //如果内容总宽度小于tabBar宽度，将多出宽度平分到每个label
                CGFloat lastWidth = width - _labelTotalWidth;
                CGFloat canAddedWidthPerLabel = lastWidth / titleArray.count;
                rect.size.width += canAddedWidthPerLabel;
            }
        }
        
        bottomLabel.frame = rect;
        topLabel.frame = rect;
        
        [_scrollView addSubview:bottomLabel];
        [_maskView addSubview:topLabel];
        
        originX = CGRectGetMaxX(bottomLabel.frame);
    }
    
    [_scrollView setContentSize:CGSizeMake(originX + configuration.contentViewHorizontalPadding, height)];
    _maskView.frame = CGRectMake(0, 0, originX + configuration.contentViewHorizontalPadding, height);
    
    //添加mask和showLayer层
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, _maskView.frame.size.width, _maskView.frame.size.height);
    _maskView.layer.mask = maskLayer;
    [_scrollView addSubview:_maskView];
    
    _showLayer = [[CAShapeLayer alloc] init];
    _showLayer.frame = CGRectMake(0, 0, 0, height);
    _showLayer.fillColor = [UIColor redColor].CGColor;
    _showLayer.strokeColor = [UIColor redColor].CGColor;
    _showLayer.strokeStart = 0;
    _showLayer.strokeEnd = 1;
    _showLayer.lineWidth = 1;
    [maskLayer addSublayer:_showLayer];
    
    //line
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, height - configuration.lineHeight, 0, configuration.lineHeight)];
    [_lineView setBackgroundColor:configuration.lineColor];
    [_scrollView addSubview:_lineView];
    
    [_frameView setHidden:(configuration.selectedType != ALWTitleTabBarSelectedTypeFrame)];
    [_lineView setHidden:(configuration.selectedType != ALWTitleTabBarSelectedTypeLine)];
    
    [self resetSelectedTitleWithIndex:0];
}

- (void)generateLabelArrayWithTitleArray:(NSArray<NSString *> *)titleArray configuration:(ALWTitleTabBarConfiguration *)configuration
{
    NSMutableArray<UILabel *> *tempBottomLabelArray = [NSMutableArray arrayWithCapacity:titleArray.count];
    NSMutableArray<UILabel *> *tempTopLabelArray = [NSMutableArray arrayWithCapacity:titleArray.count];
    NSMutableArray<NSNumber*> *tempTitleWidthArray = [NSMutableArray arrayWithCapacity:titleArray.count];
    
    CGFloat labelHeight = self.frame.size.height;
    CGFloat labelMaxWidth = 0;
    CGFloat totalWidth = 0;
    
    for (int i = 0; i < titleArray.count; i++) {
        NSString *title = titleArray[i];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [bottomLabel setText:title];
        [bottomLabel setTextColor:configuration.titleNormalColor];
        [bottomLabel setTextAlignment:NSTextAlignmentCenter];
        [bottomLabel setFont:configuration.titleFont];
        [bottomLabel sizeToFit];
        
        CGRect rect = bottomLabel.frame;
        
        [tempTitleWidthArray addObject:@(rect.size.width)];
        
        CGFloat currentLabelWidth = rect.size.width + configuration.titleViewPadding * 2;
        
        rect.size = CGSizeMake(currentLabelWidth, labelHeight);
        bottomLabel.frame = rect;
        [tempBottomLabelArray addObject:bottomLabel];
        
        //---------------
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [topLabel setText:title];
        [topLabel setTextColor:configuration.titleHighlightColor];
        [topLabel setTextAlignment:NSTextAlignmentCenter];
        [topLabel setFont:configuration.titleFont];
        [topLabel sizeToFit];
        topLabel.frame = rect;
        topLabel.tag = i;
        
        UITapGestureRecognizer *tapLabelGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedTitleWithGesture:)];
        [topLabel setUserInteractionEnabled:YES];
        [topLabel addGestureRecognizer:tapLabelGest];
        
        [tempTopLabelArray addObject:topLabel];
        
        //---------------
        if (currentLabelWidth > labelMaxWidth) {
            labelMaxWidth = currentLabelWidth;
        }
        
        totalWidth += currentLabelWidth;
    }
    
    _labelTotalWidth = totalWidth;
    _labelMaxWidth = labelMaxWidth;
    
    _bottomLabelArray = tempBottomLabelArray;
    _topLabelArray = tempTopLabelArray;
    _titleWidthArray = tempTitleWidthArray;
}

#pragma mark --
- (void)didClickedTitleWithGesture:(UITapGestureRecognizer *)tapGest
{
    NSInteger index = tapGest.view.tag;
    
    if ([self.delegate respondsToSelector:@selector(ALWTitleTabBarShouldSelectTitleWithIndex:)]) {
        if (![self.delegate ALWTitleTabBarShouldSelectTitleWithIndex:index]) {
            return;
        }
    }
    
    [self resetSelectedTitleWithIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(ALWTitleTabBarDidSelectedTitleWithIndex:)]) {
        [self.delegate ALWTitleTabBarDidSelectedTitleWithIndex:index];
    }
}

- (void)resetSelectedTitleWithIndex:(NSInteger)index
{
    switch (_configuration.selectedType) {
        case ALWTitleTabBarSelectedTypeFrame:{
            [self resetSelectedFrameWithIndex:index transition:NO animation:!_configuration.isCloseSelectedAnimation];
        }
            break;
        case ALWTitleTabBarSelectedTypeLine:{
            [self resetSelectedLineWithIndex:index transition:NO animation:!_configuration.isCloseSelectedAnimation];
        }
            break;
    }
    
    [self resetScrollViewContentOffsetWithIndex:index];
}

- (void)resetSelectedFrameWithIndex:(NSInteger)index transition:(BOOL)transition animation:(BOOL)animation
{
    _currentSelectedIndex = index;
    
    UILabel *currentLabel = _topLabelArray[index];
    CGFloat textWidth = [_titleWidthArray[index] floatValue];
    CGFloat frameWidth = textWidth + _configuration.framePadding * 2;
    CGFloat originX = currentLabel.center.x - frameWidth / 2.0;
    
    void (^resetFrameBlock)(void) = ^{
        CGRect rect = _frameView.frame;
        rect.size.width = frameWidth;
        rect.origin.x = originX;
        _frameView.frame = rect;
    };
    
    if (animation) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            resetFrameBlock();
        }];
    } else {
        resetFrameBlock();
    }
    
    if (transition) {
        void (^resetShowLayerBlock)(void) = ^{
            //以下代码，自带了过渡动画
            CGRect rect = _showLayer.frame;
            rect.size.width = frameWidth;
            rect.origin.x = originX;
            _showLayer.frame = rect;
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius:_configuration.frameCorner];
            _showLayer.path = bezierPath.CGPath;
        };
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            resetShowLayerBlock();
        }];
    } else {
        [_bottomLabelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index == idx) {
                [obj setTextColor:_configuration.titleHighlightColor];
            } else {
                [obj setTextColor:_configuration.titleNormalColor];
            }
        }];
    }
}

- (void)resetSelectedLineWithIndex:(NSInteger)index transition:(BOOL)transition animation:(BOOL)animation
{
    _currentSelectedIndex = index;

    UILabel *currentLabel = _topLabelArray[index];
    CGFloat textWidth = [_titleWidthArray[index] floatValue];
    CGFloat lineWidth = textWidth + _configuration.linePadding * 2;
    CGFloat originX = currentLabel.center.x - lineWidth / 2.0;
    
    void (^resetLineBlock)(void) = ^{
        CGRect rect = _lineView.frame;
        rect.size.width = lineWidth;
        rect.origin.x = originX;
        _lineView.frame = rect;
    };
    
    if (animation) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            resetLineBlock();
        }];
    } else {
        resetLineBlock();
    }
    
    if (transition) {
        void (^resetShowLayerBlock)(void) = ^{
            //以下代码，自带了过渡动画
            CGRect rect = _showLayer.frame;
            rect.size.width = lineWidth;
            rect.origin.x = originX;
            _showLayer.frame = rect;
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius:0];
            _showLayer.path = bezierPath.CGPath;
        };
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            resetShowLayerBlock();
        }];
    } else {
        [_bottomLabelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index == idx) {
                [obj setTextColor:_configuration.titleHighlightColor];
            } else {
                [obj setTextColor:_configuration.titleNormalColor];
            }
        }];
    }
}

- (void)resetScrollViewContentOffsetWithIndex:(NSInteger)index
{
    if (_configuration.isCloseAutoScrollToCenter) {
        return;
    }
    
    UILabel *currentLabel = _topLabelArray[index];
    CGFloat centerX = currentLabel.center.x;
    
    CGFloat width = self.frame.size.width;
    
    if (width / 2.0 < centerX && centerX < _scrollView.contentSize.width - width / 2.0) {
        [_scrollView setContentOffset:CGPointMake(centerX - width / 2.0, 0) animated:YES];
    } else if (centerX < width / 2.0) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (centerX > _scrollView.contentSize.width - width / 2.0) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentSize.width - width, 0) animated:YES];
    }
}

@end
