//
//  ALWCollectionViewLayout.m
//  base
//
//  Created by 李松 on 16/10/26.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionViewLayout.h"
#import "ALWCollectionReusableView.h"

@interface ALWCollectionViewLayout ()

@property (nonatomic, assign, readwrite) ALWCollectionViewScrollDirection   scrollDirection;

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*>     *itemAttributesArray;
@property (nonatomic, strong) NSMutableArray<ALWCollectionViewLayoutAttributes*>    *decorationViewAttributesArray;

@property (nonatomic, assign) NSInteger     lineCount;//列或者行数量
@property (nonatomic, assign) CGFloat       fixedSide;//固定的边长

@property (nonatomic, assign) CGSize        contentSize;

@end

@implementation ALWCollectionViewLayout

- (instancetype)initWithColumnCount:(NSInteger)count itemWidth:(CGFloat)width
{
    _lineCount = count;
    _fixedSide = width;
    
    return [self init];
}

- (instancetype)initWithRowCount:(NSInteger)count itemHeight:(CGFloat)height
{
    _lineCount = count;
    _fixedSide = height;
    
    return [self init];
}

#pragma mark - 重载父类方法
- (instancetype)init
{
    self = [super init];
    
    _scrollDirection = ALWCollectionViewScrollDirectionVertical;
    _layoutType = ALWCollectionViewFlowLayoutTypeOrder;
    
    _itemHorizontalSpacing = 10;
    _itemVerticalSpacing = 10;
    
    //注册section的装饰view
    [self registerClass:[ALWCollectionReusableView class] forDecorationViewOfKind:kALWSectionBackgroundColor];
    
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    switch (_layoutType) {
        case ALWCollectionViewFlowLayoutTypeOrder: {
            [self getLayoutAttributesForLayoutTypeOrder];
            break;
        }
        case ALWCollectionViewFlowLayoutTypeFill: {
            [self getLayoutAttributesForLayoutTypeFill];
            break;
        }
        default:
            break;
    }
    
    [self getAllDecorationViewAttributes];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributesArray = [NSMutableArray array];
    
    [self.itemAttributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [attributesArray addObject:attributes];
        }
    }];
    
    //将装饰view的布局属性应用到相关区域
    [self.decorationViewAttributesArray enumerateObjectsUsingBlock:^(ALWCollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesArray addObject:attributes];
        }
    }];
    
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
    return _contentSize;
}

#pragma mark - Private methods
- (void)getLayoutAttributesForLayoutTypeOrder
{
    _itemAttributesArray = [NSMutableArray array];
    CGFloat contentLength = 0;
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        
        NSMutableArray *usedLengthArray = [NSMutableArray arrayWithCapacity:_lineCount];//记录section中各列/行当前使用的内容长度

        UIEdgeInsets sectionInset = UIEdgeInsetsZero;
        
        id<ALWCollectionViewDelegateLayout> delegate = (id<ALWCollectionViewDelegateLayout>)self.collectionView.delegate;
        if ([delegate respondsToSelector:@selector(alw_collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [delegate alw_collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        switch (self.scrollDirection) {
            case ALWCollectionViewScrollDirectionVertical:{
                for (int i = 0; i < _lineCount; i++) {
                    usedLengthArray[i] = @(sectionInset.top);
                }
                
                if (_lineCount > 1) {
                    _itemHorizontalSpacing = (self.collectionView.frame.size.width - sectionInset.left - sectionInset.right - _lineCount * _fixedSide) / (_lineCount - 1);
                }
            }
                break;
            case ALWCollectionViewScrollDirectionHorizontal:{
                for (int i = 0; i < _lineCount; i++) {
                    usedLengthArray[i] = @(sectionInset.left);
                }
                
                if (_lineCount > 1) {
                    _itemVerticalSpacing = (self.collectionView.frame.size.height - sectionInset.top - sectionInset.bottom - _lineCount * _fixedSide) / (_lineCount - 1);
                }
            }
                break;
        }
        
        for (NSInteger item = 0; item < numberOfItems; item++) {
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:currentIndexPath];
            
            switch (self.scrollDirection) {
                case ALWCollectionViewScrollDirectionVertical:{
                    CGFloat itemHeight = _fixedSide;
                    
                    if ([delegate respondsToSelector:@selector(alw_collectionView:layout:heightForItemAtIndexPath:)]) {
                        itemHeight = [delegate alw_collectionView:self.collectionView layout:self heightForItemAtIndexPath:currentIndexPath];
                    }
                    
                    NSInteger locationIndex = item % _lineCount;
                    
                    CGFloat oldLength = [usedLengthArray[locationIndex] floatValue];
                    
                    CGFloat originX = sectionInset.left + locationIndex * (_fixedSide + _itemHorizontalSpacing);
                    CGFloat originY = oldLength;
                    
                    itemAttributes.frame = CGRectMake(originX, originY, _fixedSide, itemHeight);
                    
                    CGFloat newLength = oldLength + itemHeight + _itemVerticalSpacing;
                    usedLengthArray[locationIndex] = @(newLength);
                }
                    break;
                case ALWCollectionViewScrollDirectionHorizontal:{
                    CGFloat itemWidth = _fixedSide;
                    
                    if ([delegate respondsToSelector:@selector(alw_collectionView:layout:widthForItemAtIndexPath:)]) {
                        itemWidth = [delegate alw_collectionView:self.collectionView layout:self widthForItemAtIndexPath:currentIndexPath];
                    }
                    
                    NSInteger locationIndex = item % _lineCount;
                    
                    CGFloat oldLength = [usedLengthArray[locationIndex] floatValue];
                    
                    CGFloat originX = oldLength;
                    CGFloat originY = sectionInset.top + locationIndex * (_fixedSide + _itemVerticalSpacing);
                    
                    itemAttributes.frame = CGRectMake(originX, originY, itemWidth, _fixedSide);
                    
                    CGFloat newLength = oldLength + itemWidth + _itemHorizontalSpacing;
                    usedLengthArray[locationIndex] = @(newLength);
                }
                    break;
            }
            
            [_itemAttributesArray addObject:itemAttributes];
        }
        
        //计算contentLength
        CGFloat maxUsedLength = 0;
        for (int i = 0; i < usedLengthArray.count; i++) {
            CGFloat usedLength = [usedLengthArray[i] floatValue];
            if (usedLength > maxUsedLength) {
                maxUsedLength = usedLength;
            }
        }
        
        switch (self.scrollDirection) {
            case ALWCollectionViewScrollDirectionVertical:{
                contentLength = sectionInset.bottom + maxUsedLength - _itemVerticalSpacing;
            }
                break;
            case ALWCollectionViewScrollDirectionHorizontal:{
                contentLength = sectionInset.right + maxUsedLength - _itemHorizontalSpacing;
            }
                break;
        }
    }
    
    switch (self.scrollDirection) {
        case ALWCollectionViewScrollDirectionVertical:{
            _contentSize = CGSizeMake(self.collectionView.frame.size.width, contentLength);
        }
            break;
        case ALWCollectionViewScrollDirectionHorizontal:{
            _contentSize = CGSizeMake(contentLength, self.collectionView.frame.size.height);
        }
            break;
    }
}

- (void)getLayoutAttributesForLayoutTypeFill
{
    
}

- (void)getAllDecorationViewAttributes
{
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    if (numberOfSections == 0 || self.collectionView.delegate == nil) {
        return;
    }
    
    id<ALWCollectionViewDelegateLayout> delegate = (id<ALWCollectionViewDelegateLayout>)self.collectionView.delegate;
    
    self.decorationViewAttributesArray = [NSMutableArray array];
    
    for (int i = 0; i < numberOfSections; i++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:i];
        if (numberOfItems == 0) {
            continue;
        }
        
        //得到装饰view的布局属性对象，修改后保留
        ALWCollectionViewLayoutAttributes *attributes = [ALWCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kALWSectionBackgroundColor withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        
        attributes.frame = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
        attributes.zIndex = -1;//防止挡住cell
        
        //实现的背景色代理方法
        if ([delegate respondsToSelector:@selector(collectionView:layout:backgroundColorForSectionAtIndex:)]) {
            attributes.backgroundColor = [delegate alw_collectionView:self.collectionView layout:self backgroundColorForSectionAtIndex:i];
        }
        
        [self.decorationViewAttributesArray addObject:attributes];
    }
}

- (void)resetCellWithLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    //隐藏被选中拖拽的原item
    if ([layoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
        layoutAttributes.hidden = YES;
    }
}

@end
