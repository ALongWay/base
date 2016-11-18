//
//  TestCoverBrowserViewController.m
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestCoverBrowserViewController.h"

@interface TestCoverBrowserViewController ()

@end

@implementation TestCoverBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"CoverBrowser";
    
    ALWCoverBrowser *cBView = [[ALWCoverBrowser alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 228)];
    cBView.center = CGPointMake(cBView.center.x, self.view.center.y - 64);
    [self.view addSubview:cBView];
}

@end
