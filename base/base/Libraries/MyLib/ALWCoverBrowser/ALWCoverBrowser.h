//
//  ALWCoverBrowser.h
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALWCoverBrowserDelegate;

@interface ALWCoverBrowser : UIView

//item配置属性
@property (nonatomic, assign) CGSize    itemMaxSize;
@property (nonatomic, assign) CGSize    itemMinSize;
@property (nonatomic, assign) CGFloat   itemMidMaxInset;
@property (nonatomic, assign) CGFloat   itemMidMinInset;
@property (nonatomic, assign) CGFloat   itemTransform3DAngle;

/**
 滑动方向，默认横向滑动
 */
@property (nonatomic, assign) UICollectionViewScrollDirection   itemScrollDirection;

/**
 是否禁止循环滑动，默认NO
 */
@property (nonatomic, assign) BOOL      disableCircle;

/**
 是否自动滑动，默认NO
 */
@property (nonatomic, assign) BOOL      isAutoScrolling;

/**
 自动滑动周期，默认3秒
 */
@property (nonatomic, assign) CGFloat   autoScrollDuration;

@property (nonatomic, weak) id<ALWCoverBrowserDelegate> delegate;

/**
 采用默认的frame和配置数据，可在init方法后逐个修改

 @return return value description
 */
- (instancetype)init;

/**
 重置item配置，使其填充满容器
 */
- (void)resetItemFillCoverBrowser;

/**
 赋值代理对象，注册UICollectionViewCell
 
 @param delegate delegate description
 @param cellClass cellClass description
 @param identifier identifier description
 */
- (void)setupDelegate:(id<ALWCoverBrowserDelegate>)delegate registerUICollectionViewCellClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/**
 重新加载数据
 */
- (void)reloadData;

@end

@protocol ALWCoverBrowserDelegate <NSObject>

@required
- (NSInteger)alwCoverBrowserNumberOfItems:(ALWCoverBrowser *)coverBrowser;

- (UICollectionViewCell *)alwCoverBrowser:(ALWCoverBrowser *)coverBrowser reuseCollectionViewCell:(UICollectionViewCell *)cell cellForItemAtIndex:(NSInteger)index;

@optional
- (void)alwCoverBrowser:(ALWCoverBrowser *)coverBrowser didSelectItemAtIndex:(NSInteger)index;

- (void)alwCoverBrowser:(ALWCoverBrowser *)coverBrowser didScrollAtIndex:(NSInteger)index;

@end
