//
//  ALWStarView.m
//  base
//
//  Created by 李松 on 16/11/3.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWStarView.h"

#define kStarViewCOLORWITHRGBA(R, G, B, A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define kStarViewCOLOR(R, G, B)                 COLORWITHRGBA(R, G, B, 1.0)

static const NSInteger kDefaultTopPointCount = 5;
static const CGFloat kDefaultRadius = 60;

@interface ALWStarView (){
    NSInteger       _topPointCount;
    CGFloat         _radius;
}

@property (nonatomic, strong) CAShapeLayer      *maskLayer;
@property (nonatomic, strong) CAShapeLayer      *bgShapeLayer;
@property (nonatomic, strong) CAShapeLayer      *starShapeLayer;

@end

@implementation ALWStarView

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
    self = [self initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];

    _topPointCount = MAX(count, kDefaultTopPointCount);
    _radius = radius;

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _topPointCount = kDefaultTopPointCount;
        _radius = frame.size.width / 2.0;

        [self setBackgroundColor:kStarViewCOLOR(240, 240, 240)];
        
        UITapGestureRecognizer *tapStarGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedStarView:)];
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:tapStarGest];
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = self.bounds;
        
        _bgShapeLayer = [CAShapeLayer layer];
        _bgShapeLayer.frame = self.bounds;
        _bgShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _bgShapeLayer.strokeColor = [UIColor redColor].CGColor;
        _bgShapeLayer.strokeStart = 0.0;
        _bgShapeLayer.strokeEnd = 1.0;
        _bgShapeLayer.lineWidth = 5;
        _bgShapeLayer.lineCap = kCALineCapRound;
        
        _starShapeLayer = [CAShapeLayer layer];
        _starShapeLayer.frame = self.bounds;
//        _starShapeLayer.fillColor = [UIColor redColor].CGColor;
        _starShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _starShapeLayer.strokeColor = [UIColor blueColor].CGColor;
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
    
//    self.layer.mask = _maskLayer;
//    [_bgShapeLayer addSublayer:_starShapeLayer];
    [self.layer addSublayer:_bgShapeLayer];
    [self.layer addSublayer:_starShapeLayer];
}

- (void)resetSublayerPath
{
    UIBezierPath *maskBezierPath = [UIBezierPath bezierPathWithOvalInRect:_maskLayer.bounds];
    _maskLayer.path = maskBezierPath.CGPath;
    
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

#define UseEquation
#ifdef UseEquation
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
            F_y = (b1 * k2 - b2 * k1) / (k2 - k1);
            F_x = (F_y - b1) / k1;
        }

        CGPoint pointF = CGPointMake(F_x, F_y);
        [crossPointsArray addObject:[NSValue valueWithCGPoint:pointF]];
    }
#else
    for (int i = 0; i < kTopPointCount; i++) {
        CGPoint pointA = [keyPointsArray[i] CGPointValue];
        CGPoint pointB;
        
        if (i == kTopPointCount - 1) {
            pointB = [keyPointsArray[0] CGPointValue];
        } else {
            pointB = [keyPointsArray[i + 1] CGPointValue];
        }
        
        CGPoint midPoint = CGPointMake((pointA.x + pointB.x) / 2.0, (pointA.y + pointB.y) / 2.0);
        CGPoint keyPoint = CGPointMake((midPoint.x + center.x) / 2.0, (midPoint.y + center.y) / 2.0);
        
        [crossPointsArray addObject:[NSValue valueWithCGPoint:keyPoint]];
    }
#endif
    
    //合并数据
    for (int i = 0; i < crossPointsArray.count; i++) {
        [keyPointsArray insertObject:crossPointsArray[i] atIndex:(i * 2 + 1)];
    }
    
    return keyPointsArray;
}

- (void)didClickedStarView:(UITapGestureRecognizer *)tapGest
{
    if (_bgShapeLayer.animationKeys.count) {
        [_bgShapeLayer removeAllAnimations];
    } else {
        CABasicAnimation *animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animationRotation.fromValue = @(0);
        animationRotation.toValue = @(2 * M_PI);
        animationRotation.duration = 3;
        animationRotation.repeatCount = MAXFLOAT;
        [_bgShapeLayer addAnimation:animationRotation forKey:@"rotation"];
        
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
        
        [_bgShapeLayer addAnimation:group forKey:@"strokeStarPath"];
    }
}

@end
