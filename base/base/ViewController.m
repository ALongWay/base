//
//  ViewController.m
//  base
//
//  Created by 李松 on 16/8/31.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ResizeSideBase6(60), ResizeSideBase6(60))];
    imageView.center = self.view.center;
    [imageView setImage:LOADIMAGE(AppIcon)];
    [imageView.layer setMasksToBounds:YES];
    [imageView.layer setCornerRadius:10];
    [self.view addSubview:imageView];
    
    NSString *content = @"从这篇记录开始，记录的都算是干货了，都是一些编程日常的积累。\n我建议先将基础的工具加入项目，后续的开发效率会呈指数增长。如果在专注功能开发过程中，才发现缺少大量常用的工具，不仅会打断思路，还会拖慢开发节奏。\n当然，在每个项目开始的时候，不可能将全部工具都准备充分，只能依据个人的经验来评估需要提前准备的工具。\n一个好的工匠，必须要有一个好的工具箱，并且还要不断优化它。";
    UIFont *font = FONTAppliedBase6(15);
    UIColor *color = COLORWITHRRGGBB(0xFF0000);
    CGFloat lineHeight = 25;
    
    CGSize contentSize = [StringHelper getStringSizeWith:content font:font lineHeight:lineHeight maxWidth:DeviceWidth];
    NSAttributedString *attrStr = [StringHelper getAttributedStringWithString:content font:font color:color lineHeight:lineHeight maxWidth:DeviceWidth];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, DeviceWidth, contentSize.height)];
    [label setBackgroundColor:[UIColor blackColor]];
    [label setAttributedText:attrStr];
    [label setNumberOfLines:0];
//    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
    
    NSDateComponents *components = [StringHelper getDateComponentsWithDateString:@"2016-09-12 12:56:10"];
    LOG(@"%@", components);
    
    components = [StringHelper getDateComponentsWithDateString:@"2016-09-11 12:56:10"];
    LOG(@"%@", components);

    components = [StringHelper getDateComponentsWithDateString:@"2016-09-10 12:56:10"];
    LOG(@"%@", components);
    
    //加密解密测试
    NSString *message = @"测试各种加密解密方法abc123+=/";
    NSString *key = @"xyz123这是key";
    
    NSString *base64Msg = [EncryptionHelper base64EncodeWithString:message];
    NSString *decodeMsg= [EncryptionHelper decodeBase64WithString:base64Msg];
    
    NSString *md5Msg = [EncryptionHelper MD5SumWithString:message];
    NSString *sha1Msg = [EncryptionHelper SHA1HashWithString:message];
    NSString *sha256Msg = [EncryptionHelper SHA256HashWithString:message];
    
    NSString *aes256Msg = [EncryptionHelper AES256EncryptedString:message usingKey:key];
    NSString *decryptedAESMsg = [EncryptionHelper decryptedAES256String:aes256Msg usingKey:key];
    
    NSString *desMsg = [EncryptionHelper DESEncryptedString:message usingKey:key];
    NSString *decryptedDESMsg = [EncryptionHelper decryptedDESString:desMsg usingKey:key];
    
    LOG(@"message:%@; key:%@", message, key);
    
    LOG(@"base64Msg:%@", base64Msg);
    LOG(@"decodeMsg:%@", decodeMsg);
    LOG(@"md5Msg:%@", md5Msg);
    LOG(@"sha1Msg:%@", sha1Msg);
    LOG(@"sha256Msg:%@", sha256Msg);
    LOG(@"aes256Msg:%@", aes256Msg);
    LOG(@"decryptedAESMsg:%@", decryptedAESMsg);
    LOG(@"desMsg:%@", desMsg);
    LOG(@"decryptedDESMsg:%@", decryptedDESMsg);
}

@end
