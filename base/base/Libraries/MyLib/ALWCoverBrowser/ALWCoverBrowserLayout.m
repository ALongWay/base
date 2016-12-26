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

    CGFloat offset = 0;
    
    for (int i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGSize itemSize = [delegate cb_collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        CGFloat spacing = [delegate cb_collectionView:self.collectionView layout:self spacingForItemAtIndexPath:indexPath];
        CGFloat angle = [delegate cb_collectionView:self.collectionView layout:self angleForItemAtIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        switch (_itemScrollDirection) {
            case UICollectionViewScrollDirectionVertical:{
                attributes.frame = CGRectMake((self.collectionView.frame.size.width - itemSize.width) / 2.0, offset, itemSize.width, itemSize.height);
                CATransform3D rotation = CATransform3DMakeRotation(-angle, 1, 0, 0);
                attributes.transform3D = CATransform3DPerspect(rotation, CGPointMake(0, 0), 1000);
                
                offset += itemSize.height;
            }
                break;
            case UICollectionViewScrollDirectionHorizontal:{
                attributes.frame = CGRectMake(offset, (self.collectionView.frame.size.height - itemSize.height) / 2.0, itemSize.width, itemSize.height);
                CATransform3D rotation = CATransform3DMakeRotation(angle, 0, 1, 0);
                attributes.transform3D = CATransform3DPerspect(rotation, CGPointMake(0, 0), MAX(self.collectionView.frame.size.width, self.collectionView.frame.size.height));
            
                offset += itemSize.width;
            }
                break;
        }
        
        [_itemAttributesArray addObject:attributes];
        
        if (i != itemCount - 1) {
            offset += spacing;
        }
    }
    
    switch (_itemScrollDirection) {
        case UICollectionViewScrollDirectionVertical:{
            _contentSize = CGSizeMake(self.collectionView.frame.size.width, offset);
        }
            break;
        case UICollectionViewScrollDirectionHorizontal:{
            _contentSize = CGSizeMake(offset, self.collectionView.frame.size.height);
        }
            break;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{    
    return _itemAttributesArray;
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

#pragma mark -- 3D透视投影效果函数
//在CALayer的显示系统中，默认的相机使用正交投影，正交投影没有远小近大效果
//构造透视投影矩阵的代码如下
//center指的是相机的位置，相机的位置是相对于要进行变换的CALayer的来说的，
//原点是CALayer的anchorPoint在整个CALayer的位置，例如CALayer的大小是(100, 200),
//anchorPoint值为(0.5, 0.5)，此时anchorPoint在整个CALayer中的位置就是(50, 100)，正中心的位置。
//传入透视变换的相机位置为(0, 0)，那么相机所在的位置相对于CALayer就是(50, 100)。
//如果希望相机在左上角，则需要传入(-50, -100)。disZ表示的是相机离z=0平面（也可以理解为屏幕）的距离
//CALayer的旋转和缩放是绕anchorPoint点的，改变anchorPoint的值，可以使Layer绕不同的点而不只是中心点旋转缩放。
//CATransform3D可以使用CATransform3DConcat函数连接起来以构造更复杂的变换
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
