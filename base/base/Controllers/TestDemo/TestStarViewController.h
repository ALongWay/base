//
//  TestStarViewController.h
//  base
//
//  Created by 李松 on 16/11/3.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^DidSelectedTotalScoreBlock)(CGFloat totalScore);

@interface TestStarViewController : BaseViewController

- (void)setDidSelectedTotalScoreBlock:(DidSelectedTotalScoreBlock)didSelectedTotalScoreBlock;

@end
