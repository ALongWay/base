//
//  TestScratchCardViewController.m
//  base
//
//  Created by 李松 on 2016/11/7.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestScratchCardViewController.h"

@interface TestScratchCardViewController ()

@end

@implementation TestScratchCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"测试刮刮卡";
    
    [self buildUI];
}

- (void)buildUI
{
    UILabel *contentView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    [contentView setBackgroundColor:COLOR(240, 240, 240)];
    [contentView setText:@"恭喜中一等奖"];
    [contentView setTextColor:[UIColor redColor]];
    [contentView setTextAlignment:NSTextAlignmentCenter];
    [contentView setFont:FONTAppliedBoldBase6(35)];
    
    UIImage *snapshot = [ImageHelper getSnapshotWithView:contentView];
    UIImage *coverImage = [ImageHelper getBlurEffectImageWithOriginalImage:snapshot style:ImageHelperBlurEffectStyleDark];
    UIImageView *coverView = [[UIImageView alloc] initWithImage:coverImage];
    
    ALWScratchCardView *card = [[ALWScratchCardView alloc] initWithContentView:contentView coverView:coverView];
    card.center = CGPointMake(self.view.center.x, card.height);
    [self.view addSubview:card];
    
    ALWScratchCardView *scratchCard = [[ALWScratchCardView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    scratchCard.center = self.view.center;
    [self.view addSubview:scratchCard];
}

@end
