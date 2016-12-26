//
//  ALWCoverBrowserLayout.h
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALWCoverBrowserLayoutDelegate <UICollectionViewDelegate>

@required
- (CGSize)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout spacingForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout angleForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ALWCoverBrowserLayout : UICollectionViewLayout

@property (nonatomic, assign) UICollectionViewScrollDirection   itemScrollDirection;

@end
