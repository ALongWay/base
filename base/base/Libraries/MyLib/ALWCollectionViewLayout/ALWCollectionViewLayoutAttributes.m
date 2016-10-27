//
//  ALWCollectionViewLayoutAttributes.m
//  base
//
//  Created by lisong on 16/10/27.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWCollectionViewLayoutAttributes.h"

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
