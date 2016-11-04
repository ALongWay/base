//
//  ALWStarCommentView.m
//  base
//
//  Created by 李松 on 16/11/4.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWStarCommentView.h"

static const NSInteger kDefaultStarsCount = 5;
static const CGFloat kStarsMidInset = 10;
static const CGFloat kDefaultScorePerStar = 1.0;

@interface ALWStarCommentView ()<ALWStarViewDelegate>{
    NSMutableArray<ALWStarView*>    *_starsArray;
    
    NSInteger                       _starsCount;
}

@end

@implementation ALWStarCommentView

+ (ALWStarCommentView *)getDefaultStarCommentView
{
    ALWStarCommentView *starCommentView = [[ALWStarCommentView alloc] init];
    
    return starCommentView;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _starsCount = kDefaultStarsCount;
        _starsArray = [NSMutableArray arrayWithCapacity:_starsCount];
        
        for (int i = 0; i < _starsCount; i++) {
            ALWStarView *star = [ALWStarView getDefaultStarView];
            star.delegate = self;
            star.tag = i;
            
            star.frame = CGRectMake(i * (star.frame.size.width + kStarsMidInset), 0, star.frame.size.width, star.frame.size.height);
            
            _starsArray[i] = star;
            [self addSubview:star];
        }
        
        ALWStarView *lastStar = [_starsArray lastObject];
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, CGRectGetMaxX(lastStar.frame), lastStar.frame.size.height);
    }
    
    return self;
}

#pragma mark -- Setter/getter
- (void)setEnableTap:(BOOL)enableTap
{
    _enableTap = enableTap;
    
    [_starsArray enumerateObjectsUsingBlock:^(ALWStarView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableTap = enableTap;
    }];
}

- (void)setTotalScore:(CGFloat)totalScore
{
    _totalScore = totalScore;
    
    NSInteger maxIndex = (totalScore - 1) / kDefaultScorePerStar;
    CGFloat addedScore = totalScore - (maxIndex + 1) * kDefaultScorePerStar;
    if (addedScore > 0) {
        maxIndex += 1;
    }
    
    [_starsArray enumerateObjectsUsingBlock:^(ALWStarView * _Nonnull starView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < maxIndex) {
            [starView setSelectedPercent:1];
        } else if (idx == maxIndex) {
            [starView setSelectedPercent:(addedScore / kDefaultScorePerStar)];
        } else {
            [starView setSelectedPercent:0];
        }
    }];
}

#pragma mark -- ALWStarViewDelegate
- (BOOL)alwStarView:(ALWStarView *)starView shouldBeEffectiveWithPercent:(CGFloat)percent
{
    if (percent == 0) {
        return NO;
    }
    
    return YES;
}

- (void)alwStarView:(ALWStarView *)starView didClickedWithPercent:(CGFloat)percent
{
    NSInteger currentIndex = starView.tag;
    CGFloat score = 0;
    
    for (int i = 0; i < _starsArray.count; i++) {
        ALWStarView *starView = _starsArray[i];
        
        if (i < currentIndex) {
            score += kDefaultScorePerStar;
            [starView setSelectedPercent:1];
        } else if (i == currentIndex) {
            score += percent * kDefaultScorePerStar;
            [starView setSelectedPercent:percent];
        } else {
            [starView setSelectedPercent:0];
        }
    }
    
    _totalScore = score;
    
    LOG(@"_totalScore : %f", _totalScore);
    
    if ([self.delegate respondsToSelector:@selector(alwStarCommentViewDidSelectedTotalScore:)]) {
        [self.delegate alwStarCommentViewDidSelectedTotalScore:_totalScore];
    }
}

@end
