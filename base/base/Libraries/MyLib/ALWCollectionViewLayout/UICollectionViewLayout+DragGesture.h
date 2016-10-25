//
//  UICollectionViewLayout+DragGesture.h
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
@protocol ALWCollectionViewDataSource <UICollectionViewDataSource>
@optional

- (BOOL)alw_collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

@end

#pragma mark -
@protocol ALWCollectionViewDelegate <UICollectionViewDelegate>
@optional
- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

#pragma mark -
@interface UICollectionViewLayout (DragGesture)

@end
