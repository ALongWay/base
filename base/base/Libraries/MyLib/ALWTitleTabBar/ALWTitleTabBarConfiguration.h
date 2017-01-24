//
//  ALWTitleTabBarConfiguration.h
//  base
//
//  Created by 李松 on 2017/1/23.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ALWTitleTabBarSelectedType) {
    ALWTitleTabBarSelectedTypeFrame,
    ALWTitleTabBarSelectedTypeLine
};

@interface ALWTitleTabBarConfiguration : NSObject

@property (nonatomic, strong) UIFont        *titleFont;
@property (nonatomic, strong) UIColor       *titleNormalColor;
@property (nonatomic, strong) UIColor       *titleHighlightColor;

//内容view左右内边距
@property (nonatomic, assign) CGFloat       contentViewHorizontalPadding;

//titleView宽度是否相同，相同则不考虑内间距
@property (nonatomic, assign) BOOL          isEqualTitleViewWidth;
//titleView左右内边距
@property (nonatomic, assign) CGFloat       titleViewPadding;

@property (nonatomic, assign) ALWTitleTabBarSelectedType    selectedType;

//ALWTitleTabBarSelectedTypeLine相关属性
@property (nonatomic, assign) CGFloat       lineHeight;
@property (nonatomic, assign) CGFloat       linePadding;
@property (nonatomic, strong) UIColor       *lineColor;

//ALWTitleTabBarSelectedTypeFrame相关属性
@property (nonatomic, assign) CGFloat       frameHeight;
//选中框内边距
@property (nonatomic, assign) CGFloat       framePadding;
@property (nonatomic, assign) CGFloat       frameCorner;
@property (nonatomic, strong) UIColor       *frameColor;

//动画效果相关属性
//该效果不太理想，待优化完成后再启用
//是否关闭选择标题后过渡效果，默认YES
//@property (nonatomic, assign) BOOL          isCloseTransitionEffect;
//是否关闭选择动画效果，默认NO
@property (nonatomic, assign) BOOL          isCloseSelectedAnimation;
//是否关闭自动将选中项滑动到中间位置，默认NO
@property (nonatomic, assign) BOOL          isCloseAutoScrollToCenter;

+ (ALWTitleTabBarConfiguration *)getDefaultConfiguration;

@end
