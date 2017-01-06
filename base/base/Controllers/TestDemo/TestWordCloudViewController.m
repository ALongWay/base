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
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
//    [imageView setImage:LOADIMAGE(@"wordcloudTestBg.jpg")];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 277)];
    [imageView setImage:LOADIMAGE(@"heart.jpg")];
    
    ALWWordCloudCreator *wcCreator = [[ALWWordCloudCreator alloc] init];
    UIView *wordCloudView = [wcCreator createWordCloudViewWithImageView:imageView completionBlock:^{
        [SVProgressHUD showSuccessWithStatus:@"计算完成"];
    }];
   
    wordCloudView.origin = CGPointMake((DeviceWidth - wordCloudView.width) / 2.0, 40);
    [self.view addSubview:wordCloudView];
}

@end
