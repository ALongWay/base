//
//  ALWStarView.h
//  base
//
//  Created by 李松 on 16/11/3.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALWStarViewDelegate;

@interface ALWStarView : UIView

@property (nonatomic, assign) BOOL                    enableTap;
@property (nonatomic, strong) UIColor                *bgColor;
@property (nonatomic, strong) UIColor                *fillColor;
@property (nonatomic, strong) UIColor                *borderColor;

@property (nonatomic, assign, readwrite) CGFloat      selectedPercent;

@property (nonatomic, weak) id<ALWStarViewDelegate>   delegate;

+ (ALWStarView *)getDefaultStarView;

/**
 *  自定义半径，默认五角星
 *
 *  @param radius 半径
 *
 *  @return return value description
 */
- (instancetype)initWithRadius:(CGFloat)radius;

/**
 *  自定义半径和外顶点数量
 *
 *  @param radius 半径
 *  @param count  顶点数量
 *
 *  @return return value description
 */
- (instancetype)initWithRadius:(CGFloat)radius topPointCount:(NSUInteger)count;

@end

@protocol ALWStarViewDelegate <NSObject>

@optional
//percent目前只可能为0，0.5，1
- (void)alwStarView:(ALWStarView *)starView didClickedWithPercent:(CGFloat)percent;

- (BOOL)alwStarView:(ALWStarView *)starView shouldBeEffectiveWithPercent:(CGFloat)percent;

@end