//
//  ALWCollectionViewLayout.h
//  base
//
//  Created by 李松 on 16/10/26.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout+DragGesture.h"

typedef NS_ENUM(NSInteger, ALWCollectionViewScrollDirection) {
    ALWCollectionViewScrollDirectionVertical,
    ALWCollectionViewScrollDirectionHorizontal
};

typedef NS_ENUM(NSInteger, ALWCollectionViewLayoutType) {
    ALWCollectionViewFlowLayoutTypeOrder = 0,//按照数据源顺序，依次排列。要求item的与滑动方向垂直的边长度相等。
    ALWCollectionViewFlowLayoutTypeFill,//根据数据源顺序和当前每列占用的最大高度决定位置。要求item的与滑动方向垂直的边长度相等。
};

@protocol ALWCollectionViewDelegateLayout <UICollectionViewDelegate>

@optional
//竖向滑动时有效
- (CGFloat)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

//横向滑动时有效
- (CGFloat)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout widthForItemAtIndexPath:(NSIndexPath *)indexPath;

- (UIEdgeInsets)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

- (UIColor *)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

@interface ALWCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign, readonly) ALWCollectionViewScrollDirection    scrollDirection;
@property (nonatomic, assign) ALWCollectionViewLayoutType                   layoutType;


/**
 初始为10
 */
@property (nonatomic, assign) CGFloat   itemHorizontalSpacing;//竖向滑动时自动计算

/**
 初始为10
 */
@property (nonatomic, assign) CGFloat   itemVerticalSpacing;//横向滑动时自动计算

/**
 采用竖向滑动来实例化

 @param count 列的数量
 @param width item的固定宽度

 @return return value description
 */
- (instancetype)initWithColumnCount:(NSInteger)count itemWidth:(CGFloat)width;

/**
 采用横向滑动来实例化

 @param count  行的数量
 @param height item的固定高度

 @return return value description
 */
- (instancetype)initWithRowCount:(NSInteger)count itemHeight:(CGFloat)height;

@end
