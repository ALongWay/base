//
//  TestStarViewController.m
//  base
//
//  Created by 李松 on 16/11/3.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestStarViewController.h"

@implementation TestStarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"测试StarComment";
    
    [self buildUI];
}

- (void)buildUI
{
    ALWStarCommentView *starCommentView = [ALWStarCommentView getDefaultStarCommentView];
    starCommentView.center = CGPointMake(DeviceWidth / 2.0, starCommentView.frame.size.height * 3);
    starCommentView.enableTap = YES;
    starCommentView.totalScore = 3.2;
    [self.view addSubview:starCommentView];
    
    ALWStarView *star = [[ALWStarView alloc] initWithRadius:100 topPointCount:6];
    star.center = CGPointMake(DeviceWidth / 2.0, DeviceHeight / 2.0);
    star.enableTap = YES;
    [self.view addSubview:star];
}

@end
