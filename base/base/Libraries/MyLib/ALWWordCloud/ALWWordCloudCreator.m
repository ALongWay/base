//
//  ALWWordCloudCreator.m
//  base
//
//  Created by 李松 on 2016/12/28.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWWordCloudCreator.h"

@interface ALWWordCloudLabelContainer : NSObject

@property (nonatomic, strong) NSString      *wordText;
@property (nonatomic, strong) UIFont        *wordFont;
@property (nonatomic, strong) UIColor       *wordColor;
@property (nonatomic, assign) CGSize        wordSize;

@property (nonatomic, assign) CGRect        currentRect;
@property (nonatomic, assign) CGFloat       currentAngle;
@property (nonatomic, assign) CGPathRef     currentPath;

@end

@implementation ALWWordCloudLabelContainer


@end

#pragma mark -
@interface ALWWordCloudCreator ()

//字体可配置相关属性
@property (nonatomic, assign) CGFloat       wordMaxFontSize;
@property (nonatomic, assign) CGFloat       wordMinFontSize;
@property (nonatomic, assign) CGFloat       wordFontStepValue;
@property (nonatomic, assign) CGFloat       wordMinInset;

@property (nonatomic, strong) NSArray<UIColor*>     *wordColorArray;
@property (nonatomic, strong) NSArray<NSString*>    *wordTextArray;
@property (nonatomic, strong) NSArray<NSNumber*>    *wordAngleArray;

//计算相关属性
@property (nonatomic, strong) NSArray<NSValue*>     *wordSizeArray;//去掉了重复的size
//保留全部可能的labelcontainer对象
@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *labelContainerArray;

@property (nonatomic, strong) NSArray<NSValue*>     *whitePointsArray;//不可绘制点
@property (nonatomic, strong) NSArray<NSValue*>     *blackPointsArray;//可绘制点

@property (nonatomic, strong) NSMutableArray<UIBezierPath*>     *occupiedPathsArray;

@end

@implementation ALWWordCloudCreator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化变量
        self.wordMaxFontSize = 25;
        self.wordMinFontSize = 10;
        self.wordFontStepValue = 2;
        self.wordMinInset = 2;
        
        self.wordColorArray = @[[UIColor redColor],
                                [UIColor greenColor],
                                [UIColor blueColor],
                                [UIColor yellowColor]
                                ];
        self.wordTextArray = @[@"测试",
                               @"haha",
                               @"额",
                               @"试一试",
                               @"什么龟",
                               @"字体云",
                               @"效果",
                               @"不知道",
                               @"PHP",
                               @"JS",
                               @"Objective-C",
                               @"Java",
                               @"C++",
                               @"Go",
                               @"Nodejs",
                               @"C#",
                               @"iOS"
                               ];
        self.wordAngleArray = @[@(0), @(M_PI_4), @(-M_PI_4)];
    }
    
    return self;
}

#pragma mark -- Getter/Setter
- (NSMutableArray<UIBezierPath *> *)occupiedPathsArray
{
    if (!_occupiedPathsArray) {
        _occupiedPathsArray = [NSMutableArray array];
    }
    
    return _occupiedPathsArray;
}

#pragma mark -- Public methods
- (UIView *)createWordCloudViewWithImageView:(UIImageView *)imageView
{
    [self buildContainerArrayAndCalculateWordSizeArray];
    
    UIView *wcView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [wcView setBackgroundColor:[UIColor clearColor]];
    
    UIImage *currentImage = imageView.image;
    [self identifyWhiteAndBlackPointsWithImage:currentImage];
    
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:wcView.frame];
    [newImageView setBackgroundColor:[UIColor clearColor]];
    [newImageView setImage:currentImage];
    [wcView addSubview:newImageView];
    
    for (NSValue *value in self.blackPointsArray) {
        CGPoint currentPoint = [value CGPointValue];
        
        if ([self canUseCenterPoint:currentPoint]) {
            
        } else {
            
        }
    }
    
    return wcView;
}

#pragma mark -- Private methods
- (UIFont *)getCurrentShowFontWithFontSize:(CGFloat)fontSize
{
    UIFont *showFont = [UIFont systemFontOfSize:fontSize];
    
    return showFont;
}

- (void)buildContainerArrayAndCalculateWordSizeArray
{
    NSMutableArray *tempLabelContainerArray = [NSMutableArray array];
    NSMutableArray *tempWordSizeArray = [NSMutableArray array];
    
    //取最长关键字、字体和size、角度生成
    NSString *firstText = [self.wordTextArray firstObject];
    CGFloat firstLength = [firstText sizeWithAttributes:nil].width;

    NSString *maxLengthText = firstText;
    CGFloat maxLength = firstLength;
    
    NSString *minLengthText = firstText;
    CGFloat minLength = firstLength;
    
    for (NSString *text in self.wordTextArray) {
        for (int i = _wordMinFontSize; i <= _wordMaxFontSize; i+=_wordFontStepValue) {
            CGSize currentSize = [text sizeWithAttributes:@{NSFontAttributeName : [self getCurrentShowFontWithFontSize:i]}];
            if (![tempWordSizeArray containsObject:[NSValue valueWithCGSize:currentSize]]) {
                [tempWordSizeArray addObject:[NSValue valueWithCGSize:currentSize]];
            }
            
            CGFloat currentLength = currentSize.width;
            
            if (currentLength > maxLength) {
                maxLength = currentLength;
                maxLengthText = text;
            }else if (currentLength < minLength) {
                minLength = currentLength;
                minLengthText = text;
            }

            ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
//            @property (nonatomic, strong) NSString      *wordText;
//            @property (nonatomic, strong) UIFont        *wordFont;
//            @property (nonatomic, strong) UIColor       *wordColor;
//            @property (nonatomic, assign) CGSize        wordSize;
//            
//            @property (nonatomic, assign) CGRect        currentRect;
//            @property (nonatomic, assign) CGFloat       currentAngle;
//            @property (nonatomic, assign) CGPathRef     currentPath;
            
            [tempLabelContainerArray addObject:container];
        }
        
      
    }
    
    
    self.labelContainerArray = [NSMutableArray arrayWithArray:tempLabelContainerArray];
    self.wordSizeArray = [NSMutableArray arrayWithArray:tempWordSizeArray];
}

/**
 分辨可绘制和不可绘制点

 @param bgImage bgImage description
 */
- (void)identifyWhiteAndBlackPointsWithImage:(UIImage *)bgImage
{
    NSMutableArray *tempWhitePointsArray = [NSMutableArray array];
    NSMutableArray *tempBlackPointsArray = [NSMutableArray array];
    
    CGImageRef cgimage = [bgImage CGImage];
    
    size_t width = CGImageGetWidth(cgimage);//图片宽度
    size_t height = CGImageGetHeight(cgimage);//图片高度
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));//取图片首地址
    size_t bitsPerComponent = 8;// r g b a 每个component bits数目
    size_t bytesPerRow = width * 4;//一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();//创建rgb颜色空间
    
    CGContextRef context = CGBitmapContextCreate(data,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 space,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    
    for (size_t i = 0; i < height; i++){
        for (size_t j = 0; j < width; j++){
            size_t pixelIndex = i * width * 4 + j * 4;
            
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            unsigned char alpha = data[pixelIndex + 3];
            
            //临界值为128 [可以修改像素值]
            CGFloat tone = red + green + blue;
            
            if (alpha < 128 || tone > 128 * 3) {
                // Area not to draw
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 0;
                
                [tempWhitePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(j, i)]];
            } else {
                // Area to draw
//                data[i] = data[i + 1] = data[i + 2] = 0;
//                data[i + 3] = 255;
                
                [tempBlackPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(j, i)]];
            }
        
        }
    }
    
//    cgimage = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
    self.whitePointsArray = [NSArray arrayWithArray:tempWhitePointsArray];
    self.blackPointsArray = [NSArray arrayWithArray:tempBlackPointsArray];
}

- (BOOL)canUseCenterPoint:(CGPoint)center
{
    __block BOOL canUse = YES;
    
    //是否在已占用区域
    [self.occupiedPathsArray enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPathRef path = obj.CGPath;
        
        if (CGPathContainsPoint(path, nil, center, NO)) {
            canUse = NO;
            *stop = YES;
        }
    }];
    
    return canUse;
}

//随机生成临时标签容器
- (ALWWordCloudLabelContainer *)randomCurrentWordCloudContainerWithCenterPoint:(CGPoint)center
{
    ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
    
    return container;
}

- (BOOL)canUseWordCloudLabelContainer:(ALWWordCloudLabelContainer *)container
{
    BOOL canUse = NO;
    
    return canUse;
}

@end
