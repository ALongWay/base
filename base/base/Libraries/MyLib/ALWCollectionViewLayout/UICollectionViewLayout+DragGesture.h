//
//  UICollectionViewLayout+DragGesture.h
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - ALWCollectionViewDataSource
@protocol ALWCollectionViewDataSource <UICollectionViewDataSource>
@required
//决定item是否可以移动或者被移动
- (BOOL)alw_collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

//此方法用于数据源交换数据(如果部分item不能被移动，需要特别注意自行实现数据的交换算法)
- (void)alw_collectionView:(UICollectionView *)collectionView willMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

//此方法可用于重载数据
- (void)alw_collectionView:(UICollectionView *)collectionView didMovedItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end

#pragma mark - ALWCollectionViewDelegate
@protocol ALWCollectionViewDelegate <UICollectionViewDelegate>
@optional
- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - UICollectionViewLayout (DragGesture)
@interface UICollectionViewLayout (DragGesture)

/**
 *  启用自定义的拖拽手势，默认NO
 */
@property (assign, nonatomic) BOOL                      enableCustomDragGesture;

/**
 *  当前被拖拽的item
 */
@property (strong, nonatomic, readonly) NSIndexPath     *selectedItemIndexPath;

@end
