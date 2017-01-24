//
//  ViewController.m
//  base
//
//  Created by 李松 on 16/8/31.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    UIScrollView        *_scrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"测试界面";

    if (self.navigationController.viewControllers.count > 2) {
        self.willHideNavigationBar = YES;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - StatusBarHeight - NaviBarHeight - TabBarHeight)];
    [self.view addSubview:_scrollView];
    
    __weak UIScrollView *weakScrollView = _scrollView;

    [_scrollView addRefreshHeaderWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakScrollView endRefreshingHeader];
            });
        });
    }];
   
    [_scrollView addRefreshFooterWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakScrollView endRefreshingFooter];
            });
        });
    }];
    
    UIView *statusBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, StatusBarHeight)];
    [statusBarBgView setBackgroundColor:[UIColor redColor]];
    [_scrollView addSubview:statusBarBgView];
    
    UIView *naviBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarBgView.maxY, DeviceWidth, NaviBarHeight)];
    [naviBarBgView setBackgroundColor:[UIColor blackColor]];
    [_scrollView addSubview:naviBarBgView];

    UIView *contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, naviBarBgView.maxY, DeviceWidth, NaviBarHeight)];
    [contentBgView setBackgroundColor:[UIColor blueColor]];
    [_scrollView addSubview:contentBgView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [button setCommonButtonWithText:@"截屏"];
    [button setImage:LOADIMAGE(kImageNoNaviBarBackBtn) forState:UIControlStateNormal];
    [button resetButtonTitleAndImageLayoutWithMidInset:5 imageLocation:ButtonImageLocationRight];
    button.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
    [button addTarget:self action:@selector(testSnapshot) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button];
    
    UIImage *icon = LOADIMAGE(kImageAppIcon);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) + 20, ResizeSideBase6(60), ResizeSideBase6(60))];
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    [imageView setImage:icon];
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setCornerRadius:10];
    [_scrollView addSubview:imageView];
    
    NSString *content = @"从这篇记录开始，记录的都算是干货了，都是一些编程日常的积累。\n我建议先将基础的工具加入项目，后续的开发效率会呈指数增长。如果在专注功能开发过程中，才发现缺少大量常用的工具，不仅会打断思路，还会拖慢开发节奏。\n当然，在每个项目开始的时候，不可能将全部工具都准备充分，只能依据个人的经验来评估需要提前准备的工具。\n一个好的工匠，必须要有一个好的工具箱，并且还要不断优化它。";
    UIFont *font = FONTAppliedBase6(15);
    UIColor *color = COLORWITHRRGGBB(0xFF0000);
    CGFloat lineHeight = 25;
    
    CGSize contentSize = [StringHelper getStringSizeWith:content font:font lineHeight:lineHeight maxWidth:DeviceWidth];
    NSAttributedString *attrStr = [StringHelper getAttributedStringWithString:content font:font color:color lineHeight:lineHeight];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, DeviceWidth, contentSize.height)];
    [label setBackgroundColor:[UIColor blackColor]];
    [label setAttributedText:attrStr];
    [label setNumberOfLines:0];
//    [label setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:label];
    
    [_scrollView setContentSize:CGSizeMake(DeviceWidth, CGRectGetMaxY(label.frame) + 20)];
    
    NSDateComponents *components = [StringHelper getDateComponentsWithDateString:@"2016-09-12 12:56:10"];
    LOG(@"%@", components);
    
    components = [StringHelper getDateComponentsWithDateString:@"2016-09-11 12:56:10"];
    LOG(@"%@", components);

    components = [StringHelper getDateComponentsWithDateString:@"2016-09-10 12:56:10"];
    LOG(@"%@", components);
    
    //加密解密测试
    NSString *message = @"测试各种加密解密方法abc123+=/";
    NSString *key = @"xyz123这是key";
    
    LOG(@"message地址：%p", message);
    
    NSString *base64Msg = [EncryptionHelper base64EncodeWithString:message];
    NSString *decodeMsg= [EncryptionHelper decodeBase64WithString:base64Msg];
    
    NSString *md5Msg = [EncryptionHelper MD5SumWithString:message];
    NSString *sha1Msg = [EncryptionHelper SHA1HashWithString:message];
    NSString *sha256Msg = [EncryptionHelper SHA256HashWithString:message];
    
    NSString *aes256Msg = [EncryptionHelper AES256EncryptedString:message usingKey:key];
    NSString *decryptedAESMsg = [EncryptionHelper decryptedAES256String:aes256Msg usingKey:key];
    
    NSString *desMsg = [EncryptionHelper DESEncryptedString:message usingKey:key];
    NSString *decryptedDESMsg = [EncryptionHelper decryptedDESString:desMsg usingKey:key];
    
    LOG(@"message:%@; key:%@", message, key);
    
    LOG(@"base64Msg:%@", base64Msg);
    LOG(@"decodeMsg:%@", decodeMsg);
    LOG(@"md5Msg:%@", md5Msg);
    LOG(@"sha1Msg:%@", sha1Msg);
    LOG(@"sha256Msg:%@", sha256Msg);
    LOG(@"aes256Msg:%@", aes256Msg);
    LOG(@"decryptedAESMsg:%@", decryptedAESMsg);
    LOG(@"desMsg:%@", desMsg);
    LOG(@"decryptedDESMsg:%@", decryptedDESMsg);
    
    UIButton *nextUI = [UIButton createNavigationBarGrayTextButtonWithText:@"Next"];
    [nextUI addTarget:self action:@selector(nextUI) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:nextUI];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    NSCache *cache = (NSCache *)[imageCache valueForKey:@"memCache"];
    NSString *memCache = cache.name;
    NSString *diskCachePath = [imageCache valueForKey:@"diskCachePath"];
    
    LOG(@"SDImageCache memCache name: %@; diskCachePath: %@", memCache, diskCachePath);
}

- (void)nextUI
{
//    ViewController *newVC = [[ViewController alloc] init];
//    [self.navigationController pushViewController:newVC animated:YES];
//    
//    [UIRouter pushFromController:self toClass:@"ViewController" animated:YES];
//    
//    WeakSelf(weakSelf);
//    [UIRouter pushToClass:@"ViewController" beReady:^(UIViewController *toController) {
//        toController.hidesBottomBarWhenPushed = YES;
//        [weakSelf.navigationController pushViewController:toController animated:YES];
//    }];
//    
//    [UIRouter pushToViewControllerFromUIViewController:self withParas:nil];
    
#pragma mark -- 测试ViewController
//    [UIRouter pushFromController:self toClass:@"TestCollectionViewController" animated:YES];
//
//    [UIRouter pushFromController:self toClass:@"TestStarViewController" animated:YES];
//
//    [UIRouter pushFromController:self toClass:@"TestScratchCardViewController" animated:YES];
    
//    [UIRouter pushToTestStarViewControllerFromUIViewController:self withParas:nil];
    
//    [UIRouter pushToClass:@"TestCoverBrowserViewController" FromController:self animated:YES];
    
//    [UIRouter pushToClass:@"TestWordCloudViewController" FromController:self animated:YES];
    
    [UIRouter pushToClass:@"TestTitleTabBarViewController" FromController:self animated:YES];
}

- (void)testSnapshot
{
    [_scrollView.refreshHeader setHidden:!_scrollView.refreshHeader.hidden];
    [_scrollView.refreshFooter setHidden:!_scrollView.refreshFooter.hidden];
 
//    [SVProgressHUD show];
//    [SVProgressHUD showProgress:0.6 status:@"数据加载中..."];
    
    [SVProgressHUD showAppUITransitionAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    //测试GCD
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t customSerialQueue = dispatch_queue_create("customserialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t customConcurrentQueue  = dispatch_queue_create("customconcurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
//    LOG(@"测试GCD dispatch_async");
//    
//    dispatch_async(mainQueue, ^{
//        LOG(@"dispatch_async No.1 mainQueue : %@", [NSThread currentThread]);
//    });
//    
//    dispatch_async(globalQueue, ^{
//        LOG(@"dispatch_async No.2 globalQueue : %@", [NSThread currentThread]);
//    });
//    
//    dispatch_async(customSerialQueue, ^{
//        LOG(@"dispatch_async No.3 customSerialQueue : %@", [NSThread currentThread]);
//    });
//    
//    dispatch_async(customConcurrentQueue, ^{
//        LOG(@"dispatch_async No.4 customConcurrentQueue : %@", [NSThread currentThread]);
//    });
    
//    LOG(@"测试GCD dispatch_sync");
//
////    dispatch_sync(mainQueue, ^{
////        LOG(@"dispatch_sync No.1 mainQueue : %@", [NSThread currentThread]);
////    });
//    
//    dispatch_sync(globalQueue, ^{
//        LOG(@"dispatch_sync No.2 globalQueue : %@", [NSThread currentThread]);
//    });
//    
//    dispatch_sync(customSerialQueue, ^{
//        LOG(@"dispatch_sync No.3 customSerialQueue : %@", [NSThread currentThread]);
//    });
//    
//    dispatch_sync(customConcurrentQueue, ^{
//        LOG(@"dispatch_sync No.4 customConcurrentQueue : %@", [NSThread currentThread]);
//    });
    
    LOG(@"测试GCD dispatch_async混合dispatch_sync");
    LOG(@"mainThread : %@", [NSThread mainThread]);

    dispatch_async(customSerialQueue, ^{
        LOG(@"level 1 dispatch_async No.1 customSerialQueue : %@", [NSThread currentThread]);
        
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.1 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.2 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.3 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        //==============================
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.4 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.5 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.6 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        //==============================
        dispatch_sync(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_sync No.7 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_sync(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_sync No.8 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_sync(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_sync No.9 customConcurrentQueue : %@", [NSThread currentThread]);
        });
    });

    dispatch_async(customConcurrentQueue, ^{
        LOG(@"level 1 dispatch_async No.2 customConcurrentQueue : %@", [NSThread currentThread]);
        
        dispatch_sync(customSerialQueue, ^{
            LOG(@"level 2 dispatch_sync No.10 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_sync(customSerialQueue, ^{
            LOG(@"level 2 dispatch_sync No.11 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_sync(customSerialQueue, ^{
            LOG(@"level 2 dispatch_sync No.12 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        //==============================
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.13 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.14 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customConcurrentQueue, ^{
            LOG(@"level 2 dispatch_async No.15 customConcurrentQueue : %@", [NSThread currentThread]);
        });
        
        //==============================
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.16 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.17 customSerialQueue : %@", [NSThread currentThread]);
        });
        
        dispatch_async(customSerialQueue, ^{
            LOG(@"level 2 dispatch_async No.18 customSerialQueue : %@", [NSThread currentThread]);
        });
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LOG(@"dispatch_after 5 秒后执行");
    });
    
    dispatch_apply(10, globalQueue, ^(size_t index) {
        LOG(@"dispatch_apply : %zu", index);
    });
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, globalQueue, ^{
        LOG(@"dispatch_group_async : 1");
    });
    
    dispatch_group_async(group, globalQueue, ^{
        LOG(@"dispatch_group_async : 2");
    });
    
    dispatch_group_async(group, globalQueue, ^{
        LOG(@"dispatch_group_async : 3");
    });
    
    dispatch_group_async(group, globalQueue, ^{
        LOG(@"dispatch_group_async : 4");
    });
    
    dispatch_group_notify(group, globalQueue, ^{
        LOG(@"dispatch_group_async : completion");
    });
    
//    return;
    
    UIImage *icon = LOADIMAGE(kImageAppIcon);

    UIImage *testImg;
    testImg = [ImageHelper getImageWithOriginalImage:icon scale:2];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getImageWithOriginalImage:icon scaleMaxSize:CGSizeMake(100, 90)];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getImageWithOriginalImage:icon fillSize:CGSizeMake(100, 90)];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getImageWithOriginalImage:icon cutFrame:CGRectMake(10, 10, 50, 50)];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getImageWithColor:COLOR(255, 120, 100)];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getSnapshotWithView:self.view];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getFullScreenSnapshotWithoutStatusBar];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getFullScreenSnapshotWithStatusBar];
    LOG(@"%@", testImg);
    testImg = [ImageHelper getBlurEffectImageWithOriginalImage:testImg style:ImageHelperBlurEffectStyleDark];
    LOG(@"%@", testImg);
    
    LOG(@"%p", testImg);
    
    UIView *coverView = [ImageHelper getBlurEffectViewWithOriginalView:[UIApplication sharedApplication].keyWindow style:ImageHelperBlurEffectStyleDark];
    [coverView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeCoverView:)];
    [coverView addGestureRecognizer:tapGest];
}

- (void)removeCoverView:(UITapGestureRecognizer *)tapGest
{
    UIView *coverView = tapGest.view;
    [coverView removeFromSuperview];
}

#pragma mark -- Callback methods
- (void)testStarViewControllerDidSelectedTotalScoreWithScore:(CGFloat)totalScore
{
    LOG(@"ViewController totalScore: %f", totalScore);
}

@end
