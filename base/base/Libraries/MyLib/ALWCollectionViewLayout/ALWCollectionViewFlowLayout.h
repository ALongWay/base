//
//  ALWCollectionViewFlowLayout.h
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout+DragGesture.h"

#pragma mark - ALWCollectionViewDelegateFlowLayout
@protocol ALWCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

#pragma mark - ALWCollectionViewFlowLayout
@interface ALWCollectionViewFlowLayout : UICollectionViewFlowLayout

@end
