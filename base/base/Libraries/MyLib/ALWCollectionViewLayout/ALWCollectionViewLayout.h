//
//  ALWCollectionViewLayout.h
//  base
//
//  Created by 李松 on 16/10/24.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - ALWCollectionViewFlowLayout
#pragma mark -- ALWCollectionViewDelegateFlowLayout
@protocol ALWCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

@interface ALWCollectionViewFlowLayout : UICollectionViewFlowLayout

@end

#pragma mark - ALWCollectionViewLayout
@interface ALWCollectionViewLayout : UICollectionViewLayout

@end