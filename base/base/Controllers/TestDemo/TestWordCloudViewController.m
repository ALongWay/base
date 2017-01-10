//
//  TestWordCloudViewController.m
//  base
//
//  Created by 李松 on 2016/12/29.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestWordCloudViewController.h"

@interface TestWordCloudViewController (){
    UIImageView     *_testImageView;
    UIImage         *_testImage;
    UISlider        *_slider;
    
    ALWWordCloudCreator *_wcCreator;
}

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
//    [SVProgressHUD show];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
//    [imageView setImage:LOADIMAGE(@"wordcloudTestBg.jpg")];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 277)];
//    [imageView setImage:LOADIMAGE(@"heart.jpg")];
//    
//    _wcCreator = [[ALWWordCloudCreator alloc] init];
//    UIView *wordCloudView = [_wcCreator createWordCloudViewWithImageView:imageView completionBlock:^{
//        [SVProgressHUD showSuccessWithStatus:@"计算完成"];
//    }];
//   
//    wordCloudView.origin = CGPointMake((DeviceWidth - wordCloudView.width) / 2.0, 40);
//    [self.view addSubview:wordCloudView];
    
    //-----------------------
    //测试图像二值化处理
    _testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [_testImageView setImage:LOADIMAGE(@"whiteBlackTest.jpg")];
    
    _testImage = LOADIMAGE(@"whiteBlackTest.jpg");
    [_testImageView setImage:_testImage];
    [self.view addSubview:_testImageView];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(100, DeviceHeight - StatusBarHeight - NaviBarHeight - 200, 150, 10)];
    _slider.minimumValue = 0;
    _slider.maximumValue = 1;
    [_slider setValue:0.5 animated:NO];
    [_slider addTarget:self action:@selector(sliderDidChangedValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    
    [self sliderDidChangedValue];
}

- (void)sliderDidChangedValue
{
    [ImageHelper getBinaryzationImageWithOriginalImage:_testImage factor:_slider.value completionBlock:^(UIImage *resultImage) {
        [_testImageView setImage:resultImage];
    }];
}

@end
