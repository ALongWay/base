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
    ALWCollectionViewFlowLayoutTypeDefault = 0,//默认布局
    ALWCollectionViewFlowLayoutTypeOrder,//按照数据源顺序，依次排列。要求item的与滑动方向垂直的边长度相等。
    ALWCollectionViewFlowLayoutTypeFill,//根据数据源顺序和当前每列占用的最大高度决定位置。要求item的与滑动方向垂直的边长度相等。
};

#pragma mark - ALWCollectionViewDelegateFlowLayout
@protocol ALWCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

#pragma mark - ALWCollectionViewFlowLayout
@interface ALWCollectionViewFlowLayout : UICollectionViewFlowLayout

- (instancetype)initWithALWCollectionViewFlowLayoutType:(ALWCollectionViewFlowLayoutType)type;

@end
