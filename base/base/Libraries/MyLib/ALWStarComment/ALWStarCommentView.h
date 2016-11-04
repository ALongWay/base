//
//  ALWStarCommentView.h
//  base
//
//  Created by 李松 on 16/11/4.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALWStarView.h"

@protocol ALWStarCommentViewDelegate <NSObject>

@optional
- (void)alwStarCommentViewDidSelectedTotalScore:(CGFloat)totalScore;

@end

@interface ALWStarCommentView : UIView

@property (nonatomic, assign) BOOL      enableTap;
@property (nonatomic, assign) CGFloat   totalScore;

@property (nonatomic, weak) id<ALWStarCommentViewDelegate>  delegate;

+ (ALWStarCommentView *)getDefaultStarCommentView;

@end
