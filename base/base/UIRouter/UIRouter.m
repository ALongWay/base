//
//  UIRouter.m
//  base
//
//  Created by 李松 on 16/10/9.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UIRouter.h"

#pragma mark -- 引用全部视图控制器头文件
#import "AllViewControllerHeaders.h"

static UIRouter *router;

@interface UIRouter ()<UITabBarControllerDelegate>

@property (nonatomic, strong, readwrite) UIWindow                           *window;
@property (nonatomic, strong, readwrite) UITabBarController                 *tabBarC;
@property (nonatomic, strong, readwrite) NSArray<UINavigationController *>  *naviCArray;
@property (nonatomic, strong, readwrite) NSArray<UIViewController *>        *rootVCArray;

@property (nonatomic, strong, readwrite) UINavigationController  *naviC1;
@property (nonatomic, strong, readwrite) UINavigationController  *naviC2;
@property (nonatomic, strong, readwrite) UINavigationController  *naviC3;
@property (nonatomic, strong, readwrite) UINavigationController  *naviC4;

@property (nonatomic, strong, readwrite) ViewController          *rootVC1;
@property (nonatomic, strong, readwrite) ViewController          *rootVC2;
@property (nonatomic, strong, readwrite) ViewController          *rootVC3;
@property (nonatomic, strong, readwrite) ViewController          *rootVC4;

@end

@implementation UIRouter

- (instancetype)init
{
    if (router) {
        return router;
    }
    
    self = [super init];
    if (self) {
        [self buildAppBaseUI];
    }
    
    return self;
}

- (void)buildAppBaseUI
{
    _rootVC1 = [[ViewController alloc] init];
    _rootVC2 = [[ViewController alloc] init];
    _rootVC3 = [[ViewController alloc] init];
    _rootVC4 = [[ViewController alloc] init];
    
    _rootVCArray = @[_rootVC1, _rootVC2, _rootVC3, _rootVC4];
    
    _rootVC1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"1" image:[LOADIMAGE(kImageNoNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[LOADIMAGE(kImageNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _rootVC2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"2" image:[LOADIMAGE(kImageNoNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[LOADIMAGE(kImageNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _rootVC3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"3" image:[LOADIMAGE(kImageNoNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[LOADIMAGE(kImageNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _rootVC4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"4" image:[LOADIMAGE(kImageNoNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[LOADIMAGE(kImageNaviBarBackBtn) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    _naviC1 = [[UINavigationController alloc] initWithRootViewController:_rootVC1];
    _naviC2 = [[UINavigationController alloc] initWithRootViewController:_rootVC2];
    _naviC3 = [[UINavigationController alloc] initWithRootViewController:_rootVC3];
    _naviC4 = [[UINavigationController alloc] initWithRootViewController:_rootVC4];
    
    _naviCArray = @[_naviC1, _naviC2, _naviC3, _naviC4];
    
    _tabBarC = [[UITabBarController alloc] init];
    _tabBarC.delegate = self;
    _tabBarC.viewControllers = _naviCArray;
    _tabBarC.tabBar.shadowImage = [ImageHelper getImageWithColor:NaviBarShadowColor];
    
    UITabBar* tabBar = _tabBarC.tabBar;
    [tabBar setBackgroundImage:[ImageHelper getImageWithColor:[UIColor whiteColor]]];
    //    [tabBar setSelectionIndicatorImage:nil];//设置被选中选项背景图
    CGFloat tabBarFontSize = 10;
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NaviBarTitleUnselectedColor, NSForegroundColorAttributeName,FONTAppliedBase6(tabBarFontSize),NSFontAttributeName,nil] forState:UIControlStateNormal];//设置显示文字的颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NaviBarTitleSelectedColor, NSForegroundColorAttributeName,FONTAppliedBase6(tabBarFontSize),NSFontAttributeName,nil] forState:UIControlStateSelected];//设置显示文字的颜色
    
    //上移动title的位置
    //UIOffset titleOffset = [[UITabBarItem appearance] titlePositionAdjustment];
    //titleOffset.vertical -= 3;
    //[[UITabBarItem appearance] setTitlePositionAdjustment:titleOffset];
    
    //初始化window
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window setBackgroundColor:[UIColor whiteColor]];
    
#define ShowNaviBar
#ifdef ShowNaviBar
    _window.rootViewController = _tabBarC;
#else
    _window.rootViewController = _rootVC1;
#endif
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window = _window;
    [_window makeKeyAndVisible];
}

#pragma mark -- UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

}

#pragma mark -
+ (UIRouter *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[UIRouter alloc] init];
    });
    
    return router;
}

+ (void)pushFromController:(UIViewController *)fromController toClass:(NSString *)toClassName animated:(BOOL)animated
{
    Class toClass = NSClassFromString(toClassName);
    id toController = [[toClass alloc] init];
    
    if ([toController isKindOfClass:[UIViewController class]]) {
        ((UIViewController *)toController).hidesBottomBarWhenPushed = YES;
        [fromController.navigationController pushViewController:toController animated:animated];
    }else{
        LOG(@"不存在UIViewController：%@", toClassName);
    }
}

+ (void)pushToClass:(NSString *)toClassName beReady:(void (^)(UIViewController *))beReadyBlock
{
    Class toClass = NSClassFromString(toClassName);
    id toController = [[toClass alloc] init];
    
    if ([toController isKindOfClass:[UIViewController class]]) {
        if (beReadyBlock) {
            beReadyBlock(toController);
        }
    }else{
        LOG(@"不存在UIViewController：%@", toClassName);
    }
}

+ (void)pushFromController:(id)fromController toClass:(NSString *)toClassName withParameters:(NSDictionary *)paras
{
    Class toClass = NSClassFromString(toClassName);
    
    if ([fromController isMemberOfClass:[ViewController class]]
        && toClass == [ViewController class]) {
        [UIRouter pushToViewControllerFromViewController:fromController withParas:paras];
        return;
    }
    
    NSString *fromClassName = [NSString stringWithUTF8String:object_getClassName(fromController)];
    LOG(@"未实现跳转from：%@，to：%@", fromClassName, toClassName);
}

#pragma mark -- 处理带有参数或者回调操作的跳转逻辑
+ (void)pushToViewControllerFromViewController:(ViewController *)fromController withParas:(NSDictionary *)paras
{
    //可以传递参数或者设置代理、回调block
    //To do
    
    ViewController *toController = [[ViewController alloc] init];
    toController.hidesBottomBarWhenPushed = YES;
    [fromController.navigationController pushViewController:toController animated:YES];
}


@end
