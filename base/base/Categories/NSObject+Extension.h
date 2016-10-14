//
//  NSObject+Extension.h
//  base
//
//  Created by 李松 on 16/10/14.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

/**
 *  交换方法
 *
 *  @param originalSelector 原方法
 *  @param newSelector      新方法
 */
+(void)swizzleOriginalSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;

@end
