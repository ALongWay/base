//
//  UIButton+Initialization.m
//  base
//
//  Created by 李松 on 16/9/14.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UIButton+Initialization.h"
#import <objc/runtime.h>

typedef void(^ResetTitleAndImageLayoutBlock)(void);

@interface UIButton (InitializationPrivate)

@property (nonatomic, strong) ResetTitleAndImageLayoutBlock     resetTitleAndImageLayoutBlock;

@end

@implementation UIButton (Initialization)

+(void)load
{
    __weak typeof(self) weakSelf = self;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [weakSelf swizzleOriginalSelector:@selector(layoutSubviews) withNewSelector:@selector(base_layoutSubviews)];
    });
}

+(void)swizzleOriginalSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Class selfClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method newMethod = class_getInstanceMethod(selfClass, newSelector);
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    //先用新的IMP加到原始SEL中
    BOOL addSuccess = class_addMethod(selfClass, originalSelector, newIMP, method_getTypeEncoding(newMethod));
    if (addSuccess) {
        class_replaceMethod(selfClass, newSelector, originalIMP, method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (UIButton *)createNavigationBarRedTextButtonWithText:(NSString *)text
{
    CGSize textSize = [StringHelper getStringSizeWith:text font:FONTAppliedFixed(NaviItemTextFontSize)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, NaviBarHeight)];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FONTAppliedFixed(NaviItemTextFontSize), NSFontAttributeName, NaviBarTitleSelectedColor, NSForegroundColorAttributeName, nil];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    return btn;
}

+ (UIButton *)createNavigationBarGrayTextButtonWithText:(NSString *)text
{
    CGSize textSize = [StringHelper getStringSizeWith:text font:FONTAppliedFixed(NaviItemTextFontSize)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, NaviBarHeight)];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:FONTAppliedFixed(NaviItemTextFontSize), NSFontAttributeName, NaviItemTextGrayColor, NSForegroundColorAttributeName, nil];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    return btn;
}

+ (UIButton *)createNavigationBarImageButtonWithImage:(UIImage *)image
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 35)];
    [btn setImage:image forState:UIControlStateNormal];
    
    return btn;
}

#pragma mark -
- (ResetTitleAndImageLayoutBlock)resetTitleAndImageLayoutBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResetTitleAndImageLayoutBlock:(ResetTitleAndImageLayoutBlock)resetTitleAndImageLayoutBlock
{
    objc_setAssociatedObject(self, @selector(resetTitleAndImageLayoutBlock), resetTitleAndImageLayoutBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)base_layoutSubviews
{
    [self base_layoutSubviews];
    
    if (self.resetTitleAndImageLayoutBlock) {
        self.resetTitleAndImageLayoutBlock();
    }
}

- (void)setCommonButtonWithText:(NSString *)text
{
    UIFont *btnFont = FONTAppliedBase6(16);
    UIColor *color1 = COLOR(255, 120, 100);
    UIColor *color2 = COLOR(235, 109, 88);
    UIColor *color3 = COLOR(255, 195, 188);
    UIColor *color4 = COLOR(255, 255, 255);
    
    [self setButtonBgImageWithNormalBgImage:[ImageHelper getImageWithColor:color1] highlightBgImage:[ImageHelper getImageWithColor:color2]];
    [self setBackgroundImage:[ImageHelper getImageWithColor:color1] forState:UIControlStateDisabled];
    [self setButtonBorderColor:color1 borderWidth:0.5 cornerRadius:ResizeSideBase6(5)];
    [self setButtonTitleWithText:text font:btnFont normalColor:color4 andHighlightColor:color4];
    [self setButtonTitleWithText:text textColor:color3 font:btnFont forState:UIControlStateDisabled];
}

- (void)setButtonImageWithNormalImage:(UIImage *)normalImg highlightImage:(UIImage *)highlightImg
{
    [self setImage:normalImg forState:UIControlStateNormal];
    [self setImage:highlightImg forState:UIControlStateHighlighted];
}

- (void)setButtonBgImageWithNormalBgImage:(UIImage *)normalBgImg highlightBgImage:(UIImage *)highlightBgImg
{
    [self setBackgroundImage:normalBgImg forState:UIControlStateNormal];
    [self setBackgroundImage:highlightBgImg forState:UIControlStateHighlighted];
}

- (void)setButtonTitleWithText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font forState:(UIControlState)state
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil]];
    [self setAttributedTitle:attrStr forState:state];
}

- (void)setButtonTitleWithText:(NSString *)text font:(UIFont *)font normalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor
{
    [self setButtonTitleWithText:text textColor:normalColor font:font forState:UIControlStateNormal];
    [self setButtonTitleWithText:text textColor:highlightColor font:font forState:UIControlStateHighlighted];
}

- (void)setButtonBorderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius
{
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderColor:color.CGColor];
    [self.layer setBorderWidth:width];
    [self.layer setCornerRadius:radius];
}

- (void)resetButtonTitleAndImageLayoutWithMidInset:(CGFloat)midInset imageLocation:(ButtonImageLocation)imageLocation
{
    CGSize titleSize  = [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;;
    CGSize imageSize = self.imageView.size;
    
    __weak typeof(self) weakSelf = self;
    
    //因为UIButton在layoutSubviews时候，会重置titleLabel的frame，所以需要延迟调用block
    self.resetTitleAndImageLayoutBlock = ^{
        switch (imageLocation) {
            case ButtonImageLocationUp: {
                CGFloat imageOriginX = (weakSelf.width - imageSize.width) / 2.0;
                CGFloat imageOriginY = (weakSelf.height - titleSize.height - midInset - imageSize.height) / 2.0;
                weakSelf.imageEdgeInsets = UIEdgeInsetsMake(imageOriginY, imageOriginX, weakSelf.height - imageOriginY - imageSize.height, imageOriginX);
                
                CGFloat titleOriginX = (weakSelf.width - titleSize.width) / 2.0;
                CGFloat titleOriginY = imageOriginY + imageSize.height + midInset;
                weakSelf.titleEdgeInsets = UIEdgeInsetsMake(titleOriginY, titleOriginX, weakSelf.height - titleOriginY - titleSize.height, titleOriginX);
                break;
            }
            case ButtonImageLocationLeft: {
                CGFloat imageOriginX = (weakSelf.width - imageSize.width - midInset - titleSize.width) / 2.0;
                CGFloat imageOriginY = (weakSelf.height - imageSize.height) /  2.0;
                weakSelf.imageEdgeInsets = UIEdgeInsetsMake(imageOriginY, imageOriginX, imageOriginY, weakSelf.width - imageOriginX - imageSize.width);
                
                
                CGFloat titleOriginX = imageOriginX + imageSize.width + midInset;
                //横向时候，label的frame可以取较大范围
//                CGFloat titleOriginY = (weakSelf.height - titleSize.height) / 2.0;
//                weakSelf.titleLabel.frame = CGRectMake(titleOriginX, titleOriginY, titleSize.width, titleSize.height);
                weakSelf.titleLabel.frame = CGRectMake(titleOriginX, 0, weakSelf.width - titleOriginX, weakSelf.height);
                [weakSelf.titleLabel setTextAlignment:NSTextAlignmentLeft];
                break;
            }
            case ButtonImageLocationDown: {
                CGFloat titleOriginX = (weakSelf.width - titleSize.width) / 2.0;
                CGFloat titleOriginY = (weakSelf.height - titleSize.height - midInset - imageSize.height) / 2.0;
                weakSelf.titleEdgeInsets = UIEdgeInsetsMake(titleOriginY, titleOriginX, weakSelf.height - titleOriginY - titleSize.height, titleOriginX);
                
                CGFloat imageOriginX = (weakSelf.width - imageSize.width) / 2.0;
                CGFloat imageOriginY = titleOriginY + titleSize.height + midInset;
                weakSelf.imageEdgeInsets = UIEdgeInsetsMake(imageOriginY, imageOriginX, weakSelf.height - imageOriginY - imageSize.height, imageOriginX);
                break;
            }
            case ButtonImageLocationRight: {
                CGFloat titleOriginX = (weakSelf.width - imageSize.width - midInset - titleSize.width) / 2.0;
                //横向时候，label的frame可以取较大范围
//                CGFloat titleOriginY = (weakSelf.height - titleSize.height) / 2.0;
//                weakSelf.titleLabel.frame = CGRectMake(titleOriginX, titleOriginY, titleSize.width, titleSize.height);
                weakSelf.titleLabel.frame = CGRectMake(0, 0, titleOriginX + titleSize.width, weakSelf.height);
                [weakSelf.titleLabel setTextAlignment:NSTextAlignmentRight];
                
                CGFloat imageOriginX = titleOriginX + titleSize.width + midInset;
                CGFloat imageOriginY = (weakSelf.height - imageSize.height) /  2.0;
                weakSelf.imageEdgeInsets = UIEdgeInsetsMake(imageOriginY, imageOriginX, imageOriginY, weakSelf.width - imageOriginX - imageSize.width);
                break;
            }
        }
    };
}

@end
