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
@property (nonatomic, strong) UITabBarController      *tabBarC;

@property (nonatomic, strong) UINavigationController  *naviC1;
@property (nonatomic, strong) UINavigationController  *naviC2;
@property (nonatomic, strong) UINavigationController  *naviC3;
@property (nonatomic, strong) UINavigationController  *naviC4;

@property (nonatomic, strong) UIViewController        *rootVC1;
@property (nonatomic, strong) UIViewController        *rootVC2;
@property (nonatomic, strong) UIViewController        *rootVC3;
@property (nonatomic, strong) UIViewController        *rootVC4;

/**
 *  UIRouter单例，负责界面初始化、所有界面控制器的跳转；
 *  每个控制器提供方法和block供router使用；
 *  独立业务模块可由独立分类负责。减小控制器、模块间耦合性。
 *
 *  @return 单例对象
 */
+ (UIRouter *)sharedManager;

/**
 *  通用的简单跳转方法，无传参和实现协议
 *
 *  @param fromController 原视图控制器
 *  @param toClassName    目标类的名称
 *  @param animated       是否显示push动画
 */
+ (void)pushFromController:(UIViewController *)fromController toClass:(NSString *)toClassName animated:(BOOL)animated;

/**
 *  通用的简单跳转方法，无传参和实现协议；可自定义跳转配置
 *
 *  @param toClassName  目标类的名称
 *  @param beReadyBlock 自定义的跳转配置
 */
+ (void)pushToClass:(NSString *)toClassName beReady:(void (^)(UIViewController *toController))beReadyBlock;

/**
 *  有传参或者实现协议的跳转过程方法；
 *  router负责解析双方控制器、解析传递参数、实现代理方法、回调原控制器的实现方法
 *
 *  @param fromController 原视图控制器
 *  @param toClassName    目标类的名称
 *  @param paras          参数字典，可以为nil
 */
+ (void)pushFromController:(id)fromController toClass:(NSString *)toClassName withParameters:(NSDictionary *)paras;

@end
