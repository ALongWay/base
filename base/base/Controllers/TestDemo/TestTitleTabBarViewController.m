//
//  TestTitleTabBarViewController.m
//  base
//
//  Created by 李松 on 2017/1/23.
//  Copyright © 2017年 alongway. All rights reserved.
//

#import "TestTitleTabBarViewController.h"

@interface TestTitleTabBarViewController ()

@end

@implementation TestTitleTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"TitleTabBar";

    [self buildUI];
}

- (void)buildUI
{
    ALWTitleTabBar *titleTabBar = [[ALWTitleTabBar alloc] init];
    titleTabBar.center = self.view.center;
    
    NSArray *titleArray = @[@"涂鸦历史", @"圣诞节", @"名人剪影", @"花朵", @"动物", @"植物", @"名车", @"建筑"];
    [titleTabBar resetTitleTabBarWithTitleArray:titleArray];
    [self.view addSubview:titleTabBar];
}

@end
