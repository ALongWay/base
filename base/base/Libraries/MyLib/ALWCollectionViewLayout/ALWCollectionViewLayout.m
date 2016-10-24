//
//  ALWCollectionViewLayout.m
//  base
//
//  Created by 李松 on 16/10/24.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionViewLayout.h"

#pragma mark - ALWCollectionViewLayoutAttributes
@interface ALWCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

/**
 *  默认为白色
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
        return [UIColor whiteColor];
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

@property (nonatomic, strong) NSMutableArray<ALWCollectionViewLayoutAttributes*>    *decorationViewAttributesArray;

@end

@implementation ALWCollectionViewFlowLayout

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
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    if (numberOfSections == 0 || self.collectionView.delegate == nil || ![self.collectionView.delegate conformsToProtocol:@protocol(ALWCollectionViewDelegateFlowLayout)]) {
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

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //将装饰view的布局属性应用到相关区域
    NSMutableArray *attributesArray = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    for (UICollectionViewLayoutAttributes *attributes in self.decorationViewAttributesArray) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesArray addObject:attributes];
        }
    }
    
    return attributesArray;
}

@end

#pragma mark - ALWCollectionViewLayout
@implementation ALWCollectionViewLayout

@end
