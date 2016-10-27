//
//  ALWCollectionViewFlowLayout.m
//  base
//
//  Created by 李松 on 16/10/25.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionViewFlowLayout.h"

#pragma mark - ALWCollectionViewLayoutAttributes
@interface ALWCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

/**
 *  默认透明
 */
@property (nonatomic, strong) UIColor       *backgroundColor;

@end

@implementation ALWCollectionViewLayoutAttributes
@synthesize backgroundColor = _backgroundColor;

- (UIColor *)backgroundColor
{
    if (_backgroundColor) {
        return _backgroundColor;
    }else{
        return [UIColor clearColor];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
}

@end

#pragma mark - ALWCollectionReusableView
@interface ALWCollectionReusableView : UICollectionReusableView

@end

@implementation ALWCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if ([layoutAttributes isMemberOfClass:[ALWCollectionViewLayoutAttributes class]]) {
        self.backgroundColor = ((ALWCollectionViewLayoutAttributes *)layoutAttributes).backgroundColor;
    }
}

@end

#pragma mark - ALWCollectionViewFlowLayout
#define kALWSectionBackgroundColor      @"ALWSectionBackgroundColor"

@interface ALWCollectionViewFlowLayout ()

@property (nonatomic, assign) ALWCollectionViewFlowLayoutType                       flowLayoutType;

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*, UICollectionViewLayoutAttributes*>  *itemAttributesDic;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*, UICollectionViewLayoutAttributes*>  *supplementaryViewAttributesDic;
@property (nonatomic, strong) NSMutableArray<ALWCollectionViewLayoutAttributes*>    *decorationViewAttributesArray;

@property (nonatomic, assign) CGSize    contentSize;

@end

@implementation ALWCollectionViewFlowLayout

- (instancetype)initWithALWCollectionViewFlowLayoutType:(ALWCollectionViewFlowLayoutType)type
{
    _flowLayoutType = type;
    
    return [self init];
}

#pragma mark - 重载父类方法
- (instancetype)init
{
    self = [super init];
    
    //注册section的装饰view
    [self registerClass:[ALWCollectionReusableView class] forDecorationViewOfKind:kALWSectionBackgroundColor];
    
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    switch (_flowLayoutType) {
        case ALWCollectionViewFlowLayoutTypeOrder: {
            [self getLayoutAttributesForFlowLayoutTypeOrder];
            break;
        }
        case ALWCollectionViewFlowLayoutTypeFill: {
            [self getLayoutAttributesForFlowLayoutTypeFill];
            break;
        }
        default:
            break;
    }
    
    [self getAllDecorationViewAttributes];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //将装饰view的布局属性应用到相关区域
    NSMutableArray *attributesArray = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
//    for (UICollectionViewLayoutAttributes *attributes in self.decorationViewAttributesArray) {
//        if (CGRectIntersectsRect(attributes.frame, rect)) {
//            [attributesArray addObject:attributes];
//        }
//    }
    
    [self.itemAttributesDic enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [attributesArray addObject:attributes];
        }
    }];

    
    [self.supplementaryViewAttributesDic enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [attributesArray addObject:attributes];
        }
    }];
    
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
    switch (_flowLayoutType) {
        case ALWCollectionViewFlowLayoutTypeOrder:
        case ALWCollectionViewFlowLayoutTypeFill: {
            return _contentSize;
            break;
        }
        default:
            break;
    }
    
    return [super collectionViewContentSize];
}

#pragma mark - Private methods
- (void)getLayoutAttributesForFlowLayoutTypeOrder
{
    _itemAttributesDic = [NSMutableDictionary dictionary];
    _supplementaryViewAttributesDic = [NSMutableDictionary dictionary];
    CGFloat contentLength = 0;
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        
        //header
        NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:supplementaryViewIndexPath];
        
        CGRect headerFrame = headerAttributes.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            headerFrame.origin.y = contentLength;
            contentLength += headerAttributes.size.height;
        } else {
            headerFrame.origin.x = contentLength;
            contentLength += headerAttributes.size.width;
        }
        
        headerAttributes.frame = headerFrame;
        _supplementaryViewAttributesDic[supplementaryViewIndexPath] = headerAttributes;

        //variables
        BOOL isOverCalculateItemCountPerLine = NO;
        NSInteger itemCountPerLine = 0;
        NSMutableArray *usedLengthArray = [NSMutableArray array];//记录section中各列/行当前使用的内容长度
        
        CGFloat itemVerticalMidInset = 0;
        CGFloat itemHorizontalMidInset = 0;
        UIEdgeInsets sectionInset = self.sectionInset;
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            contentLength += sectionInset.top;
        } else {
            contentLength += sectionInset.left;
        }
        
        CGRect firstItemFrame = CGRectZero;
        
        //items
        for (NSInteger item = 0; item < numberOfItems; item++) {
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:currentIndexPath];
            
            if (item == 0) {
                firstItemFrame = itemAttributes.frame;
                
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    CGRect showFrame = itemAttributes.frame;
                    showFrame.origin.y = contentLength;
                    itemAttributes.frame = showFrame;
                    _itemAttributesDic[currentIndexPath] = itemAttributes;
                    
                    usedLengthArray[item] = @(itemAttributes.size.height);
                } else {
                    CGRect showFrame = itemAttributes.frame;
                    showFrame.origin.x = contentLength;
                    itemAttributes.frame = showFrame;
                    _itemAttributesDic[currentIndexPath] = itemAttributes;
                    
                    usedLengthArray[item] = @(itemAttributes.size.width);
                }
                
                continue;
            }
            
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    if (!isOverCalculateItemCountPerLine) {
                        //得到每行的item数量，根据第一列左边距判断
                        if (itemAttributes.frame.origin.x != firstItemFrame.origin.x) {
                            itemCountPerLine++;
                            
                            if (item == 1) {
                                itemHorizontalMidInset = CGRectGetMinX(itemAttributes.frame) - CGRectGetMaxX(firstItemFrame);
                            }
                            
                            CGRect showFrame = itemAttributes.frame;
                            showFrame.origin.y = contentLength;
                            itemAttributes.frame = showFrame;
                            _itemAttributesDic[currentIndexPath] = itemAttributes;
                            
                            usedLengthArray[item] = @(itemAttributes.size.height);
                        } else {
                            //说明刚好换行
                            isOverCalculateItemCountPerLine = YES;
                            itemVerticalMidInset = CGRectGetMinY(itemAttributes.frame) - CGRectGetMaxY(firstItemFrame);
                        }
                    }
                    
                    if (!isOverCalculateItemCountPerLine) {
                        continue;
                    }
                    
                    //开始处理item实际显示的位置
                    NSInteger index = item % itemCountPerLine;
                    CGFloat oldLength = [usedLengthArray[index] floatValue];
                    CGFloat originY = oldLength + itemVerticalMidInset;
                    
                    CGRect showFrame = itemAttributes.frame;
                    showFrame.origin.y = contentLength + originY;
                    itemAttributes.frame = showFrame;
                    _itemAttributesDic[currentIndexPath] = itemAttributes;
                    
                    usedLengthArray[index] = @(originY + itemAttributes.size.height);
                    
                    break;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    if (!isOverCalculateItemCountPerLine) {
                        //得到每列的item数量，根据第一行上边距判断
                        if (itemAttributes.frame.origin.y != firstItemFrame.origin.y) {
                            itemCountPerLine++;
                            
                            if (item == 1) {
                                itemVerticalMidInset = CGRectGetMinY(itemAttributes.frame) - CGRectGetMaxY(firstItemFrame);

                            }
                            
                            CGRect showFrame = itemAttributes.frame;
                            showFrame.origin.x = contentLength;
                            itemAttributes.frame = showFrame;
                            _itemAttributesDic[currentIndexPath] = itemAttributes;
                            
                            usedLengthArray[item] = @(itemAttributes.size.width);
                        } else {
                            //说明刚好换列
                            isOverCalculateItemCountPerLine = YES;
                            itemHorizontalMidInset = CGRectGetMinX(itemAttributes.frame) - CGRectGetMaxX(firstItemFrame);
                        }
                    }
                    
                    if (!isOverCalculateItemCountPerLine) {
                        continue;
                    }
                    
                    //开始处理item实际显示的位置
                    NSInteger index = item % itemCountPerLine;
                    CGFloat oldLength = [usedLengthArray[index] floatValue];
                    CGFloat originX = oldLength + itemHorizontalMidInset;
                    
                    CGRect showFrame = itemAttributes.frame;
                    showFrame.origin.x = contentLength + originX;
                    itemAttributes.frame = showFrame;
                    _itemAttributesDic[currentIndexPath] = itemAttributes;
                    
                    usedLengthArray[index] = @(originX + itemAttributes.size.width);

                    break;
                }
            }
        }
        
        //计算contentLength
        CGFloat maxUsedLength = 0;
        for (int i = 0; i < usedLengthArray.count; i++) {
            CGFloat usedLength = [usedLengthArray[i] floatValue];
            if (usedLength > maxUsedLength) {
                maxUsedLength = usedLength;
            }
        }
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            contentLength += sectionInset.bottom + maxUsedLength;
        } else {
            contentLength += sectionInset.right + maxUsedLength;
        }
        
        //footer
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:supplementaryViewIndexPath];
        
        CGRect footerFrame = footerAttributes.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            footerFrame.origin.y = contentLength;
            contentLength += footerAttributes.size.height;
        } else {
            footerFrame.origin.x = contentLength;
            contentLength += footerAttributes.size.width;
        }
        
        footerAttributes.frame = footerFrame;
        _supplementaryViewAttributesDic[supplementaryViewIndexPath] = footerAttributes;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        _contentSize = CGSizeMake(self.collectionView.frame.size.width, contentLength);
    } else {
        _contentSize = CGSizeMake(contentLength, self.collectionView.frame.size.height);
    }
}

- (void)getLayoutAttributesForFlowLayoutTypeFill
{

}

- (void)getAllDecorationViewAttributes
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
        UICollectionViewLayoutAttributes *firstItemAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        UICollectionViewLayoutAttributes *lastItemAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:numberOfItems - 1 inSection:i]];
        
        UIEdgeInsets sectionInset = self.sectionInset;
        
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:i];
        }
        
        CGRect sectionFrame = CGRectUnion(firstItemAttributes.frame, lastItemAttributes.frame);
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
    if ([layoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
        layoutAttributes.hidden = YES;
    }
}

@end
