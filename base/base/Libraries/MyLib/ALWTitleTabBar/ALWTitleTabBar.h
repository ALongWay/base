//
//  ALWTitleTabBar.h
//  base
//
//  Created by 李松 on 2017/1/23.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALWTitleTabBarConfiguration.h"

@protocol ALWTitleTabBarDelegate <NSObject>

- (BOOL)ALWTitleTabBarShouldSelectTitleWithIndex:(NSInteger)index;

- (void)ALWTitleTabBarDidSelectedTitleWithIndex:(NSInteger)index;

@end

@interface ALWTitleTabBar : UIView

@property (nonatomic, assign, readonly) NSInteger   currentSelectedIndex;

@property (nonatomic, weak) id<ALWTitleTabBarDelegate>  delegate;

- (instancetype)init;

- (instancetype)initWithFrame:(CGRect)frame;

/**
 使用默认配置

 @param titleArray titleArray description
 */
- (void)resetTitleTabBarWithTitleArray:(NSArray<NSString *> *)titleArray;

- (void)resetTitleTabBarWithTitleArray:(NSArray<NSString *> *)titleArray configuration:(ALWTitleTabBarConfiguration *)configuration;

@end
