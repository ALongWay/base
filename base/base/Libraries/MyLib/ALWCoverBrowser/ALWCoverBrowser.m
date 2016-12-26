//
//  ALWCoverBrowser.m
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCoverBrowser.h"
#import "ALWCoverBrowserLayout.h"

static const NSInteger kItemMinCount = 7;

#pragma mark - ALWCoverItemConfiguration
@interface ALWCoverItemConfiguration : NSObject

@property (nonatomic, assign) CGSize        itemSize;
@property (nonatomic, assign) CGFloat       transformAngle;
@property (nonatomic, assign) CGFloat       spacing;
@property (nonatomic, assign) NSInteger     realIndex;

@end

@implementation ALWCoverItemConfiguration


@end

#pragma mark - ALWCoverBrowser
@interface ALWCoverBrowser ()<ALWCoverBrowserLayoutDelegate, UICollectionViewDataSource>{
    NSMutableArray<ALWCoverItemConfiguration *>     *_itemConfigArray;

    NSString                *_reuseCellIdentifier;
    NSInteger               _realItemCount;//不重复的数据数量
    
    NSInteger               _originalCenterIndex;
    NSInteger               _currentCenterIndex;
    
    CGSize                  _itemMaxSize;
    CGSize                  _itemMinSize;
    CGFloat                 _itemMidMaxInset;
    CGFloat                 _itemMidMinInset;
    CGFloat                 _itemTransform3DAngle;
    
    NSTimer                 *_autoScrollTimer;
}

@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) ALWCoverBrowserLayout     *layout;

@end

@implementation ALWCoverBrowser
@synthesize autoScrollDuration = _autoScrollDuration;

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 228 * ([UIScreen mainScreen].bounds.size.width / 375))];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat rate = frame.size.width / 375.0;
        _itemMaxSize = CGSizeMake(250 * rate, 228 * rate);
        _itemMinSize = CGSizeMake(_itemMaxSize.width * 0.76, _itemMaxSize.height * 0.76);
        _itemMidMaxInset = 50 * rate;
        _itemMidMinInset = 10 * rate;
        _itemTransform3DAngle = (M_PI * 20 / 180.0);
        _itemScrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    return self;
}

#pragma mark -- Getter/Setter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _layout = [[ALWCoverBrowserLayout alloc] init];
        _layout.itemScrollDirection = _itemScrollDirection;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:_layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (void)setItemScrollDirection:(UICollectionViewScrollDirection)itemScrollDirection
{
    _itemScrollDirection = itemScrollDirection;
    
    if (_layout) {
        _layout.itemScrollDirection = _itemScrollDirection;
        
        [self reloadData];
    }
}

- (void)setDisableCircle:(BOOL)disableCircle
{
    _disableCircle = disableCircle;

    [self.collectionView setBounces:!disableCircle];

    if (disableCircle) {
        self.isAutoScrolling = NO;
    }
}

- (void)setIsAutoScrolling:(BOOL)isAutoScrolling
{
    _isAutoScrolling = isAutoScrolling;
    
    if (_autoScrollTimer) {
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }

    if (isAutoScrolling) {
        self.disableCircle = NO;
        
        _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollDuration target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    }
}

- (CGFloat)autoScrollDuration
{
    if (_autoScrollDuration == 0) {
        return 3;
    }
    
    return _autoScrollDuration;
}

- (void)setAutoScrollDuration:(CGFloat)autoScrollDuration
{
    _autoScrollDuration = autoScrollDuration;
    
    if (_isAutoScrolling) {
        self.isAutoScrolling = YES;
    }
}

#pragma mark -- ALWCoverBrowserLayoutDelegate
- (CGSize)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    return config.itemSize;
}

- (CGFloat)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout spacingForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    return config.spacing;
}

- (CGFloat)cb_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout angleForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    return config.transformAngle;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemConfigArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
    
    return [self.delegate alwCoverBrowser:self reuseCollectionViewCell:cell cellForItemAtIndex:config.realIndex];
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _currentCenterIndex = indexPath.row;
    
    if (!_disableCircle) {
        [self adjustContentViewOffset];
    }
    
    if ([self.delegate respondsToSelector:@selector(alwCoverBrowser:didSelectItemAtIndex:)]) {
        ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:indexPath.row];
        
        [self.delegate alwCoverBrowser:self didSelectItemAtIndex:config.realIndex];
    }
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.collectionView.pagingEnabled) {
        [self refreshItemConfiguration:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (!self.collectionView.pagingEnabled) {
        [self adjustContentViewOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.collectionView.pagingEnabled) {
        switch (_itemScrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:{
                _currentCenterIndex = scrollView.contentOffset.x / _itemMaxSize.width;
            }
                break;
            case UICollectionViewScrollDirectionVertical:{
                _currentCenterIndex = scrollView.contentOffset.y / _itemMaxSize.height;
            }
                break;
        }
        
        [self recoverContentViewOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_autoScrollTimer) {
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.collectionView.pagingEnabled) {
        switch (_itemScrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:{
                if (velocity.x > 0) {
                    //向左滑动
                    CGFloat nextFixedItemOffsetX = MAX((_originalCenterIndex + 1) * (_itemMinSize.width + _itemMidMinInset) + _itemMaxSize.width / 2.0 - _collectionView.frame.size.width / 2.0, 0);
                    
                    if (targetContentOffset->x > nextFixedItemOffsetX) {
                        _currentCenterIndex = _originalCenterIndex + 1;
                    }
                }else if (velocity.x < 0){
                    //向右滑动
                    CGFloat nextFixedItemOffsetX = MAX((_originalCenterIndex - 1) * (_itemMinSize.width + _itemMidMinInset) + _itemMaxSize.width / 2.0 - _collectionView.frame.size.width / 2.0, 0);
                    
                    if (targetContentOffset->x < nextFixedItemOffsetX) {
                        _currentCenterIndex = _originalCenterIndex - 1;
                    }
                }
            }
                break;
            case UICollectionViewScrollDirectionVertical:{
                if (velocity.y > 0) {
                    //向上滑动
                    CGFloat nextFixedItemOffsetY = MAX((_originalCenterIndex + 1) * (_itemMinSize.height + _itemMidMinInset) + _itemMaxSize.height / 2.0 - _collectionView.frame.size.height / 2.0, 0);
                    
                    if (targetContentOffset->y > nextFixedItemOffsetY) {
                        _currentCenterIndex = _originalCenterIndex + 1;
                    }
                }else if (velocity.y < 0){
                    //向下滑动
                    CGFloat nextFixedItemOffsetY = MAX((_originalCenterIndex - 1) * (_itemMinSize.height + _itemMidMinInset) + _itemMaxSize.height / 2.0 - _collectionView.frame.size.height / 2.0, 0);
                    
                    if (targetContentOffset->y < nextFixedItemOffsetY) {
                        _currentCenterIndex = _originalCenterIndex - 1;
                    }
                }
            }
                break;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.collectionView.pagingEnabled) {
        if (!decelerate) {
            [self adjustContentViewOffset];
        }
    }
    
    if (_isAutoScrolling) {
        self.isAutoScrolling = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self recoverContentViewOffset];
}

#pragma mark -- Private methods
- (void)refreshItemConfiguration:(UIScrollView *)scrollView
{
    CGFloat visibleCenterX = scrollView.contentOffset.x + scrollView.frame.size.width / 2.0;
    CGFloat visibleCenterY = scrollView.contentOffset.y + scrollView.frame.size.height / 2.0;
    
    //变换动画期间移动的距离
    CGFloat animationDistance = (_itemMaxSize.width + _itemMinSize.width) / 2.0 + _itemMidMinInset;
    
    CGFloat minDistance = 0;
    NSInteger scrollCenterIndex = 0;
    
    NSArray *visibleCellArray = [_collectionView visibleCells];
    
    for (int i = 0; i < visibleCellArray.count; i++) {
        UICollectionViewCell *cell = visibleCellArray[i];
        NSInteger row = [_collectionView indexPathForCell:cell].row;
        ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:row];
        config.spacing = _itemMidMinInset;

        CGFloat distance = 0;
        
        switch (_itemScrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:{
                distance = visibleCenterX - cell.center.x;
            }
                break;
            case UICollectionViewScrollDirectionVertical:{
                distance = visibleCenterY - cell.center.y;
            }
                break;
        }
        
        CGFloat absDistance = fabs(distance);
        
        if (i == 0) {
            minDistance = absDistance;
            scrollCenterIndex = [_collectionView indexPathForCell:cell].row;
        }else{
            if (absDistance < minDistance) {
                minDistance = absDistance;
                scrollCenterIndex = [_collectionView indexPathForCell:cell].row;
            }
        }
        
        if (absDistance > animationDistance) {
            config.itemSize = _itemMinSize;
        } else if (distance == 0) {
            config.itemSize = _itemMaxSize;
            config.transformAngle = 0;
        } else {
            CGFloat rate = 1 - absDistance / animationDistance;
            CGFloat nowWidth = _itemMinSize.width + (_itemMaxSize.width - _itemMinSize.width) * rate;
            CGFloat nowHeight = _itemMinSize.height + (_itemMaxSize.height - _itemMinSize.height) * rate;
            
            config.itemSize = CGSizeMake(nowWidth, nowHeight);

            //y轴翻转角度
            CGFloat angle = _itemTransform3DAngle * (1 - rate);
            
            if (distance > 0) {
                config.transformAngle = -angle;
            } else {
                config.transformAngle = angle;
            }
            
            //间距
            CGFloat nowSpacing = _itemMidMinInset;

            if (rate < 0.5) {
                nowSpacing = _itemMidMinInset + (_itemMidMaxInset - _itemMidMinInset) * rate * 2;
            } else {
                nowSpacing = _itemMidMaxInset - (_itemMidMaxInset - _itemMidMinInset) * (rate - 0.5) * 2;
            }
            
            config.spacing = nowSpacing;
        }
    }
    
    _currentCenterIndex = scrollCenterIndex;
    
    [_layout invalidateLayout];
}

- (void)adjustContentViewOffset
{
    switch (_itemScrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:{
            CGFloat offsetX = MAX(_currentCenterIndex * (_itemMinSize.width + _itemMidMinInset) + _itemMaxSize.width / 2.0 - _collectionView.frame.size.width / 2.0, 0);
            [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
            break;
        case UICollectionViewScrollDirectionVertical:{
            CGFloat offsetY = MAX(_currentCenterIndex * (_itemMinSize.height + _itemMidMinInset) + _itemMaxSize.height / 2.0 - _collectionView.frame.size.height / 2.0, 0);
            [_collectionView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }
            break;
    }
}

- (void)recoverContentViewOffset
{
    if (_disableCircle) {
        if ([self.delegate respondsToSelector:@selector(alwCoverBrowser:didScrollAtIndex:)]) {
            [self.delegate alwCoverBrowser:self didScrollAtIndex:_currentCenterIndex];
        }
        
        return;
    }
    
    //排序显示数据
    if (_currentCenterIndex == _originalCenterIndex) {
        return;
    }
    
    NSInteger offsetIndex = _currentCenterIndex - _originalCenterIndex;
    _currentCenterIndex = _originalCenterIndex;
    
    if (offsetIndex < 0) {
        //将尾部的元素移到前面
        for (int i = 0; i < -offsetIndex; i++) {
            ALWCoverItemConfiguration *config = [_itemConfigArray lastObject];
            [_itemConfigArray removeLastObject];
            [_itemConfigArray insertObject:config atIndex:0];
        }
    } else if (offsetIndex > 0) {
        //将前面的元素移到末尾
        for (int i = 0; i < offsetIndex; i++) {
            ALWCoverItemConfiguration *config = [_itemConfigArray firstObject];
            [_itemConfigArray removeObjectAtIndex:0];
            [_itemConfigArray addObject:config];
        }
    }
    
    for (int i = 0; i < _itemConfigArray.count; i++) {
        ALWCoverItemConfiguration *itemConfig = _itemConfigArray[i];
        itemConfig.spacing = _itemMidMinInset;
        
        if (i == _originalCenterIndex) {
            itemConfig.itemSize = _itemMaxSize;
            itemConfig.transformAngle = 0;
        } else if (i < _originalCenterIndex) {
            itemConfig.itemSize = _itemMinSize;
            itemConfig.transformAngle = -_itemTransform3DAngle;
        } else{
            itemConfig.itemSize = _itemMinSize;
            itemConfig.transformAngle = _itemTransform3DAngle;
        }
    }
    
    [_collectionView reloadData];
    
    switch (_itemScrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:{
            CGFloat offsetX = MAX(_originalCenterIndex * (_itemMinSize.width + _itemMidMinInset) + _itemMaxSize.width / 2.0 - _collectionView.frame.size.width / 2.0, 0);
            
            [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        }
            break;
        case UICollectionViewScrollDirectionVertical:{
            CGFloat offsetY = MAX(_currentCenterIndex * (_itemMinSize.height + _itemMidMinInset) + _itemMaxSize.height / 2.0 - _collectionView.frame.size.height / 2.0, 0);
            
            [_collectionView setContentOffset:CGPointMake(0, offsetY) animated:NO];
        }
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(alwCoverBrowser:didScrollAtIndex:)]) {
        ALWCoverItemConfiguration *config = [_itemConfigArray objectAtIndex:_currentCenterIndex];
        
        [self.delegate alwCoverBrowser:self didScrollAtIndex:config.realIndex];
    }
}

- (void)autoScroll
{
    _currentCenterIndex = _originalCenterIndex + 1;
    
    [self adjustContentViewOffset];
}

#pragma mark -- Public methods
- (void)resetItemFillCoverBrowser
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _itemMaxSize = CGSizeMake(width, height);
    _itemMinSize = _itemMaxSize;
    _itemMidMaxInset = 0;
    _itemMidMinInset = _itemMidMaxInset;
    _itemTransform3DAngle = 0;
    
    [self.collectionView setPagingEnabled:YES];
}

- (void)setupDelegate:(id<ALWCoverBrowserDelegate>)delegate registerUICollectionViewCellClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    self.delegate = delegate;
    _reuseCellIdentifier = identifier;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [self reloadData];
}

- (void)reloadData
{
    _realItemCount = [self.delegate alwCoverBrowserNumberOfItems:self];
    
    NSInteger itemCount = _realItemCount;
    
    if (_disableCircle) {
        _originalCenterIndex = 0;
    }else{
        if (itemCount > 0
            && itemCount < kItemMinCount) {
            for (int i = 2; i <= kItemMinCount; i++) {
                itemCount = _realItemCount * i;
                
                if (itemCount >= kItemMinCount) {
                    break;
                }
            }
        }
        
        _originalCenterIndex = itemCount / 2.0;
    }
    
    _itemConfigArray = [NSMutableArray arrayWithCapacity:itemCount];
    _currentCenterIndex = _originalCenterIndex;
    
    for (int i = 0; i < itemCount; i++) {
        ALWCoverItemConfiguration *itemConfig = [[ALWCoverItemConfiguration alloc] init];
        
        if (i == _originalCenterIndex) {
            itemConfig.itemSize = _itemMaxSize;
            itemConfig.transformAngle = 0;
        } else if (i < _originalCenterIndex) {
            itemConfig.itemSize = _itemMinSize;
            itemConfig.transformAngle = -_itemTransform3DAngle;
        } else{
            itemConfig.itemSize = _itemMinSize;
            itemConfig.transformAngle = _itemTransform3DAngle;
        }
        
        itemConfig.spacing = _itemMidMinInset;
        
        //源数据的真实索引
        NSInteger index = i - _originalCenterIndex;
        
        if (_realItemCount < itemCount) {
            NSInteger offsetFromCenter = labs(index);

            if (index > 0) {
                index = offsetFromCenter % _realItemCount;
            } else if (index < 0) {
                index = offsetFromCenter % _realItemCount;
                
                if (index > 0) {
                    index = _realItemCount - index;
                }
            }
        } else {
            if (index < 0) {
                index += itemCount;
            }
        }
        
        itemConfig.realIndex = index;

        [_itemConfigArray addObject:itemConfig];
    }
    
    if (!_disableCircle) {
        switch (_itemScrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:{
                CGFloat contentCenterX = (_itemMinSize.width + _itemMidMinInset) * _originalCenterIndex + _itemMaxSize.width / 2.0;
                [self.collectionView setContentOffset:CGPointMake(contentCenterX - _collectionView.frame.size.width / 2.0, 0) animated:NO];
            }
                break;
            case UICollectionViewScrollDirectionVertical:{
                CGFloat contentCenterY = (_itemMinSize.height + _itemMidMinInset) * _originalCenterIndex + _itemMaxSize.height / 2.0;
                [self.collectionView setContentOffset:CGPointMake(0, contentCenterY - _collectionView.frame.size.height / 2.0) animated:NO];
            }
                break;
        }
    }
}

@end
