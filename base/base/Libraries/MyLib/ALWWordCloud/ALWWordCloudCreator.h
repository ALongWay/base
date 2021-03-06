//
//  ALWWordCloudCreator.h
//  base
//
//  Created by 李松 on 2016/12/28.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALWWordCloudCreator : NSObject


/**
 需要注意，使用2倍图

 @param imageView imageView description
 @param completion completion description
 @return return value description
 */
- (UIView *)createWordCloudViewWithImageView:(UIImageView *)imageView completionBlock:(void (^)())completion;

@end
