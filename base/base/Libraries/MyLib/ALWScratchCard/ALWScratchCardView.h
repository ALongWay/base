//
//  ALWScratchCardView.h
//  base
//
//  Created by 李松 on 2016/11/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALWScratchCardView : UIView

/**
 刮痕的宽度，默认20
 */
@property (nonatomic, assign) CGFloat   lineWidth;

- (nonnull instancetype)initWithContentView:(nonnull UIView *)contentView coverView:(nonnull UIView *)coverView;

@end
