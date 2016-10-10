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

@implementation UIRouter

- (instancetype)init
{
    return [UIRouter sharedManager];
}

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
