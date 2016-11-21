//
//  ALWCoverBrowserLayout.m
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCoverBrowserLayout.h"

@interface ALWCoverBrowserLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*>     *itemAttributesArray;
@property (nonatomic, assign) CGSize    contentSize;

@end

@implementation ALWCoverBrowserLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    //重写布局
    NSInteger itemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    _itemAttributesArray = [NSMutableArray arrayWithCapacity:itemCount];
    
    id<ALWCoverBrowserLayoutDelegate> delegate = (id<ALWCoverBrowserLayoutDelegate>)self.collectionView.delegate;

    CGFloat offsetX = 0;
    
    for (int i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGSize itemSize = [delegate cb_collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        CGFloat rightSpacing = [delegate cb_collectionView:self.collectionView layout:self rightSpacingForItemAtIndexPath:indexPath];
        CGFloat angle = [delegate cb_collectionView:self.collectionView layout:self angleForItemAtIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(offsetX, (self.collectionView.frame.size.height - itemSize.height) / 2.0, itemSize.width, itemSize.height);
        CATransform3D rotation = CATransform3DMakeRotation(angle, 0, 1, 0);
        attributes.transform3D = CATransform3DPerspect(rotation, CGPointMake(0, 0), 500);
                
        [_itemAttributesArray addObject:attributes];
        
        if (i == itemCount - 1) {
            offsetX += itemSize.width;
        } else {
            offsetX += itemSize.width + rightSpacing;
        }
    }
    
    _contentSize = CGSizeMake(offsetX, self.collectionView.frame.size.height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{    
    return _itemAttributesArray;
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

#pragma mark -- 3D透视效果函数
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

@end
