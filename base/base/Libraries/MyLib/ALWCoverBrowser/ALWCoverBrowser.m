//
//  ALWCoverBrowser.m
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCoverBrowser.h"

static NSString *const kCollectionViewCellIdentifier = @"CoverBrowserCellIdentifier";
static const NSInteger kItemCount = 9;
static const CGFloat kItemMaxAngle = DegreesToRadian(20);

#pragma mark -
@interface ALWCoverItemConfiguration : NSObject

@property (nonatomic, assign) CGSize        itemSize;
@property (nonatomic, assign) CGFloat       transformAngle;

@end

@implementation ALWCoverItemConfiguration


@end

#pragma mark -
@interface ALWCoverBrowser ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>{
    UICollectionView        *_collectionView;
    
    NSMutableArray<ALWCoverItemConfiguration *>     *_itemConfigArray;
    NSInteger               _contentCenterIndex;
    CGFloat                 _contentCenterX;
    
    CGSize                  _itemMaxSize;
    CGSize                  _itemMinSize;
    CGFloat                 _itemMidInset;
}

@end

@implementation ALWCoverBrowser

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        _itemMaxSize = CGSizeMake(height, height);
        _itemMinSize = CGSizeMake(height * 0.76, height * 0.76);
        _itemMidInset = 10;
        
        _itemConfigArray = [NSMutableArray arrayWithCapacity:kItemCount];
        _contentCenterIndex = kItemCount / 2;
        _contentCenterX = (_itemMinSize.width + _itemMidInset) * _contentCenterIndex + _itemMaxSize.width / 2.0;
        
        for (int i = 0; i < kItemCount; i++) {
            if (i == _contentCenterIndex) {
                ALWCoverItemConfiguration *itemConfig = [[ALWCoverItemConfiguration alloc] init];
                itemConfig.itemSize = _itemMaxSize;
                itemConfig.transformAngle = 0;
                [_itemConfigArray addObject:itemConfig];
            } else if (i < _contentCenterIndex) {
                ALWCoverItemConfiguration *itemConfig = [[ALWCoverItemConfiguration alloc] init];
                itemConfig.itemSize = _itemMinSize;
                itemConfig.transformAngle = kItemMaxAngle;
                [_itemConfigArray addObject:itemConfig];
            } else{
                ALWCoverItemConfiguration *itemConfig = [[ALWCoverItemConfiguration alloc] init];
                itemConfig.itemSize = _itemMinSize;
                itemConfig.transformAngle = -kItemMaxAngle;
                [_itemConfigArray addObject:itemConfig];
            }
        }
        
        ALWCollectionViewFlowLayout *layout = [[ALWCollectionViewFlowLayout alloc] initWithCustomFlowLayout];
        layout.itemFixedSide = height;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
        [self addSubview:_collectionView];
        
        [_collectionView setContentOffset:CGPointMake(_contentCenterX - _collectionView.frame.size.width / 2.0, 0) animated:NO];
    }
    
    return self;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    return config.itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _itemMidInset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemConfigArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    if (!label) {
        label = [[UILabel alloc] init];
        [label setBackgroundColor:COLOR(240, 240, 240)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:COLOR(0, 0, 0)];
        label.tag = 1;
        [cell.contentView addSubview:label];
    }
    
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    CGSize itemSize = config.itemSize;
    label.frame = CGRectMake(0, 0, itemSize.width, itemSize.height);
    label.center = CGPointMake(itemSize.width / 2.0, _itemMaxSize.height / 2.0);
    [label setText:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
    
    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"clicked index : %d", (int)indexPath.row);
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat visibleCenterX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    
    //变换动画期间移动的距离
    CGFloat animationDistance = (_itemMaxSize.width + _itemMinSize.width) / 2.0 + _itemMidInset;
    
    NSArray *visibleCellArray = [_collectionView visibleCells];
    
    for (int i = 0; i < visibleCellArray.count; i++) {
        UICollectionViewCell *cell = visibleCellArray[i];
        NSInteger row = [_collectionView indexPathForCell:cell].row;
        ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:row];
        
        CGFloat distance = visibleCenterX - cell.center.x;
        
        if (fabs(distance) > animationDistance) {
            config.itemSize = _itemMinSize;
        } else if (distance == 0) {
            config.itemSize = _itemMaxSize;
        } else {
            CGFloat rate = 1 - fabs(distance) / animationDistance;
            CGFloat nowWidth = _itemMinSize.width + (_itemMaxSize.width - _itemMinSize.width) * rate;
            CGFloat nowHeight = _itemMinSize.height + (_itemMaxSize.height - _itemMinSize.height) * rate;
            
            config.itemSize = CGSizeMake(nowWidth, nowHeight);
        }
    }
    
    [_collectionView reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat visibleCenterX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    
    CGFloat minDistance = 0;
    UICollectionViewCell *currentCenterCell;
    
    NSArray *visibleCellArray = [_collectionView visibleCells];
    
    for (int i = 0; i < visibleCellArray.count; i++) {
        UICollectionViewCell *cell = visibleCellArray[i];
        
        CGFloat distance = fabs(visibleCenterX - cell.center.x);
        
        if (i == 0) {
            minDistance = distance;
            currentCenterCell = cell;
        }else{
            if (distance < minDistance) {
                minDistance = distance;
                currentCenterCell = cell;
            }
        }
    }
    
    [_collectionView setContentOffset:CGPointMake(currentCenterCell.center.x + scrollView.frame.size.width / 2.0, 0) animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat visibleCenterX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    
    CGFloat minDistance = 0;
    UICollectionViewCell *currentCenterCell;
    
    NSArray *visibleCellArray = [_collectionView visibleCells];
    
    for (int i = 0; i < visibleCellArray.count; i++) {
        UICollectionViewCell *cell = visibleCellArray[i];
        
        CGFloat distance = fabs(visibleCenterX - cell.center.x);
        
        if (i == 0) {
            minDistance = distance;
            currentCenterCell = cell;
        }else{
            if (distance < minDistance) {
                minDistance = distance;
                currentCenterCell = cell;
            }
        }
    }
    
    [_collectionView setContentOffset:CGPointMake(currentCenterCell.center.x + scrollView.frame.size.width / 2.0, 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

}

#pragma mark -- Private methods
- (void)refreshItemConfiguration
{
   
}

@end
