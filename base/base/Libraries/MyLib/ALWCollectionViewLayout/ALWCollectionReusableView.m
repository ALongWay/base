//
//  ALWCollectionReusableView.m
//  base
//
//  Created by lisong on 16/10/27.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionReusableView.h"

@implementation ALWCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if ([layoutAttributes isMemberOfClass:[ALWCollectionViewLayoutAttributes class]]) {
        self.backgroundColor = ((ALWCollectionViewLayoutAttributes *)layoutAttributes).backgroundColor;
    }
}

@end
