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

@property (nonatomic, assign) CGSize    itemMaxSize;
@property (nonatomic, assign) CGSize    itemMinSize;
@property (nonatomic, assign) CGFloat   itemMidMaxInset;
@property (nonatomic, assign) CGFloat   itemMidMinInset;
@property (nonatomic, assign) CGFloat   itemTransform3DAngle;

@property (nonatomic, weak) id<ALWCoverBrowserDelegate> delegate;

/**
 采用默认的frame和配置数据，可在init方法后逐个修改

 @return return value description
 */
- (instancetype)init;


/**
 注册UICollectionViewCell

 @param cellClass cellClass description
 @param identifier identifier description
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

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

@end
