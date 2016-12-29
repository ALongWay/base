//
//  TestWordCloudViewController.m
//  base
//
//  Created by 李松 on 2016/12/29.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestWordCloudViewController.h"

@interface TestWordCloudViewController ()

@end

@implementation TestWordCloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Word Cloud";
    
    [self buildUI];
}

- (void)buildUI
{
    [SVProgressHUD show];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    [bgView setBackgroundColor:COLOR(0, 0, 0)];
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    centerView.center = CGPointMake(bgView.width / 2.0, bgView.height / 2.0);
    [centerView setBackgroundColor:COLOR(255, 255, 255)];
    [bgView addSubview:centerView];
    
    UIImage *image = [ImageHelper getSnapshotWithView:bgView];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    ALWWordCloudCreator *wcCreator = [[ALWWordCloudCreator alloc] init];
    UIView *wordCloudView = [wcCreator createWordCloudViewWithImageView:imageView completionBlock:^{
        LOG(@"计算完成");
        [SVProgressHUD showSuccessWithStatus:@"计算完成"];
    }];
   
    wordCloudView.origin = CGPointMake((DeviceWidth - wordCloudView.width) / 2.0, 40);
    [self.view addSubview:wordCloudView];
}

@end
