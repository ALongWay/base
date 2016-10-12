//
//  UIScrollView+RefreshControl.h
//  base
//
//  Created by 李松 on 16/10/12.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (RefreshControl)

/**
 *  头部刷新控件，可以自行设置hidden属性
 */
@property (nonatomic, strong, readonly) UIView      *refreshHeader;

/**
 *  底部刷新控件，可以自行设置hidden属性
 */
@property (nonatomic, strong, readonly) UIView      *refreshFooter;

/**
 *  分页数据中，请求的当前页数，考虑到网络请求失败，请自行管理；添加刷新后，默认为1
 */
@property (nonatomic, assign          ) NSUInteger   refreshPageNum;

/**
 *  分页数据中，每页请求的数量；添加刷新后，默认为10
 */
@property (nonatomic, assign          ) NSUInteger   refreshCountPerPage;

/**
 *  添加头部刷新控件
 *
 *  @param refreshingBlock refreshingBlock description
 */
- (void)addRefreshHeaderWithRefreshingBlock:(void (^)(void))refreshingBlock;

/**
 *  添加底部刷新控件
 *
 *  @param refreshingBlock refreshingBlock description
 */
- (void)addRefreshFooterWithRefreshingBlock:(void (^)(void))refreshingBlock;

/**
 *  结束头部刷新动画
 */
- (void)endRefreshingHeader;

/**
 *  结束底部刷新动画
 */
- (void)endRefreshingFooter;

/**
 *  结束头部和底部的刷新动画
 */
- (void)endRefreshingHeaderAndFooter;

@end
