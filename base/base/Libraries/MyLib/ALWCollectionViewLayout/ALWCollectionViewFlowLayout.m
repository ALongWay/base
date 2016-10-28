//
//  ALWCollectionViewFlowLayout.m
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionViewFlowLayout.h"
#import "ALWCollectionReusableView.h"

@interface ALWCollectionViewFlowLayout ()<UIGestureRecognizerDelegate>

#pragma mark -- 自定义布局相关的属性
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*>     *itemAttributesArray;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*>     *supplementaryViewAttributesArray;
@property (nonatomic, strong) NSMutableArray<ALWCollectionViewLayoutAttributes*>    *decorationViewAttributesArray;
@property (nonatomic, strong) NSMutableArray                                        *sectionFrameArray;

@property (nonatomic, assign) BOOL                                                  enableCustomFlowLayout;
@property (nonatomic, assign) ALWCollectionViewFlowLayoutType                       flowLayoutType;

@property (nonatomic, assign) NSInteger         countPerLine;
@property (nonatomic, assign) CGFloat           fixedSide;
@property (nonatomic, assign) CGSize            newContentSize;

@end

@implementation ALWCollectionViewFlowLayout

- (instancetype)initWithCountPerLine:(NSUInteger)count itemFixedSide:(CGFloat)fixedSide flowLayoutType:(ALWCollectionViewFlowLayoutType)type
{
    self = [self init];
    if (self) {
        _enableCustomFlowLayout = YES;
        _flowLayoutType = type;
        _countPerLine = count;
        _fixedSide = fixedSide;
        _newContentSize = CGSizeZero;
    }
    
    return self;
}

#pragma mark - Life circle
- (instancetype)init
{
    self = [super init];
    
    //注册section的装饰view
    [self registerClass:[ALWCollectionReusableView class] forDecorationViewOfKind:kALWSectionBackgroundColor];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    //注册section的装饰view
    [self registerClass:[ALWCollectionReusableView class] forDecorationViewOfKind:kALWSectionBackgroundColor];
    
    return self;
}

#pragma mark - 重载父类方法
- (void)prepareLayout
{
    [super prepareLayout];
    
    if (_enableCustomFlowLayout) {
        switch (_flowLayoutType) {
            case ALWCollectionViewFlowLayoutTypeOrder: {
                [self getItemLayoutAttributesForFlowLayoutTypeOrder];
                break;
            }
            case ALWCollectionViewFlowLayoutTypeFill: {
                [self getItemLayoutAttributesForFlowLayoutTypeFill];
                break;
            }
        }
    }
    
    [self getDecorationViewAttributesForSectionBgColor];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributesArray;
    
    if (_enableCustomFlowLayout) {
        attributesArray = [NSMutableArray array];
        
        for (UICollectionViewLayoutAttributes *attributes in _itemAttributesArray) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }

        }

        for (UICollectionViewLayoutAttributes *attributes in _supplementaryViewAttributesArray) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }        
    } else {
        attributesArray = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    }
    
    //将装饰view的布局属性应用到相关区域
    for (UICollectionViewLayoutAttributes *attributes in _decorationViewAttributesArray) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesArray addObject:attributes];
        }
    }
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        switch (attributes.representedElementCategory) {
            case UICollectionElementCategoryCell: {
                [self resetCellWithLayoutAttributes:attributes];
            }
                break;
            default:
                break;
        }
    }
    
    return attributesArray;
}

- (CGSize)collectionViewContentSize
{
    if (_enableCustomFlowLayout) {
        return _newContentSize;
    }else{
        return [super collectionViewContentSize];
    }
}

#pragma mark - 自定义布局相关方法
- (void)getItemLayoutAttributesForFlowLayoutTypeOrder
{
    LOG(@"getItemLayoutAttributesForFlowLayoutTypeOrder");
    
    _itemAttributesArray = [NSMutableArray array];
    _supplementaryViewAttributesArray = [NSMutableArray array];
    _sectionFrameArray = [NSMutableArray array];
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    CGFloat currentContentLength = 0;
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:sectionIndex];
        
        //记录每一排item在当前section占用的内容长度
        NSMutableArray *lineUsedLengthArray = [NSMutableArray arrayWithCapacity:_countPerLine];
        CGRect currentSectionFrame = CGRectZero;
        CGFloat currentSectionLength = 0;
        CGFloat itemHorizontalMidInset = 0;
        CGFloat itemVerticalMidInset = 0;

        //header
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
        UICollectionViewLayoutAttributes *headerAttributes = [[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:supplementaryViewIndexPath] copy];
        
        CGRect headerFrame = headerAttributes.frame;
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                headerFrame.origin.y = currentContentLength;
                currentContentLength += headerFrame.size.height;
                currentSectionFrame.origin = CGPointMake(0, currentContentLength);
                itemVerticalMidInset = self.minimumInteritemSpacing;
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                headerFrame.origin.x = currentContentLength;
                currentContentLength += headerFrame.size.width;
                currentSectionFrame.origin = CGPointMake(currentContentLength, 0);
                itemHorizontalMidInset = self.minimumLineSpacing;
                break;
            }
        }
        
        headerAttributes.frame = headerFrame;
        if (headerAttributes) {
            [_supplementaryViewAttributesArray addObject:headerAttributes];
        }
        
        //section inset
        UIEdgeInsets sectionInset = self.sectionInset;
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:sectionIndex];
        }
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                currentSectionLength = sectionInset.top;
                
                if (_countPerLine > 1) {
                    itemHorizontalMidInset = (self.collectionView.frame.size.width - sectionInset.left - sectionInset.right - _countPerLine * _fixedSide) / (_countPerLine - 1);
                }
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                currentSectionLength = sectionInset.left;
                
                if (_countPerLine > 1) {
                    itemVerticalMidInset = (self.collectionView.frame.size.height - sectionInset.top - sectionInset.bottom - _countPerLine * _fixedSide) / (_countPerLine - 1);
                }
                break;
            }
        }
        
        for (int i = 0; i < _countPerLine; i++) {
            lineUsedLengthArray[i] = @(currentContentLength + currentSectionLength);
        }
        
        //section items
        for (NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex++) {
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            
            UICollectionViewLayoutAttributes *itemAttributes = [[self layoutAttributesForItemAtIndexPath:currentIndexPath] copy];
            
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    CGFloat itemHeight = _fixedSide;
                    
                    if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                        itemHeight = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:currentIndexPath].height;
                    }
                    
                    NSInteger locationIndex = itemIndex % _countPerLine;
                    
                    CGFloat oldLength = [lineUsedLengthArray[locationIndex] floatValue];
                    
                    CGFloat originX = sectionInset.left + locationIndex * (_fixedSide + itemHorizontalMidInset);
                    CGFloat originY = oldLength;
                    
                    itemAttributes.frame = CGRectMake(originX, originY, _fixedSide, itemHeight);
                    
                    CGFloat newLength = oldLength + itemHeight + itemVerticalMidInset;
                    lineUsedLengthArray[locationIndex] = @(newLength);
                    
                    if (itemAttributes) {
                        [_itemAttributesArray addObject:itemAttributes];
                    }

                    break;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    CGFloat itemWidth = _fixedSide;
                    
                    if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                        itemWidth = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:currentIndexPath].width;
                    }
                    
                    NSInteger locationIndex = itemIndex % _countPerLine;
                    
                    CGFloat oldLength = [lineUsedLengthArray[locationIndex] floatValue];
                    
                    CGFloat originY = sectionInset.top + locationIndex * (_fixedSide + itemVerticalMidInset);
                    CGFloat originX = oldLength;
                    
                    itemAttributes.frame = CGRectMake(originX, originY, itemWidth, _fixedSide);
                    
                    CGFloat newLength = oldLength + itemWidth + itemHorizontalMidInset;
                    lineUsedLengthArray[locationIndex] = @(newLength);
                    
                    if (itemAttributes) {
                        [_itemAttributesArray addObject:itemAttributes];
                    }

                    break;
                }
            }
        }
        
        //修正currentContentLength,currentSectionLength,currentSectionFrame
        CGFloat maxUsedLength = 0;//指当前所有内容的最大长度
        for (int i = 0; i < lineUsedLengthArray.count; i++) {
            CGFloat usedLength = [lineUsedLengthArray[i] floatValue];
            if (usedLength > maxUsedLength) {
                maxUsedLength = usedLength;
            }
        }
        
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                maxUsedLength -= itemVerticalMidInset;
                currentSectionLength = maxUsedLength + sectionInset.bottom - currentContentLength;
                currentContentLength += currentSectionLength;
                currentSectionFrame.size = CGSizeMake(self.collectionView.frame.size.width, currentSectionLength);
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                maxUsedLength -= itemHorizontalMidInset;
                currentSectionLength = maxUsedLength + sectionInset.right - currentContentLength;
                currentContentLength += currentSectionLength;
                currentSectionFrame.size = CGSizeMake(currentSectionLength, self.collectionView.frame.size.height);
                break;
            }
        }
        
        //记录currentSectionFrame
        [_sectionFrameArray addObject:[NSValue valueWithCGRect:currentSectionFrame]];
        
        //footer
        UICollectionViewLayoutAttributes *footerAttributes = [[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:supplementaryViewIndexPath] copy];
        
        CGRect footerFrame = footerAttributes.frame;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            footerFrame.origin.y = currentContentLength;
            currentContentLength += footerFrame.size.height;
        } else {
            footerFrame.origin.x = currentContentLength;
            currentContentLength += footerFrame.size.width;
        }
        
        footerAttributes.frame = footerFrame;
        if (footerAttributes) {
            [_supplementaryViewAttributesArray addObject:footerAttributes];
        }
    }
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
            _newContentSize = CGSizeMake(self.collectionView.frame.size.width, currentContentLength);
            break;
        }
        case UICollectionViewScrollDirectionHorizontal: {
            _newContentSize = CGSizeMake(currentContentLength, self.collectionView.frame.size.height);
            break;
        }
    }
}

- (void)getItemLayoutAttributesForFlowLayoutTypeFill
{
    
}

- (void)getDecorationViewAttributesForSectionBgColor
{
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    if (numberOfSections == 0 || self.collectionView.delegate == nil) {
        return;
    }
    
    id<ALWCollectionViewDelegateFlowLayout> delegate = (id<ALWCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    
    self.decorationViewAttributesArray = [NSMutableArray array];
    
    for (int i = 0; i < numberOfSections; i++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:i];
        if (numberOfItems == 0) {
            continue;
        }
        
        //计算section的区域frame
        CGRect sectionFrame;
        
        if (_enableCustomFlowLayout) {
            if (i < _sectionFrameArray.count) {
                sectionFrame = [_sectionFrameArray[i] CGRectValue];
            }
        } else {
            UICollectionViewLayoutAttributes *firstItemAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            UICollectionViewLayoutAttributes *lastItemAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:numberOfItems - 1 inSection:i]];
            
            UIEdgeInsets sectionInset = self.sectionInset;
            
            if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:i];
            }
            
            sectionFrame = CGRectUnion(firstItemAttributes.frame, lastItemAttributes.frame);
            sectionFrame.origin.x -= sectionInset.left;
            sectionFrame.origin.y -= sectionInset.top;
            
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionVertical:{
                    sectionFrame.size.width = self.collectionView.frame.size.width;
                    sectionFrame.size.height += sectionInset.top + sectionInset.bottom;
                    break;
                }
                case UICollectionViewScrollDirectionHorizontal:{
                    sectionFrame.size.width += sectionInset.left + sectionInset.right;
                    sectionFrame.size.height = self.collectionView.frame.size.height;
                    break;
                }
            }
        }
        
        //得到装饰view的布局属性对象，修改后保留
        ALWCollectionViewLayoutAttributes *attributes = [ALWCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kALWSectionBackgroundColor withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        
        attributes.frame = sectionFrame;
        attributes.zIndex = -1;//防止挡住cell
        
        //实现的背景色代理方法
        if ([delegate respondsToSelector:@selector(collectionView:layout:backgroundColorForSectionAtIndex:)]) {
            attributes.backgroundColor = [delegate collectionView:self.collectionView layout:self backgroundColorForSectionAtIndex:i];
        }
        
        [self.decorationViewAttributesArray addObject:attributes];
    }
}

- (void)resetCellWithLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    //隐藏被选中拖拽的原item
    if (self.enableCustomDragGesture
        && [layoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
        layoutAttributes.hidden = YES;
    }
}

@end
