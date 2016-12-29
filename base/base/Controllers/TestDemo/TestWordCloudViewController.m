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
    
    WeakSelf(weakSelf);
    ALWWordCloudCreator *wcCreator = [[ALWWordCloudCreator alloc] init];
    [wcCreator createWordCloudViewWithImageView:imageView completionBlock:^(UIView *wordCloudView) {
        [SVProgressHUD dismiss];
        
        wordCloudView.origin = CGPointMake((DeviceWidth - wordCloudView.width) / 2.0, 40);
        [weakSelf.view addSubview:wordCloudView];
    }];
}

@end
