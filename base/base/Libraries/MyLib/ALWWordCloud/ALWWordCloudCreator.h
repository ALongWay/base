//
//  ALWWordCloudCreator.h
//  base
//
//  Created by 李松 on 2016/12/28.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALWWordCloudCreator : NSObject

- (void)createWordCloudViewWithImageView:(UIImageView *)imageView completionBlock:(void(^)(UIView *wordCloudView))completion;

@end
