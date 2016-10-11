//
//  UIImageView+HttpHelper.h
//  base
//
//  Created by lisong on 16/10/11.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HttpHelper)

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock)completedBlock;

@end
