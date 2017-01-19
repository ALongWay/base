//
//  BaseViewController.h
//  base
//
//  Created by 李松 on 16/9/19.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kImageNoNaviBarBackBtn = @"BaseViewController.bundle/noNaviBarBackBtn.png";
static NSString * const kImageNaviBarBackBtn = @"BaseViewController.bundle/naviBarBackBtn.png";

//使用基于视图控制器的状态栏控制系统，UIApplication的setStatusBarHidden类似方法将无效
//开启此宏定义，请将Info.plist中View controller-based status bar appearance设置为YES，否则置为NO
//#define UseDefaultUIViewControllerBasedStatusBarSystem

@interface BaseViewController : UIViewController

/**
 *  标记视图控制器，可以在viewDidLoad时候命名，默认使用视图控制器类名
 */
@property (nonatomic, strong) NSString          *pageName;

/**
 *  是否将隐藏状态栏，建议在viewDidLoad中设置
 */
@property (nonatomic, assign) BOOL               willHideStatusBar;

/**
 *  状态栏样式，建议在viewDidLoad中设置
 */
@property (nonatomic, assign) UIStatusBarStyle   statusBarStyle;

/**
 *  1.是否将隐藏导航栏，建议在viewDidLoad中设置（该属性与UINavigationController自带属性不同，不会立即生效，只会在viewWillAppear时候生效）
 *  2.若为YES，将self.view上的scrollView的contentOffset交由自己控制（系统默认偏移到状态栏或者导航栏下边线）
 */
@property (nonatomic, assign) BOOL               willHideNavigationBar;

/**
 *  更新状态栏，viewWillAppear方法会自动调用，可以忽略
 */
- (void)updateStatusBar;

/**
 *  返回上一个界面
 */
- (void)goBack;

/**
 *  释放资源
 */
- (void)releaseVariables;

@end
