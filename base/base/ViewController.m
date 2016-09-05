//
//  ViewController.m
//  base
//
//  Created by 李松 on 16/8/31.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ResizeSideBase6(60), ResizeSideBase6(60))];
    imageView.center = self.view.center;
    [imageView setImage:LOADIMAGE(AppIcon)];
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setCornerRadius:10];
    [self.view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, DeviceWidth, 20)];
    [label setText:LocalizedString(HelloWorld)];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:FONTFZZYFixed(15)];
    [self.view addSubview:label];
}

@end
