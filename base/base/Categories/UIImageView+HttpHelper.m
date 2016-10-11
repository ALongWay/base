//
//  UIImageView+HttpHelper.m
//  base
//
//  Created by lisong on 16/10/11.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UIImageView+HttpHelper.h"

@implementation UIImageView (HttpHelper)

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority progress:progressBlock completed:completedBlock];
}

@end
