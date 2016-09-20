//
//  BaseViewController.m
//  base
//
//  Created by 李松 on 16/9/19.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController (){
    UIButton*       _backBtn;
    UIButton*       _backBtnWhenHideNaviBar;
    BOOL            _isTappedBack;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.pageName = NSStringFromClass([self class]);
    self.willHideStatusBar = NO;
    self.willHideNavigationBar = NO;
    
    //存在导航栏
    if (self.navigationController) {
        //当存在导航栏时候，解决ios7.0以上系统的self.view的originY起始位置在屏幕顶部的问题
        if (DeviceIOSVersionAbove(7)){
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        //设置导航栏
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTranslucent:NO];
        [self.navigationController.navigationBar setBackgroundImage:[ImageHelper getImageWithColor:NaviBarColor] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[ImageHelper getImageWithColor:NaviBarShadowColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:NaviBarTitleAttributes];
        
        //返回按钮
        if (self.navigationController.viewControllers.count > 1) {
            _backBtn = [UIButton createNavigationBarImageButtonWithImage:LOADIMAGE(NaviBarBackBtnImage)];
            [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
            
            self.navigationItem.leftBarButtonItems = @[leftItem];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateStatusBar];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.willHideNavigationBar animated:animated];
        
        if (self.willHideNavigationBar) {
            [self addBackButtonToSelfViewWhenHideNavigationBar];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_isTappedBack) {
        [self releaseVariables];
    }
}

- (void)setWillHideNavigationBar:(BOOL)willHideNavigationBar
{
    //willHideNavigationBar若为YES，将self.view上的scrollView的contentOffset交由自己控制（系统默认偏移到状态栏或者导航栏下边线）
    self.automaticallyAdjustsScrollViewInsets = !willHideNavigationBar;
    
    _willHideNavigationBar = willHideNavigationBar;
}

- (void)addBackButtonToSelfViewWhenHideNavigationBar
{
    if (!_backBtnWhenHideNaviBar) {
        _backBtnWhenHideNaviBar = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_backBtnWhenHideNaviBar setImage:LOADIMAGE(NoNaviBarBackBtnImage) forState:UIControlStateNormal];
        [_backBtnWhenHideNaviBar addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        _backBtnWhenHideNaviBar.center = CGPointMake(15 + _backBtnWhenHideNaviBar.frame.size.width / 2.0, StatusBarHeight + NaviBarHeight / 2.0);
    }
    
    //避免返回按钮被遮挡
    [self.view addSubview:_backBtnWhenHideNaviBar];
}

#pragma mark -- 【状态栏控制方法
#ifdef UseDefaultUIViewControllerBasedStatusBarSystem

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.willHideStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#endif

- (void)updateStatusBar
{
#ifdef UseDefaultUIViewControllerBasedStatusBarSystem
    [self setNeedsStatusBarAppearanceUpdate];
#else
    [[UIApplication sharedApplication] setStatusBarHidden:self.willHideStatusBar withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
#endif
}

#pragma mark -- 】状态栏控制方法

- (void)goBack
{
    _isTappedBack = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)releaseVariables
{
    //释放变量和资源
}

@end
