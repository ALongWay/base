//
//  ALWPageControl.h
//  base
//
//  Created by 李松 on 2017/1/16.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALWPageControl : UIView

@property (nonatomic, assign) UIEdgeInsets  marginInsets;
@property (nonatomic, assign) CGFloat       pointMidInset;
@property (nonatomic, assign) CGSize        pointSize;
@property (nonatomic, assign) CGFloat       pointCorner;
@property (nonatomic, assign) CGFloat       pointBorderWidth;
@property (nonatomic, strong) UIColor       *pointBorderColor;
@property (nonatomic, strong) UIColor       *pointNormalColor;
@property (nonatomic, strong) UIColor       *pointSelectedColor;

@property (nonatomic, assign) NSInteger     currentPageIndex;

- (instancetype)init;

- (void)resetPageControlWithCount:(NSInteger)count;

@end
