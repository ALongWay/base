//
//  FLAnimatedImageView+HttpHelper.h
//  base
//
//  Created by lisong on 16/10/11.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "FLAnimatedImageView.h"

@interface FLAnimatedImageView (HttpHelper)

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

@end
