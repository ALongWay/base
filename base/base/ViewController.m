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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, DeviceWidth, 20)];
    [label setText:LocalizedString(HelloWorld)];
    [label setTextColor:COLORWITHRRGGBB(0xFF0000)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:FONTFZZYFixed(15)];
    [self.view addSubview:label];
    
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
