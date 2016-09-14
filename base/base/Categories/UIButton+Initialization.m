//
//  UIButton+Initialization.m
//  base
//
//  Created by 李松 on 16/9/14.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "UIButton+Initialization.h"

@implementation UIButton (Initialization)

+(UIButton *)createNavigationBarRedTextButtonWithText:(NSString *)text
{
    CGSize textSize = [StringHelper getStringSizeWith:text font:FONTAppliedFixed(NaviItemTextFontSize)];
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, NaviBarHeight)];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:FONTAppliedFixed(NaviItemTextFontSize), NSFontAttributeName, NaviBarTitleSelectedColor, NSForegroundColorAttributeName, nil];
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    return btn;
}

+(UIButton *)createNavigationBarGrayTextButtonWithText:(NSString *)text
{
    CGSize textSize = [StringHelper getStringSizeWith:text font:FONTAppliedFixed(NaviItemTextFontSize)];
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, NaviBarHeight)];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:FONTAppliedFixed(NaviItemTextFontSize), NSFontAttributeName, NaviItemTextGrayColor, NSForegroundColorAttributeName, nil];
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    return btn;
}

+(UIButton *)createNavigationBarImageButtonWithImage:(UIImage *)image
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 35)];
    [btn setImage:image forState:UIControlStateNormal];
    
    return btn;
}

-(void)setCommonButtonWithText:(NSString *)text
{
    UIFont* btnFont = FONTAppliedBase6(16);
    UIColor* color1 = COLOR(255, 120, 100);
    UIColor* color2 = COLOR(235, 109, 88);
    UIColor* color3 = COLOR(255, 195, 188);
    UIColor* color4 = COLOR(255, 255, 255);
    
    [self setButtonBgImageWithNormalBgImage:[ImageHelper getImageWithColor:color1] highlightBgImage:[ImageHelper getImageWithColor:color2]];
    [self setBackgroundImage:[ImageHelper getImageWithColor:color1] forState:UIControlStateDisabled];
    [self setButtonBorderColor:color1 borderWidth:0.5 cornerRadius:ResizeSideBase6(5)];
    [self setButtonTitleWithText:text font:btnFont normalColor:color4 andHighlightColor:color4];
    [self setButtonTitleWithText:text textColor:color3 font:btnFont forState:UIControlStateDisabled];
}

-(void)setButtonImageWithNormalImage:(UIImage *)normalImg highlightImage:(UIImage *)highlightImg
{
    [self setImage:normalImg forState:UIControlStateNormal];
    [self setImage:highlightImg forState:UIControlStateHighlighted];
}

-(void)setButtonBgImageWithNormalBgImage:(UIImage *)normalBgImg highlightBgImage:(UIImage *)highlightBgImg
{
    [self setBackgroundImage:normalBgImg forState:UIControlStateNormal];
    [self setBackgroundImage:highlightBgImg forState:UIControlStateHighlighted];
}

-(void)setButtonTitleWithText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font forState:(UIControlState)state
{
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil]];
    [self setAttributedTitle:attrStr forState:state];
}

-(void)setButtonTitleWithText:(NSString *)text font:(UIFont *)font normalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor
{
    [self setButtonTitleWithText:text textColor:normalColor font:font forState:UIControlStateNormal];
    [self setButtonTitleWithText:text textColor:highlightColor font:font forState:UIControlStateHighlighted];
}

-(void)setButtonBorderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius
{
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderColor:color.CGColor];
    [self.layer setBorderWidth:width];
    [self.layer setCornerRadius:radius];
}

@end
