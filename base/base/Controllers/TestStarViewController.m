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
    ALWStarView *star = [[ALWStarView alloc] initWithRadius:100];
    star.center = CGPointMake(DeviceWidth / 2.0, DeviceHeight / 2.0);
    [self.view addSubview:star];
}

@end
