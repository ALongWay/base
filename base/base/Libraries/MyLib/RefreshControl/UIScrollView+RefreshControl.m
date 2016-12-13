//
//  UIScrollView+RefreshControl.m
//  base
//
//  Created by 李松 on 16/10/12.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UIScrollView+RefreshControl.h"
#import <objc/runtime.h>
#import "RefreshNormalHeader.h"
#import "RefreshNormalFooter.h"

@implementation UIScrollView (RefreshControl)

- (UIView *)refreshHeader
{
    return objc_getAssociatedObject(self, _cmd);
}

- (UIView *)refreshFooter
{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSUInteger)refreshPageNum
{
    NSUInteger pageNum = [objc_getAssociatedObject(self, _cmd) integerValue];
    
    return pageNum;
}

- (void)setRefreshPageNum:(NSUInteger)refreshPageNum
{
    objc_setAssociatedObject(self, @selector(refreshPageNum), @(refreshPageNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)refreshCountPerPage
{
    NSUInteger countPerPage = [objc_getAssociatedObject(self, _cmd) integerValue];
    
    return countPerPage;
}

- (void)setRefreshCountPerPage:(NSUInteger)refreshCountPerPage
{
    objc_setAssociatedObject(self, @selector(refreshCountPerPage), @(refreshCountPerPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addRefreshHeaderWithRefreshingBlock:(void (^)(void))refreshingBlock
{
    RefreshNormalHeader *header = [RefreshNormalHeader headerWithRefreshingBlock:refreshingBlock];
    objc_setAssociatedObject(self, @selector(refreshHeader), header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setRefreshPageNum:1];
    [self setRefreshCountPerPage:10];
    
    self.mj_header = header;
    
    //增加背景view
    [header setBackgroundColor:[UIColor whiteColor]];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -[UIScreen mainScreen].bounds.size.height, self.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [bgView setBackgroundColor:header.backgroundColor];
    [header insertSubview:bgView atIndex:0];
}

- (void)addRefreshFooterWithRefreshingBlock:(void (^)(void))refreshingBlock
{
    RefreshNormalFooter *footer = [RefreshNormalFooter footerWithRefreshingBlock:refreshingBlock];
    objc_setAssociatedObject(self, @selector(refreshFooter), footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.mj_footer = footer;
    
    //增加背景view
    [footer setBackgroundColor:[UIColor whiteColor]];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, MJRefreshFooterHeight, self.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [bgView setBackgroundColor:footer.backgroundColor];
    [footer insertSubview:bgView atIndex:0];
}

- (void)endRefreshingHeader
{
    [self.mj_header endRefreshing];
}

- (void)endRefreshingFooter
{
    [self.mj_footer endRefreshing];
}

- (void)endRefreshingHeaderAndFooter
{
    [self endRefreshingHeader];
    [self endRefreshingFooter];
}

- (void)showNoMoreDataFooter
{
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)showLoadMoreDataFooter
{
    [self.mj_footer resetNoMoreData];
}

@end
