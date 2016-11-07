//
//  ALWStarView.m
//  base
//
//  Created by 李松 on 16/11/3.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWStarView.h"

#define kStarViewCOLORWITHRGBA(R, G, B, A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define kStarViewCOLOR(R, G, B)                 kStarViewCOLORWITHRGBA(R, G, B, 1.0)

#define kDefaultBgColor                         kStarViewCOLOR(240, 240, 240)
#define kDefaultFillColor                       [UIColor yellowColor]
#define kDefaultBorderColor                     kStarViewCOLOR(255, 120, 100)

static const NSInteger kDefaultTopPointCount = 5;
static const CGFloat kDefaultRadius = 15;

@interface ALWStarView (){
    CAShapeLayer    *_maskLayer;
    CAShapeLayer    *_bgShapeLayer;
    CAShapeLayer    *_starShapeLayer;
    
    NSInteger       _topPointCount;
    CGFloat         _radius;
}

@end

@implementation ALWStarView

+ (ALWStarView *)getDefaultStarView
{
    return [[ALWStarView alloc] init];
}

- (instancetype)init
{
    return [self initWithRadius:kDefaultRadius];
}

- (instancetype)initWithRadius:(CGFloat)radius
{
    return [self initWithRadius:radius topPointCount:kDefaultTopPointCount];
}

- (instancetype)initWithRadius:(CGFloat)radius topPointCount:(NSUInteger)count
{
    _topPointCount = count;
    
    return [self initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableTap = NO;
        _bgColor = kDefaultBgColor;
        _fillColor = kDefaultFillColor;
        _borderColor = kDefaultBorderColor;
        
        _topPointCount = MAX(_topPointCount, kDefaultTopPointCount);
        _radius = frame.size.width / 2.0;

        [self setBackgroundColor:_bgColor];
        
        UITapGestureRecognizer *tapStarGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedStarView:)];
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:tapStarGest];
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = self.bounds;
        
        _bgShapeLayer = [CAShapeLayer layer];
        _bgShapeLayer.frame = self.bounds;
        _bgShapeLayer.backgroundColor = _fillColor.CGColor;
        _bgShapeLayer.fillColor = [UIColor clearColor].CGColor;
      
        _starShapeLayer = [CAShapeLayer layer];
        _starShapeLayer.frame = self.bounds;
        _starShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _starShapeLayer.strokeColor = _borderColor.CGColor;
        _starShapeLayer.strokeStart = 0;
        _starShapeLayer.strokeEnd = 1;
        _starShapeLayer.lineWidth = 1;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self resetSublayerPath];
    
    self.layer.mask = _maskLayer;
    [self.layer addSublayer:_bgShapeLayer];
    [self.layer addSublayer:_starShapeLayer];
}

#pragma mark -- Setter/getter
- (void)setSelectedPercent:(CGFloat)selectedPercent
{
    _selectedPercent = selectedPercent;
    
    CGRect rect = _bgShapeLayer.frame;
    rect.size.width = self.bounds.size.width * _selectedPercent;
    _bgShapeLayer.frame = rect;
}

#pragma mark -- Private methods
- (void)resetSublayerPath
{
//    UIBezierPath *maskBezierPath = [UIBezierPath bezierPathWithOvalInRect:_maskLayer.bounds];
//    _maskLayer.path = maskBezierPath.CGPath;

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_bgShapeLayer.frame.size.width / 2.0, _bgShapeLayer.frame.size.height / 2.0) radius:_radius startAngle:0 endAngle: 2 * M_PI clockwise:YES];
    _bgShapeLayer.path = bezierPath.CGPath;
    
    NSArray *keyPointsArray = [self getStarKeyPoints];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint firstPoint = [[keyPointsArray firstObject] CGPointValue];
    CGPathMoveToPoint(path, nil, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < keyPointsArray.count; i++) {
        CGPoint currentPoint = [keyPointsArray[i] CGPointValue];
        CGPathAddLineToPoint(path, nil, currentPoint.x, currentPoint.y);
    }
    
    CGPathAddLineToPoint(path, nil, firstPoint.x, firstPoint.y);
    
    _maskLayer.path = path;
    _starShapeLayer.path = path;
    CGPathRelease(path);
}

- (NSArray *)getStarKeyPoints
{
    CGPoint center = CGPointMake(self.frame.size.width / 2.0, _radius);
    CGFloat sectionAngle = 2 * M_PI / _topPointCount;
    
    NSMutableArray *keyPointsArray = [NSMutableArray array];
    CGPoint firstPoint = CGPointMake(center.x, 0);
    [keyPointsArray addObject:[NSValue valueWithCGPoint:firstPoint]];
    
    //外围顶点
    for (int i = 1; i < _topPointCount; i++) {
        CGFloat x = cosf(i * sectionAngle - M_PI_2) * _radius;
        CGFloat y = sinf(i * sectionAngle - M_PI_2) * _radius;
        
        CGPoint point = CGPointMake(x + center.x, y + center.y);
        
        [keyPointsArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    //内交点
    NSMutableArray *crossPointsArray = [NSMutableArray array];

    //采用二元一次方程求解
    //AC点确定直线方程y = kx + b
    //过B点直线y = B.y
    for (int i = 0; i < _topPointCount; i++) {
        CGPoint A = [keyPointsArray[i] CGPointValue];
        
        NSInteger index = i + 1;
        if (index > _topPointCount - 1) {
            index -= _topPointCount;
        }
        CGPoint B = [keyPointsArray[index] CGPointValue];
        
        index = i + 2;
        if (index > _topPointCount - 1) {
            index -= _topPointCount;
        }
        CGPoint C = [keyPointsArray[index] CGPointValue];
        
        index = i - 1;
        if (index < 0) {
            index += _topPointCount;
        }
        CGPoint E = [keyPointsArray[index] CGPointValue];
        
        CGFloat F_x = 0.0, F_y = 0.0, k1 = 0.0, k2 = 0.0, b1 = 0.0, b2 = 0.0;
        
        if (A.x == C.x) {
            F_x = A.x;
        } else {
            k1 = (A.y - C.y) / (A.x - C.x);
            b1 = A.y - k1 * A.x;
        }
        
        if (B.x == E.x) {
            F_x = B.x;
        } else {
            k2 = (B.y - E.y) / (B.x - E.x);
            b2 = B.y - k2 * B.x;
        }
        
        if (A.x == C.x) {
            F_y = k2 * F_x + b2;
        }else if (B.x == E.x) {
            F_y = k1 * F_x + b1;
        }else{
            if (k1 == 0) {
                F_y = A.y;
                F_x = (F_y - b2) / k2;
            } else {
                F_y = (b1 * k2 - b2 * k1) / (k2 - k1);
                F_x = (F_y - b1) / k1;
            }
        }

        CGPoint pointF = CGPointMake(F_x, F_y);
        [crossPointsArray addObject:[NSValue valueWithCGPoint:pointF]];
    }
    
    //合并数据
    for (int i = 0; i < crossPointsArray.count; i++) {
        [keyPointsArray insertObject:crossPointsArray[i] atIndex:(i * 2 + 1)];
    }
    
    return keyPointsArray;
}

- (void)didClickedStarView:(UITapGestureRecognizer *)tapGest
{
    if (!self.enableTap) {
        return;
    }

//    [self addAnimation];
    
    //点击范围
    CGFloat percent = 0;
    CGPoint touchPoint = [tapGest locationInView:tapGest.view];
    CGPoint center = CGPointMake(self.frame.size.width / 2.0, _radius);
    CGFloat distance = sqrtf(powf(touchPoint.x - center.x, 2) + powf(touchPoint.y - center.y, 2));
    
    if (distance < _radius) {
        //判断左右范围
        if (touchPoint.x < center.x) {
            percent = 0.5;
        } else {
            percent = 1;
        }
    }else{
        percent = 0;
    }
    
    BOOL beEffective = YES;
    if ([self.delegate respondsToSelector:@selector(alwStarView:shouldBeEffectiveWithPercent:)]) {
        beEffective = [self.delegate alwStarView:self shouldBeEffectiveWithPercent:percent];
    }
    
    if (beEffective) {
        self.selectedPercent = percent;//setter方法
        
        if ([self.delegate respondsToSelector:@selector(alwStarView:didClickedWithPercent:)]) {
            [self.delegate alwStarView:self didClickedWithPercent:percent];
        }
    }
}

- (void)addAnimation
{
    if (_starShapeLayer.animationKeys.count) {
        [_starShapeLayer removeAllAnimations];
    } else {
        CABasicAnimation *animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animationRotation.fromValue = @(0);
        animationRotation.toValue = @(2 * M_PI);
        animationRotation.duration = 3;
        animationRotation.repeatCount = MAXFLOAT;
        [_starShapeLayer addAnimation:animationRotation forKey:@"rotation"];
        
        CABasicAnimation *animationEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animationEnd.fromValue = @(0);
        animationEnd.toValue = @(1);
        animationEnd.duration = 1;
        animationEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        CABasicAnimation *animationStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animationStart.fromValue = @(0);
        animationStart.toValue = @(1);
        animationStart.duration = 1;
        animationStart.beginTime = 1;
        animationEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[animationEnd, animationStart];
        group.duration = 2;
        group.repeatCount = MAXFLOAT;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = YES;
        
        [_starShapeLayer addAnimation:group forKey:@"strokeStarPath"];
    }
}

@end
