//
//  ALWScratchCardView.m
//  base
//
//  Created by 李松 on 2016/11/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWScratchCardView.h"

#define kScratchCardCOLORWITHRGBA(R, G, B, A)       [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define kScratchCardCOLOR(R, G, B)                  kScratchCardCOLORWITHRGBA(R, G, B, 1.0)

#define kDefaultBorderColor                         kScratchCardCOLOR(230, 230, 230)

static CGFloat const kDefaultLineWidth = 20;
static NSInteger const kMinPointCountPerPath = 2;

@interface ALWScratchCardView (){
    UIView              *_bgIV;
    UIView              *_contentIV;
    
    NSMutableArray      *_pathArray;
    NSMutableArray      *_currentPointsArray;
}

@end

@implementation ALWScratchCardView
@synthesize lineWidth = _lineWidth;

- (instancetype)initWithContentView:(UIView *)contentView coverView:(UIView *)coverView
{
    self = [super initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    if (self) {
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.5];
        [self.layer setBorderColor:kDefaultBorderColor.CGColor];
        [self setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFingerOnSelfViewWith:)];
        [self addGestureRecognizer:panGest];
        
        _bgIV = coverView;
        _bgIV.frame = coverView.bounds;
        [self addSubview:_bgIV];
        
        _contentIV = contentView;
        _contentIV.frame = contentView.bounds;
        [self addSubview:_contentIV];
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = _contentIV.bounds;
        _contentIV.layer.mask = maskLayer;
        
        _pathArray = [NSMutableArray array];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.5];
        [self.layer setBorderColor:kDefaultBorderColor.CGColor];
        [self setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFingerOnSelfViewWith:)];
        [self addGestureRecognizer:panGest];
        
        _bgIV = [[UIView alloc] initWithFrame:self.bounds];
        [_bgIV setBackgroundColor:kScratchCardCOLOR(240, 240, 240)];
        [self addSubview:_bgIV];
        
        _contentIV = [[UIView alloc] initWithFrame:self.bounds];
        [_contentIV setBackgroundColor:kScratchCardCOLOR(255, 120, 100)];
        [self addSubview:_contentIV];
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = _contentIV.bounds;
        _contentIV.layer.mask = maskLayer;
        
        UILabel *label = [[UILabel alloc] initWithFrame:_contentIV.bounds];
        [label setText:@"谢谢惠顾"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:kScratchCardCOLOR(0, 0, 0)];
        [label setFont:[UIFont boldSystemFontOfSize:30]];
        [_contentIV addSubview:label];
        
        _pathArray = [NSMutableArray array];
    }
    
    return self;
}

- (CGFloat)lineWidth
{
    if (_lineWidth == 0) {
        _lineWidth = kDefaultLineWidth;
    }

    return _lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
}

- (void)panFingerOnSelfViewWith:(UIPanGestureRecognizer *)panGest
{
    CGPoint currentPoint = [panGest locationInView:panGest.view];

    switch (panGest.state) {
        case UIGestureRecognizerStateBegan:{
            CAShapeLayer *sublayer = [CAShapeLayer layer];
            sublayer.frame = _contentIV.bounds;
            sublayer.fillColor = nil;
            sublayer.strokeColor = [UIColor blackColor].CGColor;
            sublayer.lineWidth = self.lineWidth;
            sublayer.lineCap = kCALineCapRound;
            sublayer.lineJoin = kCALineJoinRound;
            
            [_pathArray addObject:sublayer];
            
            _currentPointsArray = [NSMutableArray array];
            [_currentPointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            [_currentPointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];
            
            if (_currentPointsArray.count >= kMinPointCountPerPath) {
                //添加sublayer
                CGPoint firstPoint = [[_currentPointsArray firstObject] CGPointValue];
                
                UIBezierPath *bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint:firstPoint];
                
                for (int i = 1; i < _currentPointsArray.count; i++) {
                    CGPoint point = [_currentPointsArray[i] CGPointValue];
                    [bezierPath addLineToPoint:point];
                }
                
                CAShapeLayer *currentLayer = [_pathArray lastObject];
                currentLayer.path = bezierPath.CGPath;
                [_contentIV.layer.mask addSublayer:currentLayer];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if (_pathArray.count > 0) {
                CAShapeLayer *currentLayer = [_pathArray lastObject];
                if (_currentPointsArray
                    && _currentPointsArray.count < kMinPointCountPerPath) {
                    [_pathArray removeObject:currentLayer];
                }
            }
            
            if (_currentPointsArray) {
                [_currentPointsArray removeAllObjects];
                _currentPointsArray = nil;
            }
        }
            break;
        default:
            break;
    }
}

@end
