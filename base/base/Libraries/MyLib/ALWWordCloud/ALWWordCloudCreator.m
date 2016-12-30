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

@property (nonatomic, assign) CGRect        originalRect;//偏转前的rect

//实际显示用的属性
@property (nonatomic, assign) CGPoint       currentCenter;//包围矩形边框的外接圆圆心
@property (nonatomic, assign) CGRect        currentRect;//偏转后的rect
@property (nonatomic, assign) CGFloat       currentRadius;//包围矩形边框的外接圆半径
@property (nonatomic, assign) double        currentAngle;//偏转角度
//@property (nonatomic, assign) CGPathRef     currentPath;//偏转后实际的path

@end

@implementation ALWWordCloudLabelContainer


@end

#pragma mark -
@interface ALWWordCloudCreator ()

@property (nonatomic, strong) UIView        *bgView;

//字体可配置相关属性
@property (nonatomic, assign) CGFloat       wordMaxFontSize;
@property (nonatomic, assign) CGFloat       wordMinFontSize;
@property (nonatomic, assign) CGFloat       wordFontStepValue;
@property (nonatomic, assign) CGFloat       wordMinInset;

@property (nonatomic, strong) NSArray<NSNumber*>    *wordFontSizeArray;
@property (nonatomic, strong) NSArray<UIColor*>     *wordColorArray;
@property (nonatomic, strong) NSArray<NSString*>    *wordTextArray;
@property (nonatomic, strong) NSArray<NSString*>    *wordKeyTextArray;
@property (nonatomic, strong) NSArray<NSNumber*>    *wordAngleArray;

//计算相关属性
@property (nonatomic, strong) NSArray<NSNumber*>    *wordCircleRadiusArray;//去掉了重复的外接圆半径
@property (nonatomic, strong) NSArray<NSValue*>     *wordShowSizeArray;//去掉重复的标签显示size
//保留全部可能的labelcontainer对象
@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *labelContainerArray;

//记录平面坐标点是否可用于绘制,key为point的string，value为1，0
@property (nonatomic, strong) NSMutableDictionary   *pointsDic;
@property (nonatomic, strong) NSArray<NSValue*>     *whitePointsArray;//不可绘制点
@property (nonatomic, strong) NSArray<NSValue*>     *blackPointsArray;//可绘制点

@end

@implementation ALWWordCloudCreator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化变量
        self.wordMaxFontSize = 14;
        self.wordMinFontSize = 3;
        self.wordFontStepValue = 2;
        self.wordMinInset = 3;
        
        NSMutableArray *fontSizeArray = [NSMutableArray array];
        for (int i = _wordMinFontSize; i <= _wordMaxFontSize; ) {
            [fontSizeArray addObject:@(i)];
            
            i += _wordFontStepValue;
            
            if (i > _wordMaxFontSize && i - _wordMaxFontSize < _wordFontStepValue) {
                i = _wordMaxFontSize;
            }
        }
        self.wordFontSizeArray = [NSArray arrayWithArray:fontSizeArray];
        
        self.wordColorArray = @[[UIColor redColor],
                                [UIColor greenColor],
                                [UIColor grayColor],
                                [UIColor yellowColor]
                                ];
//        self.wordTextArray = @[@"测试",
//                               @"haha",
//                               @"额",
//                               @"试一试seee",
//                               @"什么龟ccc",
//                               @"字体云ee",
//                               @"效果bbb",
//                               @"不知道ee",
//                               @"PHPqqq",
//                               @"JSxxx",
//                               @"Objective-C",
//                               @"Java",
//                               @"C++",
//                               @"Go",
//                               @"Nodejs",
//                               @"C#",
//                               @"iOS"
//                               ];
        
        self.wordTextArray = @[@"2017"
                               ];
        
        self.wordKeyTextArray = @[@"字体云",
                               @"2017"
                               ];
        
        //目前先支持水平和垂直方向
        self.wordAngleArray = @[@(0), @(M_PI), @(M_PI_2), @(-M_PI_2)];
    }
    
    return self;
}

#pragma mark -- Getter/Setter


#pragma mark -- Public methods
- (UIView *)createWordCloudViewWithImageView:(UIImageView *)imageView completionBlock:(void (^)())completion
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [_bgView setBackgroundColor:[UIColor clearColor]];
    
    UIImage *currentImage = imageView.image;
    
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:_bgView.frame];
    [newImageView setBackgroundColor:[UIColor clearColor]];
    [newImageView setImage:currentImage];
    [_bgView addSubview:newImageView];

    NSLog(@"计时开始！");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self identifyWhiteAndBlackPointsWithImage:currentImage];
        
        [self generatePossibleLabelContainerArray];
        
        //先随机显示重要的关键词
        [self randomShowKeyTextContainers];
        
        //扫描坐标点
        [self scanPointsOneByOne];
        
        NSLog(@"计时结束！");

        if (completion) {
            completion();
        }
    });
    
    return _bgView;
}

#pragma mark -- Private methods

/**
 绘制标签，内部将标记占用的点

 @param showContainer showContainer description
 */
- (void)drawLabelContainerWithContainer:(ALWWordCloudLabelContainer *)showContainer
{
    //标记占用的点
    [self markRectAsOccupiedRect:showContainer.currentRect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:showContainer.originalRect];
        
        if (showContainer.currentAngle != 0) {
            wordLabel.transform = CGAffineTransformMakeRotation(showContainer.currentAngle);
        }
        
        [wordLabel setText:showContainer.wordText];
        [wordLabel setTextColor:showContainer.wordColor];
        [wordLabel setFont:showContainer.wordFont];
        [_bgView addSubview:wordLabel];
    });
}

/**
 分辨可绘制和不可绘制点
 
 @param bgImage bgImage description
 */
- (UIImage *)identifyWhiteAndBlackPointsWithImage:(UIImage *)bgImage
{
    NSMutableArray *tempWhitePointsArray = [NSMutableArray array];
    NSMutableArray *tempBlackPointsArray = [NSMutableArray array];
    NSMutableDictionary *tempPointsDic = [NSMutableDictionary dictionary];
    
    CGImageRef cgimage = [bgImage CGImage];
    
    size_t width = CGImageGetWidth(cgimage);//图片宽度
    size_t height = CGImageGetHeight(cgimage);//图片高度
    size_t dataLength = width * height * 4;
    unsigned char *data = calloc(dataLength, sizeof(unsigned char));//取图片首地址
    size_t bitsPerComponent = 8;// r g b a 每个component bits数目
    size_t bitsPerPixel = bitsPerComponent * 4;
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
                //修改像素值
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 255;//不透明
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    CGPoint point = CGPointMake(j / 2, i / 2);
                    
                    [tempWhitePointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsDic setObject:@(NO) forKey:NSStringFromCGPoint(point)];
                }
            } else {
                // Area to draw
                //修改像素值
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 255;
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    CGPoint point = CGPointMake(j / 2, i / 2);
                    
                    [tempBlackPointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsDic setObject:@(YES) forKey:NSStringFromCGPoint(point)];
                }
            }
        }
    }
    
    self.whitePointsArray = [NSArray arrayWithArray:tempWhitePointsArray];
    self.blackPointsArray = [NSArray arrayWithArray:tempBlackPointsArray];
    self.pointsDic = tempPointsDic;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);

    cgimage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, kCGImageAlphaLast | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);

    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
    return newImage;
}

- (UIFont *)getCurrentShowFontWithFontSize:(CGFloat)fontSize
{
    UIFont *showFont = [UIFont systemFontOfSize:fontSize];
    
    return showFont;
}

- (void)generatePossibleLabelContainerArray
{
    NSMutableArray *tempLabelContainerArray = [NSMutableArray array];
    NSMutableArray *tempWordCircleRadiusArray = [NSMutableArray array];
    NSMutableArray *tempWordShowSizeArray = [NSMutableArray array];
    
    for (NSString *text in self.wordTextArray) {
        for (NSNumber *fontValue in _wordFontSizeArray) {
            NSInteger fontSize = [fontValue integerValue];
            UIFont *currentFont = [self getCurrentShowFontWithFontSize:fontSize];
            CGSize currentSize = [text sizeWithAttributes:@{NSFontAttributeName : currentFont}];
            CGFloat currentRadius = sqrtf(powf(currentSize.width, 2) + powf(currentSize.height, 2)) / 2.0;
            
            if (![tempWordCircleRadiusArray containsObject:@(currentRadius)]) {
                if (tempWordCircleRadiusArray.count) {
                    //不重复的半径从小到大排序
                    for (int i = 0; i < tempWordCircleRadiusArray.count; i++) {
                        CGFloat tempRadius = [tempWordCircleRadiusArray[i] floatValue];
                        
                        if (currentRadius < tempRadius) {
                            [tempWordCircleRadiusArray insertObject:@(currentRadius) atIndex:MAX(i - 1, 0)];
                            break;
                        } else if (currentRadius > tempRadius){
                            if (i == tempWordCircleRadiusArray.count - 1) {
                                [tempWordCircleRadiusArray addObject:@(currentRadius)];
                            }
                        }
                    }
                } else {
                    [tempWordCircleRadiusArray addObject:@(currentRadius)];
                }
            }
            
            for (NSNumber *value in self.wordAngleArray) {
                double angle = [value doubleValue];
                
                ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
                container.wordText = text;
                container.wordFont = currentFont;
                
                container.originalRect = CGRectMake(0, 0, currentSize.width, currentSize.height);
                
                container.currentRadius = sqrtf(powf(currentSize.width, 2) + powf(currentSize.height, 2)) / 2.0;//包围矩形边框的外接圆半径
                container.currentAngle = angle;//偏转角度
                
                if ([self isVerticalAngle:angle]) {
                    container.currentRect = CGRectMake(0, 0, currentSize.height, currentSize.width);
                } else {
                    container.currentRect = container.originalRect;
                }
                
                //记录不重复的显示用size
                NSValue *showSizeValue = [NSValue valueWithCGSize:container.currentRect.size];
                if (![tempWordShowSizeArray containsObject:showSizeValue]) {
                    [tempWordShowSizeArray addObject:showSizeValue];
                }
                
                [tempLabelContainerArray addObject:container];
            }
        }
    }
    
    self.labelContainerArray = [NSMutableArray arrayWithArray:tempLabelContainerArray];
    self.wordCircleRadiusArray = [NSMutableArray arrayWithArray:tempWordCircleRadiusArray];
    self.wordShowSizeArray = [NSMutableArray arrayWithArray:tempWordShowSizeArray];
}


/**
 逐点扫描的算法
 */
- (void)scanPointsOneByOne
{
    for (int y = 0; y < _bgView.frame.size.height; y++) {
        for (int x = 0; x < _bgView.frame.size.width; x++) {
            CGPoint originPoint = CGPointMake(x, y);
            
            if (![[_pointsDic objectForKey:NSStringFromCGPoint(originPoint)] boolValue]) {
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithOriginPoint:originPoint];
            if (showContainer) {
                //绘制标签
                [self drawLabelContainerWithContainer:showContainer];
                
                x = CGRectGetMaxX(showContainer.currentRect) + 1;
                
                if (![self isVerticalAngle:showContainer.currentAngle]) {
                    x += _wordMinInset;
                }
            }
        }
        
        y += _wordMinInset;
    }
}

/**
 根据origin点尝试返回可绘制的标签对象，失败则为nil

 @param origin origin description
 @return return value description
 */
- (ALWWordCloudLabelContainer *)randomCurrentWordCloudContainerWithOriginPoint:(CGPoint)origin
{
    NSMutableArray *mutShowSizeArray = [NSMutableArray arrayWithArray:_wordShowSizeArray];
    
    while (mutShowSizeArray.count > 0) {
        NSInteger randomIndex = arc4random() % mutShowSizeArray.count;
        CGSize showSize = [mutShowSizeArray[randomIndex] CGSizeValue];
        CGRect showRect = CGRectMake(origin.x, origin.y, showSize.width, showSize.height);
        
        //判断临时的标签是否可以用于显示
        //是否超出了最大区域
        if (showRect.origin.x < 0
            || showRect.origin.y < 0
            || CGRectGetMaxX(showRect) > self.bgView.frame.size.width
            || CGRectGetMaxY(showRect) > self.bgView.frame.size.height) {
            [mutShowSizeArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //showRect区域内是否有不可用点，包括白点和已占用点
        if (![self canUseRectAsShowRect:showRect]) {
            [mutShowSizeArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //可以使用该size显示
        NSMutableArray *preselectedContainerArray = [NSMutableArray array];
        
        for (ALWWordCloudLabelContainer *temp in _labelContainerArray) {
            if (CGSizeEqualToSize(temp.currentRect.size, showRect.size)) {
                [preselectedContainerArray addObject:temp];
            }
        }
        
        //生成显示用标签属性配置对象
        NSInteger randomContainerIndex = arc4random() % preselectedContainerArray.count;
        ALWWordCloudLabelContainer *randomContainer = preselectedContainerArray[randomContainerIndex];
        
        ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
        tempContainer.wordText = randomContainer.wordText;
        tempContainer.wordFont = randomContainer.wordFont;
        
        tempContainer.originalRect = randomContainer.originalRect;
        tempContainer.currentRadius = randomContainer.currentRadius;
        tempContainer.currentAngle = randomContainer.currentAngle;
        tempContainer.currentRect = randomContainer.currentRect;
        
        //反向推算圆心和原始rect
        tempContainer.currentRect = showRect;
        
        tempContainer.currentCenter = CGPointMake(origin.x + showRect.size.width / 2.0, origin.y + showRect.size.height / 2.0);
        
        //计算未旋转时候的rect
        CGRect originRect = tempContainer.originalRect;
        
        if ([self isVerticalAngle:tempContainer.currentAngle]) {
            originRect.origin = CGPointMake(tempContainer.currentCenter.x - tempContainer.currentRect.size.height / 2.0, tempContainer.currentCenter.y - tempContainer.currentRect.size.width / 2.0);
        }else{
            originRect.origin = origin;
        }
        
        tempContainer.originalRect = originRect;

        //随机颜色
        NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
        tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
        
        return tempContainer;
        break;
    }
    
    return nil;
}

/**
 随机显示醒目的关键字
 */
- (void)randomShowKeyTextContainers
{
    for (NSString *keyText in _wordKeyTextArray) {
        //随机较大的几个字尺寸
        NSInteger randomIndex = _wordFontSizeArray.count - 1 - arc4random() % 2;
        NSInteger fontSize = [_wordFontSizeArray[randomIndex] integerValue];
        UIFont *textFont = [self getCurrentShowFontWithFontSize:fontSize];
        CGSize originalSize = [keyText sizeWithAttributes:@{NSFontAttributeName : textFont}];
        
        randomIndex = arc4random() % _wordAngleArray.count;
        CGSize showSize = originalSize;
        double angle = [_wordAngleArray[randomIndex] doubleValue];
        if ([self isVerticalAngle:angle]) {
            showSize = CGSizeMake(originalSize.height, originalSize.width);
        }
        
        NSMutableArray *mutBlackPointsArray = [NSMutableArray arrayWithArray:_blackPointsArray];
        
        for (int i = 0; i < mutBlackPointsArray.count; i++) {
            randomIndex = arc4random() % _blackPointsArray.count;
            CGPoint origin = [mutBlackPointsArray[randomIndex] CGPointValue];
            
            CGRect showRect = CGRectMake(origin.x, origin.y, showSize.width, showSize.height);
            
            if (![self canUseRectAsShowRect:showRect]) {
                [mutBlackPointsArray removeObjectAtIndex:randomIndex];
                continue;
            }
            
            ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
            tempContainer.wordText = keyText;
            tempContainer.wordFont = textFont;
            tempContainer.currentAngle = angle;
            
            //反向推算圆心和原始rect
            tempContainer.currentRect = showRect;
            
            tempContainer.currentCenter = CGPointMake(origin.x + showRect.size.width / 2.0, origin.y + showRect.size.height / 2.0);
            
            //计算未旋转时候的rect
            CGRect originRect = CGRectMake(0, 0, originalSize.width, originalSize.height);
            
            if ([self isVerticalAngle:angle]) {
                originRect.origin = CGPointMake(tempContainer.currentCenter.x - tempContainer.currentRect.size.height / 2.0, tempContainer.currentCenter.y - tempContainer.currentRect.size.width / 2.0);
            }else{
                originRect.origin = origin;
            }
            
            tempContainer.originalRect = originRect;
            
            //随机颜色
            NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
            tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
            
            [self drawLabelContainerWithContainer:tempContainer];
            
            break;
        }
    }
}

- (void)randomShowWordCloudContainerAroundRect:(CGRect)rect;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self randomShowWordCloudContainerOnRightWithRect:rect];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self randomShowWordCloudContainerOnBottomWithRect:rect];
    });
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        [self randomShowWordCloudContainerWithMaxX:CGRectGetMaxX(rect) + _wordMinInset];
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        [self randomShowWordCloudContainerWithMaxY:CGRectGetMaxY(rect) + _wordMinInset];
//    });
    
//    [self randomShowWordCloudContainerOnRightWithRect:rect];
//    [self randomShowWordCloudContainerOnBottomWithRect:rect];
//    [self randomShowWordCloudContainerWithMaxX:CGRectGetMaxX(rect) + _wordMinInset];
//    [self randomShowWordCloudContainerWithMaxY:CGRectGetMaxY(rect) + _wordMinInset];
}

- (void)randomShowWordCloudContainerOnRightWithRect:(CGRect)rect
{
    NSMutableArray *originYArray = [NSMutableArray array];
    
    for (int i = rect.origin.y; i < CGRectGetMaxY(rect); i++) {
        [originYArray addObject:@(i)];
    }
    
    while (originYArray.count) {
        NSInteger randomOriginYIndex = arc4random() % originYArray.count;
        NSInteger minOriginX = CGRectGetMaxX(rect);
        if (rect.size.width > rect.size.height) {
            minOriginX += _wordMinInset;
        }else{
            minOriginX += 1;
        }
        
        NSInteger currentOriginY = [originYArray[randomOriginYIndex] integerValue];
        CGPoint origin = CGPointMake(minOriginX, currentOriginY);
        
        if (![[_pointsDic objectForKey:NSStringFromCGPoint(origin)] boolValue]) {
            [originYArray removeObjectAtIndex:randomOriginYIndex];
            continue;
        }
        
        ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithOriginPoint:origin];
        if (showContainer) {
            //绘制标签
            [self drawLabelContainerWithContainer:showContainer];
        }
        
        [originYArray removeObjectAtIndex:randomOriginYIndex];
    }
}

- (void)randomShowWordCloudContainerOnBottomWithRect:(CGRect)rect
{
    NSMutableArray *originXArray = [NSMutableArray array];
    
    for (int i = rect.origin.x; i < CGRectGetMaxX(rect); i++) {
        [originXArray addObject:@(i)];
    }
    
    while (originXArray.count) {
        NSInteger randomOriginXIndex = arc4random() % originXArray.count;
        NSInteger currentOriginX = [originXArray[randomOriginXIndex] integerValue];
        NSInteger minOriginY = CGRectGetMaxY(rect);

        if (rect.size.height > rect.size.width) {
            minOriginY += _wordMinInset;
        }else{
            minOriginY += 1;
        }

        CGPoint origin = CGPointMake(currentOriginX, minOriginY);
        
        if (![[_pointsDic objectForKey:NSStringFromCGPoint(origin)] boolValue]) {
            [originXArray removeObjectAtIndex:randomOriginXIndex];
            continue;
        }
        
        ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithOriginPoint:origin];
        if (showContainer) {
            //绘制标签
            [self drawLabelContainerWithContainer:showContainer];
        }
        
        [originXArray removeObjectAtIndex:randomOriginXIndex];
    }
}

- (void)randomShowWordCloudContainerWithMaxX:(CGFloat)maxX
{
    
}

- (void)randomShowWordCloudContainerWithMaxY:(CGFloat)maxY
{
    
}

- (BOOL)isVerticalAngle:(double)angle
{
    if (angle == M_PI_2
        || angle == -M_PI_2) {
        return YES;
    }
    
    return NO;
}

/**
 判断区域是否可绘制

 @param rect rect description
 @return return value description
 */
- (BOOL)canUseRectAsShowRect:(CGRect)rect
{
    //扫描坐标点
    BOOL canUse = YES;
    
    for (int y = rect.origin.y; y < CGRectGetMaxY(rect); y++) {
        for (int x = rect.origin.x; x < CGRectGetMaxX(rect); x++) {
            CGPoint currentPoint = CGPointMake(x, y);
            
            canUse = [[_pointsDic objectForKey:NSStringFromCGPoint(currentPoint)] boolValue];
            
            if (!canUse) {
                break;
            }
        }
        
        if (!canUse) {
            break;
        }
    }
    
    return canUse;
}

/**
 标记占用的点

 @param rect rect description
 */
- (void)markRectAsOccupiedRect:(CGRect)rect
{
    for (int y = rect.origin.y; y < CGRectGetMaxY(rect); y++) {
        for (int x = rect.origin.x; x < CGRectGetMaxX(rect); x++) {
            CGPoint currentPoint = CGPointMake(x, y);
            [_pointsDic setObject:@(NO) forKey:NSStringFromCGPoint(currentPoint)];
        }
    }
}

@end
