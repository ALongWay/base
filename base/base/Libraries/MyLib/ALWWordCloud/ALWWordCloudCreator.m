//
//  ALWWordCloudCreator.m
//  base
//
//  Created by 李松 on 2016/12/28.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "ALWWordCloudCreator.h"

#pragma mark - ALWWordCloudLabelContainer
@interface ALWWordCloudLabelContainer : NSObject

@property (nonatomic, strong) NSString      *wordText;
@property (nonatomic, strong) UIFont        *wordFont;
@property (nonatomic, strong) UIColor       *wordColor;

/**
 包裹内容的容器size
 */
@property (nonatomic, assign) CGSize        wordSize;

//实际显示用的属性
@property (nonatomic, assign) CGRect        originalRect;//偏转前的rect
@property (nonatomic, assign) double        rotationAngle;//偏转角度

@property (nonatomic, assign) CGRect        showRect;//有倾斜角度时候，可忽视

@property (nonatomic, strong) NSArray<NSValue*>     *drawPointsArray;//绘制占用的点

@end

@implementation ALWWordCloudLabelContainer

@end

#pragma mark - ALWWordCloudShowContainer
//记录不重复container的对象
@interface ALWWordCloudShowContainer : NSObject

@property (nonatomic, assign) CGSize        wordSize;
@property (nonatomic, assign) double        rotationAngle;

@property (nonatomic, strong) NSMutableArray<ALWWordCloudLabelContainer*>   *labelContainerArray;

@end

@implementation ALWWordCloudShowContainer

@end

#pragma mark - ALWWordCloudCreator
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

/**
 保留全部可能的labelcontainer对象
 */
@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *labelContainerArray;

/**
 去除重复后，可显示的labelContainer对象根据size和angle分组后的对象数组
 */
@property (nonatomic, strong) NSArray<ALWWordCloudShowContainer*>   *showContainerArray;

//记录平面坐标点是否可用于绘制,key为point的string，value为1，0
@property (nonatomic, strong) NSMutableDictionary   *pointsStatusDic;

//初始时候，区分可绘制和不可绘制点数组
@property (nonatomic, strong) NSArray<NSValue*>     *noDrawPointsArray;//不可绘制点
@property (nonatomic, strong) NSArray<NSValue*>     *canDrawPointsArray;//可绘制点

@end

@implementation ALWWordCloudCreator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化变量
        self.wordMaxFontSize = 16;
        self.wordMinFontSize = 2;
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
                                [UIColor brownColor],
                                [UIColor blackColor]
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
        
        self.wordTextArray = @[@"字体云",
                               @"2017"
                               ];
        
        self.wordKeyTextArray = @[@"字体云",
                                  @"2017"
                                  ];
        
        //目前先支持水平和垂直方向
        //正弧度值表示逆时针旋转，负弧度值表示顺时针旋转
        self.wordAngleArray = @[@(0), @(0), @(M_PI_2), @(-M_PI_2)];
//        self.wordAngleArray = @[@(0), @(0), @(M_PI_2), @(-M_PI_2), @(M_PI_4), @(-M_PI_4), @(M_PI / 6.0), @(-M_PI / 6.0), @(M_PI / 3), @(-M_PI / 3)];
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
    
//    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:_bgView.frame];
//    [newImageView setBackgroundColor:[UIColor clearColor]];
//    [newImageView setImage:currentImage];
//    [_bgView addSubview:newImageView];

    NSLog(@"计时开始！");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self identifyWhiteAndBlackPointsWithImage:currentImage];
        
        [self generatePossibleLabelContainerArray];
        
        //先随机显示重要的关键词
//        [self randomShowKeyTextContainers];
        
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
 分辨可绘制和不可绘制点
 
 @param bgImage bgImage description
 */
- (UIImage *)identifyWhiteAndBlackPointsWithImage:(UIImage *)bgImage
{
    NSMutableArray *tempNoDrawPointsArray = [NSMutableArray array];
    NSMutableArray *tempCanDrawPointsArray = [NSMutableArray array];
    NSMutableDictionary *tempPointsStatusDic = [NSMutableDictionary dictionary];
    
    CGImageRef cgimage = [bgImage CGImage];
    
    size_t width = CGImageGetWidth(cgimage);//图片宽度
    size_t height = CGImageGetHeight(cgimage);//图片高度
    size_t dataLength = width * height * 4;
    unsigned char *data = calloc(dataLength, sizeof(unsigned char));//取图片首地址
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
                //修改像素值，有待进一步处理
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 255;//不透明
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    CGPoint point = CGPointMake(j / 2, i / 2);
                    
                    [tempNoDrawPointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsStatusDic setObject:@(NO) forKey:NSStringFromCGPoint(point)];
                }
            } else {
                // Area to draw
                //修改像素值
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 255;
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    CGPoint point = CGPointMake(j / 2, i / 2);
                    
                    [tempCanDrawPointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsStatusDic setObject:@(YES) forKey:NSStringFromCGPoint(point)];
                }
            }
        }
    }
    
    self.noDrawPointsArray = [NSArray arrayWithArray:tempNoDrawPointsArray];
    self.canDrawPointsArray = [NSArray arrayWithArray:tempCanDrawPointsArray];
    self.pointsStatusDic = tempPointsStatusDic;
    
    //生成新的图像
//    size_t bitsPerPixel = bitsPerComponent * 4;
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
//
//    cgimage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, kCGImageAlphaLast | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
//
//    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
//    
//    return newImage;
    
    return nil;
}

- (UIFont *)getCurrentShowFontWithFontSize:(CGFloat)fontSize
{
    UIFont *showFont = [UIFont systemFontOfSize:fontSize];
    
    return showFont;
}


/**
 生成可能的标签对象
 */
- (void)generatePossibleLabelContainerArray
{
    NSMutableArray<ALWWordCloudLabelContainer*> *tempLabelContainerArray = [NSMutableArray array];
    NSMutableArray<ALWWordCloudShowContainer*> *tempShowContainerArray = [NSMutableArray array];
    
    for (NSString *text in _wordTextArray) {
        for (NSNumber *fontValue in _wordFontSizeArray) {
            NSInteger fontSize = [fontValue integerValue];
            UIFont *currentFont = [self getCurrentShowFontWithFontSize:fontSize];
            CGSize currentSize = [text sizeWithAttributes:@{NSFontAttributeName : currentFont}];
            
            for (NSNumber *value in _wordAngleArray) {
                double angle = [value doubleValue];
                
                ALWWordCloudLabelContainer *labelContainer = [[ALWWordCloudLabelContainer alloc] init];
                labelContainer.wordText = text;
                labelContainer.wordFont = currentFont;
                
                labelContainer.wordSize = currentSize;
                labelContainer.rotationAngle = angle;//偏转角度

                //记录全部container
                [tempLabelContainerArray addObject:labelContainer];
                
                //记录不重复的showContainer对象(size和角度不完全一样)
                BOOL isExist = NO;
                ALWWordCloudShowContainer *existShowContainer;
                
                for (int i = 0; i < tempShowContainerArray.count; i++) {
                    ALWWordCloudShowContainer *showContainer = tempShowContainerArray[i];
                    
                    if (CGSizeEqualToSize(showContainer.wordSize, labelContainer.wordSize)
                        && showContainer.rotationAngle == labelContainer.rotationAngle) {
                        //重复的showContainer
                        existShowContainer = showContainer;
                        
                        isExist = YES;
                        break;
                    }
                }
                
                if (isExist) {
                    //将labelContainer加入showContainer的分组数组中
                    [existShowContainer.labelContainerArray addObject:labelContainer];
                } else {
                    //新建showContainer
                    existShowContainer = [[ALWWordCloudShowContainer alloc] init];
                    existShowContainer.wordSize = labelContainer.wordSize;
                    existShowContainer.rotationAngle = labelContainer.rotationAngle;
                    
                    existShowContainer.labelContainerArray = [NSMutableArray arrayWithObject:labelContainer];
                    
                    [tempShowContainerArray addObject:existShowContainer];
                }
            }
        }
    }
    
    self.labelContainerArray = [NSMutableArray arrayWithArray:tempLabelContainerArray];
    self.showContainerArray = [NSMutableArray arrayWithArray:tempShowContainerArray];
}

/**
 逐点扫描的算法
 */
- (void)scanPointsOneByOne
{
    for (int y = 0; y < _bgView.frame.size.height; y++) {
        for (int x = 0; x < _bgView.frame.size.width; x++) {
            CGPoint originPoint = CGPointMake(x, y);
            
            if (![self canUsePoint:originPoint]) {
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *labelContainer = [self randomCurrentWordCloudLabelContainerWithOriginPoint:originPoint];
            if (labelContainer) {
                //绘制标签
                [self drawLabelContainerWithContainer:labelContainer];
                
                if ([self isVerticalAngle:labelContainer.rotationAngle]) {
                    x = CGRectGetMaxX(labelContainer.showRect) + 1;
                } else if ([self isHorizontalAngle:labelContainer.rotationAngle]) {
                    x = CGRectGetMaxX(labelContainer.showRect) + _wordMinInset;
                }else{
                    x += _wordMinInset;
                }
            }
        }
        
        y += _wordMinInset;
    }
}

/**
 绘制标签，内部将标记占用的点
 
 @param showContainer showContainer description
 */
- (void)drawLabelContainerWithContainer:(ALWWordCloudLabelContainer *)labelContainer
{
    //标记占用的点
    [self markPointsAsOccupiedWithPointsArray:labelContainer.drawPointsArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:labelContainer.originalRect];
        
        if (![self isHorizontalAngle:labelContainer.rotationAngle]) {
            wordLabel.transform = CGAffineTransformMakeRotation(labelContainer.rotationAngle);
        }
        
        [wordLabel setText:labelContainer.wordText];
        [wordLabel setTextColor:labelContainer.wordColor];
        [wordLabel setFont:labelContainer.wordFont];
        [_bgView addSubview:wordLabel];
    });
}


/**
 得到区域内的点数组
 
 @param origin origin description
 @param wordSize wordSize description
 @param rotationAngle rotationAngle description
 @return return value description
 */
- (NSArray<NSValue*> *)getRegionPointsWithOrigin:(CGPoint)origin wordSize:(CGSize)wordSize rotationAngle:(double)rotationAngle
{
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    if ([self isHorizontalAngle:rotationAngle]) {
        for (int y = origin.y; y < origin.y + wordSize.height; y++) {
            for (int x = origin.x; x < origin.x + wordSize.width; x++) {
                CGPoint currentPoint = CGPointMake(x, y);
                
                [pointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];
            }
        }
    } else if ([self isVerticalAngle:rotationAngle]) {
        for (int y = origin.y; y < origin.y + wordSize.width; y++) {
            for (int x = origin.x; x < origin.x + wordSize.height; x++) {
                CGPoint currentPoint = CGPointMake(x, y);
                
                [pointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];
            }
        }
    } else {
        //其他偏转角度，先计算水平时候点
        NSMutableArray *tempPointsArray = [NSMutableArray array];
        
        for (int y = origin.y; y < origin.y + wordSize.height; y++) {
            for (int x = origin.x; x < origin.x + wordSize.width; x++) {
                CGPoint currentPoint = CGPointMake(x, y);
                
                [tempPointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];
            }
        }
        
        //对全部点做二维旋转矩阵运算
        for (NSValue *value in tempPointsArray) {
            CGPoint originalPoint = [value CGPointValue];
            
            CGPoint drawPoint = [self get2DRotationMatrixPointWithOriginalPoint:originalPoint rotationAngle:rotationAngle centerPoint:origin];
            
            [pointsArray addObject:[NSValue valueWithCGPoint:drawPoint]];
        }
    }
    
    return pointsArray;
}

/**
 如果倾斜角度非水平或者垂直，需要使用二维旋转矩阵，如下：
 (x, y)表示旋转前的点坐标，(x', y')表示旋转后的点坐标，(Cx, Cy)表示围绕旋转的中心点，θ表示旋转角，逆时针为正
 
 x' = x*cosθ - y*sinθ + Cx*(1 - cosθ) + Cy*sinθ];
 y' = x*sinθ + y*cosθ + Cy*(1 - cosθ) - Cx*sinθ];

 @param point point description
 @param center center description
 @return return value description
 */
- (CGPoint)get2DRotationMatrixPointWithOriginalPoint:(CGPoint)point rotationAngle:(double)rotationAngle centerPoint:(CGPoint)center
{
    //屏幕坐标系和平面几何坐标系有区别，取负角度纠正
    double angle = -rotationAngle;
    
    CGPoint newPoint = point;
    
    newPoint.x = point.x * cos(angle) - point.y * sin(angle) + center.x * (1 - cos(angle)) + center.y * sin(angle);
    newPoint.y = point.x * sin(angle) + point.y * cos(angle) + center.x * (1 - cos(angle)) - center.y * sin(angle);
    
    return newPoint;
}

- (void)markRectAsOccupiedWithRect:(CGRect)rect
{
    for (int y = rect.origin.y; y < CGRectGetMaxY(rect); y++) {
        for (int x = rect.origin.x; x < CGRectGetMaxX(rect); x++) {
            CGPoint currentPoint = CGPointMake(x, y);
            [_pointsStatusDic setObject:@(NO) forKey:NSStringFromCGPoint(currentPoint)];
        }
    }
}

/**
 标记占用的点
 
 @param pointsArray pointsArray description
 */
- (void)markPointsAsOccupiedWithPointsArray:(NSArray<NSValue*> *)pointsArray
{
    [pointsArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint currentPoint = [obj CGPointValue];
        [_pointsStatusDic setObject:@(NO) forKey:NSStringFromCGPoint(currentPoint)];
    }];
}

#pragma mark -- 随机算法
/**
 根据origin点尝试返回可绘制的标签对象，失败则为nil

 @param origin origin description
 @return return value description
 */
- (ALWWordCloudLabelContainer *)randomCurrentWordCloudLabelContainerWithOriginPoint:(CGPoint)origin
{
    NSMutableArray *mutShowContainerArray = [NSMutableArray arrayWithArray:_showContainerArray];
    
    while (mutShowContainerArray.count > 0) {
        NSInteger randomIndex = arc4random() % mutShowContainerArray.count;
        ALWWordCloudShowContainer *showContainer = mutShowContainerArray[randomIndex];
        
        NSArray *regionPointsArray;
        
        if ([self isVerticalAngle:showContainer.rotationAngle]) {
            CGRect showRect = CGRectMake(origin.x, origin.y, showContainer.wordSize.height, showContainer.wordSize.width);
            
            if (![self canUseRectAsDrawRect:showRect]) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        } else if ([self isHorizontalAngle:showContainer.rotationAngle]) {
            CGRect showRect = CGRectMake(origin.x, origin.y, showContainer.wordSize.width, showContainer.wordSize.height);
            
            if (![self canUseRectAsDrawRect:showRect]) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        } else {
            regionPointsArray = [self getRegionPointsWithOrigin:origin wordSize:showContainer.wordSize rotationAngle:showContainer.rotationAngle];
            
            if (![self canUseRegionWithPointsArray:regionPointsArray]) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        }
        
        //可以使用该size显示
        //生成显示用标签属性配置对象
        NSInteger randomContainerIndex = arc4random() % showContainer.labelContainerArray.count;
        ALWWordCloudLabelContainer *randomContainer = showContainer.labelContainerArray[randomContainerIndex];
        
        ALWWordCloudLabelContainer *labelContainer = [[ALWWordCloudLabelContainer alloc] init];
        labelContainer.wordText = randomContainer.wordText;
        labelContainer.wordFont = randomContainer.wordFont;
        
        //随机颜色
        NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
        labelContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
        
        labelContainer.wordSize = randomContainer.wordSize;
        labelContainer.rotationAngle = randomContainer.rotationAngle;
        
        //保留占用的点数组
        if (!regionPointsArray) {
            regionPointsArray = [self getRegionPointsWithOrigin:origin wordSize:showContainer.wordSize rotationAngle:showContainer.rotationAngle];
        }

        labelContainer.drawPointsArray = regionPointsArray;
        
        //如果是水平和垂直方向，记录显示用的rect，并反向推算原始rect
        if ([self isVerticalAngle:labelContainer.rotationAngle]) {
            labelContainer.showRect = CGRectMake(origin.x, origin.y, randomContainer.wordSize.height, randomContainer.wordSize.width);
            
            CGPoint center = CGPointMake(origin.x + randomContainer.wordSize.height / 2.0, origin.y + randomContainer.wordSize.width / 2.0);

            labelContainer.originalRect = CGRectMake(center.x - randomContainer.wordSize.width / 2.0, center.y - randomContainer.wordSize.height / 2.0, randomContainer.wordSize.width, randomContainer.wordSize.height);
        } else if ([self isHorizontalAngle:labelContainer.rotationAngle]) {
            labelContainer.showRect = CGRectMake(origin.x, origin.y, randomContainer.wordSize.width, randomContainer.wordSize.height);
            labelContainer.originalRect = randomContainer.showRect;
        } else{
            labelContainer.originalRect = CGRectMake(origin.x, origin.y, randomContainer.wordSize.width, randomContainer.wordSize.height);
            
            //其他角度，showRect可以忽视
            labelContainer.showRect = randomContainer.originalRect;
        }
        
        [mutShowContainerArray removeAllObjects];
        mutShowContainerArray = nil;
        return labelContainer;
        break;
    }
    
    return nil;
}

///**
// 随机显示醒目的关键字
// */
//- (void)randomShowKeyTextContainers
//{
//    for (NSString *keyText in _wordKeyTextArray) {
//        //随机较大的几个字尺寸
//        NSInteger randomIndex = _wordFontSizeArray.count - 1 - arc4random() % 2;
//        NSInteger fontSize = [_wordFontSizeArray[randomIndex] integerValue];
//        UIFont *textFont = [self getCurrentShowFontWithFontSize:fontSize];
//        CGSize originalSize = [keyText sizeWithAttributes:@{NSFontAttributeName : textFont}];
//        
//        randomIndex = arc4random() % _wordAngleArray.count;
//        CGSize showSize = originalSize;
//        double angle = [_wordAngleArray[randomIndex] doubleValue];
//        if ([self isVerticalAngle:angle]) {
//            showSize = CGSizeMake(originalSize.height, originalSize.width);
//        }
//        
//        NSMutableArray *mutCanDrawPointsArray = [NSMutableArray arrayWithArray:_canDrawPointsArray];
//        
//        for (int i = 0; i < mutCanDrawPointsArray.count; i++) {
//            randomIndex = arc4random() % _canDrawPointsArray.count;
//            CGPoint origin = [mutCanDrawPointsArray[randomIndex] CGPointValue];
//            
//            CGRect showRect = CGRectMake(origin.x, origin.y, showSize.width, showSize.height);
//            
//            if (![self canUseRectAsShowRect:showRect]) {
//                [mutCanDrawPointsArray removeObjectAtIndex:randomIndex];
//                continue;
//            }
//            
//            ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
//            tempContainer.wordText = keyText;
//            tempContainer.wordFont = textFont;
//            tempContainer.currentAngle = angle;
//            
//            //反向推算圆心和原始rect
//            tempContainer.currentRect = showRect;
//            
//            tempContainer.currentCenter = CGPointMake(origin.x + showRect.size.width / 2.0, origin.y + showRect.size.height / 2.0);
//            
//            //计算未旋转时候的rect
//            CGRect originRect = CGRectMake(0, 0, originalSize.width, originalSize.height);
//            
//            if ([self isVerticalAngle:angle]) {
//                originRect.origin = CGPointMake(tempContainer.currentCenter.x - tempContainer.currentRect.size.height / 2.0, tempContainer.currentCenter.y - tempContainer.currentRect.size.width / 2.0);
//            }else{
//                originRect.origin = origin;
//            }
//            
//            tempContainer.originalRect = originRect;
//            
//            //随机颜色
//            NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
//            tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
//            
//            [self drawLabelContainerWithContainer:tempContainer];
//            
//            break;
//        }
//    }
//}

#pragma mark -- 判断算法
- (BOOL)isVerticalAngle:(double)angle
{
    if (angle == M_PI_2
        || angle == -M_PI_2) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isHorizontalAngle:(double)angle
{
    if (angle == 0
        || angle == M_PI
        || angle == -M_PI) {
        return YES;
    }
    
    return NO;
}

- (BOOL)canUsePoint:(CGPoint)point
{
    return [[_pointsStatusDic objectForKey:NSStringFromCGPoint(point)] boolValue];
}

- (BOOL)canUseRectAsDrawRect:(CGRect)rect
{
    BOOL canUse = YES;
    
    if (CGRectGetMinX(rect) < 0
        || CGRectGetMinY(rect) < 0
        || CGRectGetMaxX(rect) > _bgView.frame.size.width
        || CGRectGetMaxY(rect) > _bgView.frame.size.height) {
        return NO;
    }
    
    for (int y = rect.origin.y; y < CGRectGetMaxY(rect); y++) {
        for (int x = rect.origin.x; x < CGRectGetMaxX(rect); x++) {
            CGPoint currentPoint = CGPointMake(x, y);
            
            canUse = [self canUsePoint:currentPoint];
            
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
 判断区域是否可绘制

 @param pointsArray pointsArray description
 @return return value description
 */
- (BOOL)canUseRegionWithPointsArray:(NSArray<NSValue*> *)pointsArray
{
    __block BOOL canUse = YES;
    
    [pointsArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint currentPoint = [obj CGPointValue];
        
        if (![self canUsePoint:currentPoint]) {
            canUse = NO;
            *stop = YES;
        }
    }];
    
    return canUse;
}

@end
