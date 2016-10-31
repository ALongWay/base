//
//  ALWCollectionViewFlowLayout.h
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout+DragGesture.h"

typedef NS_ENUM(NSInteger, ALWCollectionViewFlowLayoutType) {
    ALWCollectionViewFlowLayoutTypeOrder = 0,//按照数据源顺序，依次排列。要求item的与滑动方向垂直的边长度相等。
    ALWCollectionViewFlowLayoutTypeFill,//根据数据源顺序和当前每列占用的最大高度决定位置。要求item的与滑动方向垂直的边长度相等。
};

#pragma mark - ALWCollectionViewDelegateFlowLayout
@protocol ALWCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

#pragma mark - ALWCollectionViewFlowLayout
@interface ALWCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  自定义流动布局类型
 */
@property (nonatomic, assign) ALWCollectionViewFlowLayoutType   flowLayoutType;

/**
 *  每一排（行/列）的item数量,默认为1
 */
@property (nonatomic, assign) NSInteger                         countPerLine;

/**
 *  固定边的长度（指与滑动方向垂直的边），默认为50
 */
@property (nonatomic, assign) CGFloat                           itemFixedSide;

/**
 *  UICollectionViewFlowLayout原初始化方法
 *
 *  @return return value description
 */
- (instancetype)init;

/**
 *  采用自定义的流动布局初始化，需要实现相关协议方法
 *
 *  @return return value description
 */
- (instancetype)initWithCustomFlowLayout;

@end

