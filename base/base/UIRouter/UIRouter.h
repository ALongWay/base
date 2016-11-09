//
//  UIRouter.h
//  base
//
//  Created by 李松 on 16/10/9.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIRouter : NSObject

//统一管理界面的导航控制器和根视图控制器
@property (nonatomic, strong, readonly) UIWindow                            *window;
@property (nonatomic, strong, readonly) UITabBarController                  *tabBarC;
@property (nonatomic, strong, readonly) NSArray<UINavigationController *>   *naviCArray;
@property (nonatomic, strong, readonly) NSArray<UIViewController *>         *rootVCArray;

#pragma mark -
/**
 *  UIRouter单例，负责界面初始化、所有界面控制器的跳转；
 *  每个控制器提供方法和block供router使用；
 *  独立业务模块可由独立分类负责。减小控制器、模块间耦合性。
 *
 *  @return 单例对象
 */
+ (UIRouter *)sharedManager;

/**
 *  通用的简单跳转方法，无传参和回调
 *
 *  @param fromController 原视图控制器
 *  @param toClassName    目标类的名称
 *  @param animated       是否显示push动画
 */
+ (void)pushFromController:(UIViewController *)fromController toClass:(NSString *)toClassName animated:(BOOL)animated;

/**
 *  通用的简单跳转方法，无传参和回调；可自定义跳转配置
 *
 *  @param toClassName  目标类的名称
 *  @param beReadyBlock 自定义的跳转配置
 */
+ (void)pushToClass:(NSString *)toClassName beReady:(void (^)(UIViewController *toController))beReadyBlock;

#pragma mark - 以下，每个方法统一处理具有相同目标控制器、并带有参数或者回调操作的跳转逻辑
+ (void)pushToViewControllerFromUIViewController:(UIViewController *)fromController withParas:(NSDictionary *)paras;

+ (void)pushToTestStarViewControllerFromUIViewController:(UIViewController *)fromController withParas:(NSDictionary *)paras;

@end
