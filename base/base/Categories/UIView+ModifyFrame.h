//
//  UIView+ModifyFrame.h
//  base
//
//  Created by 李松 on 16/9/13.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ModifyFrame)

@property (nonatomic, assign) CGFloat originX;

@property (nonatomic, assign) CGFloat originY;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGSize  size;

@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign, readonly) CGFloat maxX;

@property (nonatomic, assign, readonly) CGFloat maxY;

@end
