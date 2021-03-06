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

//相对的初始origin为(0, 0)
@property (nonatomic, assign) CGRect        originalRect;//偏转前的rect

//实际显示用的属性
@property (nonatomic, assign) CGPoint       currentCenter;//包围矩形边框的外接圆圆心
@property (nonatomic, assign) CGRect        currentRect;//偏转后的rect
@property (nonatomic, assign) CGFloat       currentRadius;//包围矩形边框的外接圆半径
@property (nonatomic, assign) double        currentAngle;//偏转角度

@property (nonatomic, strong) NSArray<NSValue*>     *drawPointsArray;//绘制占用的点，主要用于倾斜容器

@end

@implementation ALWWordCloudLabelContainer


@end

#pragma mark - ALWWordCloudShowContainer
//记录不重复container的对象
@interface ALWWordCloudShowContainer : NSObject

@property (nonatomic, assign) CGSize        wordSize;
@property (nonatomic, assign) double        currentAngle;

@property (nonatomic, assign) CGPoint       rotationRectOffsetVector;

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
@property (nonatomic, strong) NSArray<NSNumber*>    *wordAngleArray;

@property (nonatomic, assign) CGSize        minSize;
@property (nonatomic, assign) CGSize        maxSize;

//------------
@property (nonatomic, strong) UIImageView           *keyWordView;
@property (nonatomic, strong) NSArray<NSString*>    *wordKeyTextArray;

@property (nonatomic, assign) CGSize        minKeySize;
@property (nonatomic, assign) CGSize        maxKeySize;

/**
 保留全部可能的labelcontainer对象
 */
@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *labelContainerArray;

/**
 去除重复后，可显示的labelContainer对象根据size和angle分组后的对象数组
 */
@property (nonatomic, strong) NSArray<ALWWordCloudShowContainer*>   *showContainerArray;

@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *keyLabelContainerArray;
@property (nonatomic, strong) NSArray<ALWWordCloudShowContainer*>   *keyShowContainerArray;

//记录平面坐标点是否可用于绘制,key为point的string，value为1，0
@property (nonatomic, strong) NSMutableDictionary   *pointsStatusDic;

@property (nonatomic, strong) NSArray<NSValue*>     *whitePointsArray;//不可绘制点
@property (nonatomic, strong) NSArray<NSValue*>     *blackPointsArray;//可绘制点

/**
 记录可以绘制到画布上的标签对象
 */
@property (nonatomic, strong) NSMutableArray<ALWWordCloudLabelContainer*>   *drawLabelContainerArray;

@end

@implementation ALWWordCloudCreator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化变量
        self.wordMaxFontSize = 40;
        self.wordMinFontSize = 5;
        self.wordFontStepValue = 5;
        
        NSMutableArray *fontSizeArray = [NSMutableArray array];
        for (int i = _wordMinFontSize; i <= _wordMaxFontSize; ) {
            [fontSizeArray addObject:@(i)];
            
            i += _wordFontStepValue;
            
            if (i > _wordMaxFontSize && i - _wordMaxFontSize < _wordFontStepValue) {
                i = _wordMaxFontSize;
            }
        }
        self.wordFontSizeArray = fontSizeArray;

        self.wordMinInset = 2;

        self.wordColorArray = @[COLOR(255, 120, 100),
//                                [UIColor greenColor],
//                                [UIColor grayColor],
//                                [UIColor brownColor],
//                                [UIColor blackColor]
                                ];
        
        self.wordTextArray = @[@"Happy",
                               @"New",
                               @"Year",
                               @"To",
                               @"You",
                               @"2017"
                               ];
        
        self.wordKeyTextArray = @[@"Happy",
                                  @"New",
                                  @"Year",
                                  @"2017"
                                  ];
        
        //目前先支持水平和垂直方向
        //目前，正弧度值表示顺时针旋转，负弧度值表示逆时针旋转
//        self.wordAngleArray = @[@(0), @(0), @(M_PI_2), @(-M_PI_2)];
        self.wordAngleArray = @[@(0), @(M_PI / 2.2), @(-M_PI / 2.2), @(M_PI / 2.6), @(-M_PI / 2.6), @(M_PI / 2.6), @(-M_PI / 2.6), @(M_PI / 3.0), @(-M_PI / 3.0), @(M_PI / 4.0), @(-M_PI / 4.0), @(M_PI / 4.5), @(-M_PI / 4.5), @(M_PI / 6.0), @(-M_PI / 6.0), @(M_PI / 9.0), @(-M_PI / 9.0), @(M_PI / 18.0), @(-M_PI / 18.0)];
        
//        self.wordAngleArray = @[@(-M_PI / 3.0)];
    }
    
    return self;
}

- (void)resetParameterWithMinFontSize:(NSInteger)minSize maxFontSize:(NSInteger)maxSize step:(NSInteger)step
{
    self.wordMaxFontSize = maxSize;
    self.wordMinFontSize = minSize;
    self.wordFontStepValue = step;
    
    NSMutableArray *fontSizeArray = [NSMutableArray array];
    for (int i = _wordMinFontSize; i <= _wordMaxFontSize; ) {
        [fontSizeArray addObject:@(i)];
        
        i += _wordFontStepValue;
        
        if (i > _wordMaxFontSize && i - _wordMaxFontSize < _wordFontStepValue) {
            i = _wordMaxFontSize;
        }
    }
    self.wordFontSizeArray = fontSizeArray;
}

#pragma mark -- Getter/Setter
- (NSMutableArray<ALWWordCloudLabelContainer *> *)drawLabelContainerArray
{
    if (!_drawLabelContainerArray) {
        _drawLabelContainerArray = [NSMutableArray array];
    }
    
    return _drawLabelContainerArray;
}

#pragma mark -- Public methods
- (UIView *)createWordCloudViewWithImageView:(UIImageView *)imageView completionBlock:(void (^)())completion
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [_bgView setBackgroundColor:[UIColor clearColor]];
    
    _keyWordView = [[UIImageView alloc] initWithFrame:imageView.frame];
    [_keyWordView setImage:imageView.image];
    
    UIImage *currentImage = imageView.image;
    
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:_bgView.frame];
    [newImageView setBackgroundColor:[UIColor clearColor]];
    [newImageView setImage:currentImage];
    [_bgView addSubview:newImageView];

    NSLog(@"计时开始！");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self identifyWhiteAndBlackPointsWithImage:currentImage];
        
        //---------
        [self resetParameterWithMinFontSize:40 maxFontSize:40 step:5];
        [self generatePossibleKeyLabelContainerArray];
        [self verticalRandomShowKeyTextContainers];

        //---------
        [self resetParameterWithMinFontSize:15 maxFontSize:20 step:1];
        [self generatePossibleKeyLabelContainerArray];
        [self verticalRandomShowKeyTextContainers];
        
        //重新扫描新的背景图
        [self identifyWhiteAndBlackPointsWithImage:[ImageHelper getSnapshotWithView:_keyWordView]];

        //---------
        [self resetParameterWithMinFontSize:10 maxFontSize:15 step:1];
        [self generatePossibleLabelContainerArray];
//        [self scanVerticalPointsOneByOne];
        [self verticalRandomShowKeyTextContainers];

        [self identifyWhiteAndBlackPointsWithImage:[ImageHelper getSnapshotWithView:_keyWordView]];

        //---------
        [self resetParameterWithMinFontSize:6 maxFontSize:10 step:1];
        [self generatePossibleLabelContainerArray];
        [self scanHorizontalPointsOneByOne];
        
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
    if ([self isHorizontalAngle:showContainer.currentAngle]
        || [self isVerticalAngle:showContainer.currentAngle]) {
        [self markRectAsOccupiedRect:showContainer.currentRect];
    } else {
        [self markPointsAsOccupiedWithPointsArray:showContainer.drawPointsArray];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:showContainer.originalRect];
        
        if (![self isHorizontalAngle:showContainer.currentAngle]) {
            wordLabel.transform = CGAffineTransformMakeRotation(showContainer.currentAngle);
        }
        
        [wordLabel setText:showContainer.wordText];
        [wordLabel setTextColor:showContainer.wordColor];
        [wordLabel setTextAlignment:NSTextAlignmentCenter];
        [wordLabel setFont:showContainer.wordFont];
        [_bgView addSubview:wordLabel];
    });
}

- (void)drawKeyLabelContainerWithContainer:(ALWWordCloudLabelContainer *)showContainer
{
    //标记占用的点
    if ([self isHorizontalAngle:showContainer.currentAngle]
        || [self isVerticalAngle:showContainer.currentAngle]) {
        [self markRectAsOccupiedRect:showContainer.currentRect];
    } else {
        [self markPointsAsOccupiedWithPointsArray:showContainer.drawPointsArray];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:showContainer.originalRect];
        
        if (![self isHorizontalAngle:showContainer.currentAngle]) {
            wordLabel.transform = CGAffineTransformMakeRotation(showContainer.currentAngle);
        }
        
        [wordLabel setText:showContainer.wordText];
        [wordLabel setTextColor:[UIColor whiteColor]];
        [wordLabel setTextAlignment:NSTextAlignmentCenter];
        [wordLabel setFont:showContainer.wordFont];
        [_keyWordView addSubview:wordLabel];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:showContainer.originalRect];
        
        if (![self isHorizontalAngle:showContainer.currentAngle]) {
            wordLabel.transform = CGAffineTransformMakeRotation(showContainer.currentAngle);
        }
        
        [wordLabel setText:showContainer.wordText];
        [wordLabel setTextColor:showContainer.wordColor];
        [wordLabel setTextAlignment:NSTextAlignmentCenter];
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
    NSInteger scale = width / _bgView.frame.size.width;
    
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
                
                if (i % scale == 0
                    && j % scale == 0) {
                    CGPoint point = CGPointMake(j / scale, i / scale);
                    
                    [tempWhitePointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsDic setObject:@(NO) forKey:NSStringFromCGPoint(point)];
                }
            } else {
                // Area to draw
                //修改像素值
//                data[i] = data[i + 1] = data[i + 2] = 255;
//                data[i + 3] = 255;
                
                if (i % scale == 0
                    && j % scale == 0) {
                    CGPoint point = CGPointMake(j / scale, i / scale);
                    
                    [tempBlackPointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsDic setObject:@(YES) forKey:NSStringFromCGPoint(point)];
                }
            }
        }
    }
    
    self.whitePointsArray = [NSArray arrayWithArray:tempWhitePointsArray];
    self.blackPointsArray = [NSArray arrayWithArray:tempBlackPointsArray];
    self.pointsStatusDic = tempPointsDic;
    
    //生成新的图像
//    size_t bitsPerPixel = bitsPerComponent * 4;
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
//
//    cgimage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, kCGImageAlphaLast | kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
//
//    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
//    
//    return newImage;
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
    
    return nil;
}

- (UIFont *)getCurrentShowFontWithFontSize:(CGFloat)fontSize
{
//    UIFont *showFont = [UIFont systemFontOfSize:fontSize];
    UIFont *showFont = [UIFont boldSystemFontOfSize:fontSize];
    
    return showFont;
}


/**
 生成可能的标签对象
 */
- (void)generatePossibleLabelContainerArray
{
    NSMutableArray *tempLabelContainerArray = [NSMutableArray array];
    NSMutableArray *tempShowContainerArray = [NSMutableArray array];
    
    for (NSNumber *fontValue in _wordFontSizeArray) {
        for (NSString *text in _wordTextArray) {
            NSInteger fontSize = [fontValue integerValue];
            UIFont *currentFont = [self getCurrentShowFontWithFontSize:fontSize];
            CGSize currentSize = [text sizeWithAttributes:@{NSFontAttributeName : currentFont}];
            currentSize.width += _wordMinInset;
//            currentSize.height += _wordMinInset;
            
            //记录最小尺寸宽度和高度
            if (CGSizeEqualToSize(_minSize, currentSize)) {
                _minSize = currentSize;
            }else{
                _minSize.width = MIN(_minSize.width, currentSize.width);
                _minSize.height = MIN(_minSize.height, currentSize.height);
            }
            
            if (CGSizeEqualToSize(_maxSize, currentSize)) {
                _maxSize = currentSize;
            } else {
                _maxSize.width = MAX(_maxSize.width, currentSize.width);
                _maxSize.height = MAX(_maxSize.height, currentSize.height);
            }
            
            for (NSNumber *value in _wordAngleArray) {
                double angle = [value doubleValue];
                
                ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
                container.wordText = text;
                container.wordFont = currentFont;
                container.wordSize = currentSize;
                
                container.originalRect = CGRectMake(0, 0, currentSize.width, currentSize.height);
                
                container.currentRadius = sqrtf(powf(currentSize.width, 2) + powf(currentSize.height, 2)) / 2.0;//包围矩形边框的外接圆半径
                container.currentAngle = angle;//偏转角度
                
                if ([self isVerticalAngle:angle]) {
                    container.currentRect = CGRectMake(0, 0, currentSize.height, currentSize.width);
                } else if ([self isHorizontalAngle:angle]) {
                    container.currentRect = container.originalRect;
                } else {
                    container.originalRect = [self getRealOriginalRectForRotationRectWhenCurrentOriginIsZeroWithSize:currentSize rotationAngle:angle];
                    container.currentRect = container.originalRect;
                }
                
                //记录全部container
                [tempLabelContainerArray addObject:container];
                
                //--------------------------
                //记录不重复的showContainer对象(size和角度不完全一样)
                BOOL isExist = NO;
                ALWWordCloudShowContainer *showContainer;
                
                for (int i = 0; i < tempShowContainerArray.count; i++) {
                    showContainer = tempShowContainerArray[i];
                    
                    if (CGSizeEqualToSize(showContainer.wordSize, container.wordSize)
                        && showContainer.currentAngle == container.currentAngle) {
                        //重复的showContainer
                        isExist = YES;
                        break;
                    }
                }
                
                if (isExist) {
                    //将labelContainer加入showContainer的分组数组中
                    [showContainer.labelContainerArray addObject:container];
                } else {
                    //新建showContainer
                    showContainer = [[ALWWordCloudShowContainer alloc] init];
                    showContainer.wordSize = container.wordSize;
                    showContainer.currentAngle = container.currentAngle;
                    showContainer.rotationRectOffsetVector = container.originalRect.origin;
                    
                    showContainer.labelContainerArray = [NSMutableArray arrayWithObject:container];
                    
                    [tempShowContainerArray addObject:showContainer];
                }
            }
        }
    }
    
    self.labelContainerArray = tempLabelContainerArray;
    self.showContainerArray = tempShowContainerArray;
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

- (void)generatePossibleKeyLabelContainerArray
{
    NSMutableArray *keyLabelContainerArray = [NSMutableArray array];
    NSMutableArray *keyShowContainerArray = [NSMutableArray array];
    
    for (NSString *text in _wordKeyTextArray) {
        for (NSNumber *fontValue in _wordFontSizeArray) {
            NSInteger fontSize = [fontValue integerValue];
            UIFont *currentFont = [self getCurrentShowFontWithFontSize:fontSize];
            CGSize currentSize = [text sizeWithAttributes:@{NSFontAttributeName : currentFont}];
            currentSize.width += _wordMinInset * 2;
//            currentSize.height += _wordMinInset;
            
            //记录最小尺寸宽度和高度
            if (CGSizeEqualToSize(_minKeySize, currentSize)) {
                _minKeySize = currentSize;
            }else{
                _minKeySize.width = MIN(_minKeySize.width, currentSize.width);
                _minKeySize.height = MIN(_minKeySize.height, currentSize.height);
            }
            
            if (CGSizeEqualToSize(_maxKeySize, currentSize)) {
                _maxKeySize = currentSize;
            } else {
                _maxKeySize.width = MAX(_maxKeySize.width, currentSize.width);
                _maxKeySize.height = MAX(_maxKeySize.height, currentSize.height);
            }
            
            for (NSNumber *value in _wordAngleArray) {
                double angle = [value doubleValue];
                
                ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
                container.wordText = text;
                container.wordFont = currentFont;
                container.wordSize = currentSize;
                
                container.originalRect = CGRectMake(0, 0, currentSize.width, currentSize.height);
                
                container.currentRadius = sqrtf(powf(currentSize.width, 2) + powf(currentSize.height, 2)) / 2.0;//包围矩形边框的外接圆半径
                container.currentAngle = angle;//偏转角度
                
                if ([self isVerticalAngle:angle]) {
                    container.currentRect = CGRectMake(0, 0, currentSize.height, currentSize.width);
                } else if ([self isHorizontalAngle:angle]) {
                    container.currentRect = container.originalRect;
                } else {
                    container.originalRect = [self getRealOriginalRectForRotationRectWhenCurrentOriginIsZeroWithSize:currentSize rotationAngle:angle];
                    container.currentRect = container.originalRect;
                }
                
                //记录全部container
                [keyLabelContainerArray addObject:container];
                
                //记录不重复的keyShowContainer对象(size和角度不完全一样)
                BOOL isExist = NO;
                ALWWordCloudShowContainer *keyShowContainer;
                
                for (int i = 0; i < keyShowContainerArray.count; i++) {
                    keyShowContainer = keyShowContainerArray[i];
                    
                    if (CGSizeEqualToSize(keyShowContainer.wordSize, container.wordSize)
                        && keyShowContainer.currentAngle == container.currentAngle) {
                        //重复的showContainer
                        isExist = YES;
                        break;
                    }
                }
                
                if (isExist) {
                    //将labelContainer加入showContainer的分组数组中
                    [keyShowContainer.labelContainerArray addObject:container];
                } else {
                    //新建showContainer
                    keyShowContainer = [[ALWWordCloudShowContainer alloc] init];
                    keyShowContainer.wordSize = container.wordSize;
                    keyShowContainer.currentAngle = container.currentAngle;
                    keyShowContainer.rotationRectOffsetVector = container.originalRect.origin;
                    
                    keyShowContainer.labelContainerArray = [NSMutableArray arrayWithObject:container];
                    
                    [keyShowContainerArray addObject:keyShowContainer];
                }
            }
        }
    }
    
    self.keyLabelContainerArray = keyLabelContainerArray;
    self.keyShowContainerArray = keyShowContainerArray;
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

/**
 逐点扫描的算法
 */
- (void)scanVerticalPointsOneByOne
{
    for (int x = 0; x < _bgView.frame.size.width; x++) {
        NSMutableArray *mutYArray = [NSMutableArray array];
        for (int i = 0; i < _bgView.frame.size.height; i++) {
            [mutYArray addObject:@(i)];
        }
        
        while (mutYArray.count > 0) {
            NSInteger randomIndex = arc4random() % mutYArray.count;
            NSInteger y = [mutYArray[randomIndex] integerValue];
            CGPoint originPoint = CGPointMake(x, y);
            
            CGRect canUseRect = [self isExistCanUseRegionWithOriginPoint:originPoint minSize:_minKeySize];
            
            if (CGRectEqualToRect(canUseRect, CGRectZero)) {
                [mutYArray removeObjectAtIndex:randomIndex];
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithCanUseRegion:canUseRect];
            if (showContainer) {
                //绘制标签
                [self drawLabelContainerWithContainer:showContainer];
                
                for (NSInteger j = y; j < MIN(CGRectGetMaxY(showContainer.currentRect), _bgView.frame.size.height); j++) {
                    [mutYArray removeObject:@(j)];
                }
            }else{
                for (NSInteger j = y; j < MIN(y + _wordMinInset, _bgView.frame.size.height); j++) {
                    [mutYArray removeObject:@(j)];
                }
            }
        }
        
        x += _wordMinInset;
    }
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

- (void)scanHorizontalPointsOneByOne
{
    for (int y = 0; y < _bgView.frame.size.height; y++) {
        NSMutableArray *mutXArray = [NSMutableArray array];
        for (int i = 0; i < _bgView.frame.size.width; i++) {
            [mutXArray addObject:@(i)];
        }
        
        while (mutXArray.count > 0) {
            NSInteger randomIndex = arc4random() % mutXArray.count;
            NSInteger x = [mutXArray[randomIndex] integerValue];
            CGPoint originPoint = CGPointMake(x, y);
            
            CGRect canUseRect = [self isExistCanUseRegionWithOriginPoint:originPoint minSize:_minKeySize];
            
            if (CGRectEqualToRect(canUseRect, CGRectZero)) {
                [mutXArray removeObjectAtIndex:randomIndex];
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithCanUseRegion:canUseRect];
            if (showContainer) {
                //绘制标签
                [self drawLabelContainerWithContainer:showContainer];
                
                for (NSInteger j = x; j < MIN(CGRectGetMaxX(showContainer.currentRect), _bgView.frame.size.width); j++) {
                    [mutXArray removeObject:@(j)];
                }
            }else{
                for (NSInteger j = x; j < MIN(x + _wordMinInset, _bgView.frame.size.width); j++) {
                    [mutXArray removeObject:@(j)];
                }
            }
        }
        
        y += _wordMinInset;
    }
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

/**
 随机显示醒目的关键字
 */
- (void)verticalRandomShowKeyTextContainers
{
    for (int x = 0; x < _bgView.frame.size.width; x++) {
        NSMutableArray *mutYArray = [NSMutableArray array];
        for (int i = 0; i < _bgView.frame.size.height; i++) {
            [mutYArray addObject:@(i)];
        }
        
        while (mutYArray.count > 0) {
            if (_keyLabelContainerArray.count == 0) {
                return;
            }
            
            NSInteger randomIndex = arc4random() % mutYArray.count;
            NSInteger y = [mutYArray[randomIndex] integerValue];
            CGPoint originPoint = CGPointMake(x, y);
            
            CGRect canUseRect = [self isExistCanUseRegionWithOriginPoint:originPoint minSize:_minKeySize];
            
            if (CGRectEqualToRect(canUseRect, CGRectZero)) {
                [mutYArray removeObjectAtIndex:randomIndex];
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *showContainer = [self randomKeyWordCloudContainerWithCanUseRegion:canUseRect];
            if (showContainer) {
                //绘制标签
                [self drawKeyLabelContainerWithContainer:showContainer];
                
                for (NSInteger j = y; j < MIN(CGRectGetMaxY(showContainer.currentRect), _bgView.frame.size.height); j++) {
                    [mutYArray removeObject:@(j)];
                }
            }else{
                for (NSInteger j = y; j < MIN(y + _wordMinInset, _bgView.frame.size.height); j++) {
                    [mutYArray removeObject:@(j)];
                }
            }
        }
        
        x += _wordMinInset;
    }
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

- (void)hortizontalRandomShowKeyTextContainers
{
    for (int y = 0; y < _bgView.frame.size.height; y++) {
        NSMutableArray *mutXArray = [NSMutableArray array];
        for (int i = 0; i < _bgView.frame.size.width; i++) {
            [mutXArray addObject:@(i)];
        }
        
        while (mutXArray.count > 0) {
            if (_keyLabelContainerArray.count == 0) {
                return;
            }
            
            NSInteger randomIndex = arc4random() % mutXArray.count;
            NSInteger x = [mutXArray[randomIndex] integerValue];
            CGPoint originPoint = CGPointMake(x, y);
            
            CGRect canUseRect = [self isExistCanUseRegionWithOriginPoint:originPoint minSize:_minKeySize];
            
            if (CGRectEqualToRect(canUseRect, CGRectZero)) {
                [mutXArray removeObjectAtIndex:randomIndex];
                continue;
            }
            
            //根据点得到能填充的标签
            ALWWordCloudLabelContainer *showContainer = [self randomKeyWordCloudContainerWithCanUseRegion:canUseRect];
            if (showContainer) {
                //绘制标签
                [self drawKeyLabelContainerWithContainer:showContainer];
                
                for (NSInteger j = x; j < MIN(CGRectGetMaxX(showContainer.currentRect), _bgView.frame.size.height); j++) {
                    [mutXArray removeObject:@(j)];
                }
            }else{
                for (NSInteger j = x; j < MIN(x + _wordMinInset, _bgView.frame.size.width); j++) {
                    [mutXArray removeObject:@(j)];
                }
            }
        }
        
        y += _wordMinInset;
    }
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
}

//找出当前可用的最大区域（此方法耗时太长了，不可取）
- (CGRect)findMaxRect
{
    CGRect maxRect = CGRectZero;
    
    for (NSValue *value in _blackPointsArray) {
        //根据当前点，向右和向下延伸，找到最大可用区域
        CGPoint origin = [value CGPointValue];
        CGRect rect = [self isExistCanUseRegionWithOriginPoint:origin minSize:_minKeySize];
        
        if (rect.size.width * rect.size.height > maxRect.size.width * maxRect.size.height) {
            maxRect = rect;
        }
    }
    
    NSLog(@"complete: %@", NSStringFromSelector(_cmd));
    
    return maxRect;
}

/**
 根据origin点尝试返回可绘制的标签对象，失败则为nil

 @param origin origin description
 @return return value description
 */
- (ALWWordCloudLabelContainer *)randomCurrentWordCloudContainerWithCanUseRegion:(CGRect)region
{
    NSMutableArray<ALWWordCloudShowContainer*> *mutShowContainerArray = [NSMutableArray array];
    
    for (ALWWordCloudShowContainer *temp in _showContainerArray) {
        if (temp.wordSize.width <= region.size.width
            && temp.wordSize.height <= region.size.height) {
            [mutShowContainerArray addObject:temp];
        }
    }
    
    while (mutShowContainerArray.count > 0) {
        NSInteger randomIndex = arc4random() % mutShowContainerArray.count;
        ALWWordCloudShowContainer *showContainer = mutShowContainerArray[randomIndex];
        CGPoint origin = region.origin;
        CGSize wordSize = showContainer.wordSize;
        CGRect originalRect = CGRectMake(origin.x, origin.y, wordSize.width, wordSize.height);
        CGRect showRect = originalRect;
        
        //使用二维旋转矩阵判断点数组
        NSArray *tempDrawPointsArray;
        
        if ([self isHorizontalAngle:showContainer.currentAngle]
            || [self isVerticalAngle:showContainer.currentAngle]) {
            if ([self isVerticalAngle:showContainer.currentAngle]) {
                showRect = CGRectMake(origin.x, origin.y, wordSize.height, wordSize.width);
            }
            
            //判断临时的标签是否可以用于显示
            //showRect区域内是否有不可用点，包括白点和已占用点
            if (![self canUseRectAsShowRect:showRect]) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        } else{
            //使用二维旋转矩阵判断点数组
            originalRect = CGRectMake(origin.x + showContainer.rotationRectOffsetVector.x, origin.y + showContainer.rotationRectOffsetVector.y, wordSize.width, wordSize.height);
            showRect = originalRect;
            
            CGPoint center = CGPointMake(originalRect.origin.x + originalRect.size.width / 2.0, originalRect.origin.y + originalRect.size.height / 2.0);

            tempDrawPointsArray = [self getDrawPointsArrayWithOriginalRect:originalRect rotationAngle:showContainer.currentAngle rotationCenterPoint:center];
            
            if (!tempDrawPointsArray) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        }
        
        //可以使用该size显示
        //生成显示用标签属性配置对象
        NSInteger randomContainerIndex = arc4random() % showContainer.labelContainerArray.count;
        ALWWordCloudLabelContainer *randomContainer = showContainer.labelContainerArray[randomContainerIndex];
        
        ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
        tempContainer.wordText = randomContainer.wordText;
        tempContainer.wordFont = randomContainer.wordFont;
        tempContainer.wordSize = randomContainer.wordSize;
        
        tempContainer.currentRadius = randomContainer.currentRadius;
        tempContainer.currentAngle = randomContainer.currentAngle;
        
        //反向推算圆心和原始rect
        tempContainer.currentRect = showRect;
        
        tempContainer.currentCenter = CGPointMake(origin.x + showRect.size.width / 2.0, origin.y + showRect.size.height / 2.0);
        
        //计算未旋转时候的rect
        if ([self isVerticalAngle:tempContainer.currentAngle]) {
            originalRect.origin = CGPointMake(tempContainer.currentCenter.x - tempContainer.currentRect.size.height / 2.0, tempContainer.currentCenter.y - tempContainer.currentRect.size.width / 2.0);
        }
        
        tempContainer.originalRect = originalRect;

        //随机颜色
        NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
        tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
        
        //倾斜容器的点数组
        tempContainer.drawPointsArray = tempDrawPointsArray;
        
        return tempContainer;
        break;
    }
    
    return nil;
}

- (ALWWordCloudLabelContainer *)randomKeyWordCloudContainerWithCanUseRegion:(CGRect)region
{
    NSMutableArray<ALWWordCloudShowContainer*> *mutShowContainerArray = [NSMutableArray array];
    
    for (ALWWordCloudShowContainer *temp in _keyShowContainerArray) {
        if (temp.wordSize.width <= region.size.width
            && temp.wordSize.height <= region.size.height) {
            [mutShowContainerArray addObject:temp];
        }
    }
    
    while (mutShowContainerArray.count > 0 && _keyLabelContainerArray.count > 0) {
        NSInteger randomIndex = arc4random() % mutShowContainerArray.count;
        ALWWordCloudShowContainer *showContainer = mutShowContainerArray[randomIndex];
        CGPoint origin = region.origin;
        CGSize wordSize = showContainer.wordSize;
        CGRect originalRect = CGRectMake(origin.x, origin.y, wordSize.width, wordSize.height);
        CGRect showRect = originalRect;
        
        //使用二维旋转矩阵判断点数组
        NSArray *tempDrawPointsArray;
        
        if ([self isHorizontalAngle:showContainer.currentAngle]
            || [self isVerticalAngle:showContainer.currentAngle]) {
            if ([self isVerticalAngle:showContainer.currentAngle]) {
                showRect = CGRectMake(origin.x, origin.y, wordSize.height, wordSize.width);
            }
            
            //判断临时的标签是否可以用于显示
            //showRect区域内是否有不可用点，包括白点和已占用点
            if (![self canUseRectAsShowRect:showRect]) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        } else{
            //使用二维旋转矩阵判断点数组
            originalRect = CGRectMake(origin.x + showContainer.rotationRectOffsetVector.x, origin.y + showContainer.rotationRectOffsetVector.y, wordSize.width, wordSize.height);
            showRect = originalRect;
            
            CGPoint center = CGPointMake(originalRect.origin.x + originalRect.size.width / 2.0, originalRect.origin.y + originalRect.size.height / 2.0);
            
            tempDrawPointsArray = [self getDrawPointsArrayWithOriginalRect:originalRect rotationAngle:showContainer.currentAngle rotationCenterPoint:center];
            
            if (!tempDrawPointsArray) {
                [mutShowContainerArray removeObjectAtIndex:randomIndex];
                continue;
            }
        }
        
        //可以使用该size显示
        //生成显示用标签属性配置对象
        NSInteger randomContainerIndex = arc4random() % showContainer.labelContainerArray.count;
        ALWWordCloudLabelContainer *randomContainer = showContainer.labelContainerArray[randomContainerIndex];
        
        ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
        tempContainer.wordText = randomContainer.wordText;
        tempContainer.wordFont = randomContainer.wordFont;
        tempContainer.wordSize = randomContainer.wordSize;
        
        tempContainer.currentRadius = randomContainer.currentRadius;
        tempContainer.currentAngle = randomContainer.currentAngle;
        
        //反向推算圆心和原始rect
        tempContainer.currentRect = showRect;
        
        tempContainer.currentCenter = CGPointMake(origin.x + showRect.size.width / 2.0, origin.y + showRect.size.height / 2.0);
        
        //计算未旋转时候的rect
        if ([self isVerticalAngle:tempContainer.currentAngle]) {
            originalRect.origin = CGPointMake(tempContainer.currentCenter.x - tempContainer.currentRect.size.height / 2.0, tempContainer.currentCenter.y - tempContainer.currentRect.size.width / 2.0);
        }
        
        tempContainer.originalRect = originalRect;
        
        //随机颜色
        NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
        tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
        
        //倾斜容器的点数组
        tempContainer.drawPointsArray = tempDrawPointsArray;
        
        return tempContainer;
        break;
    }
    
    return nil;
}

- (CGRect)getRealOriginalRectForRotationRectWhenCurrentOriginIsZeroWithSize:(CGSize)size rotationAngle:(double)rotationAngle
{
    CGRect realOriginalRect = CGRectZero;
    
    //计算出展示时候的真正中心点
    if (rotationAngle > 0) {
        //倾斜方向为左下至右上
        CGRect originalRect = CGRectMake(0, 0, size.width, size.height);
        
        CGPoint origin = originalRect.origin;
        CGSize wordSize = originalRect.size;
        
        CGFloat distanceX = cos(rotationAngle) * wordSize.width;
        CGFloat distanceY = sin(rotationAngle) * wordSize.width;
        
        CGPoint leftTop = CGPointMake(origin.x, origin.y + distanceY);
        CGPoint rightTop = CGPointMake(origin.x + distanceX, origin.y);
        
        CGPoint vector = CGPointMake(sin(rotationAngle) * wordSize.height, cos(rotationAngle) * wordSize.height);
        
        CGPoint rightBottom = CGPointMake(rightTop.x + vector.x, rightTop.y + vector.y);
        
        CGPoint showCenter = CGPointMake((leftTop.x + rightBottom.x) / 2.0 , (leftTop.y + rightBottom.y) / 2.0);
        
        realOriginalRect = CGRectMake(showCenter.x - wordSize.width / 2.0, showCenter.y - wordSize.height / 2.0 , wordSize.width, wordSize.height);
    } else {
        //倾斜方向为左上至右下
        CGRect originalRect = CGRectMake(0, 0, size.width, size.height);
        
        CGPoint origin = originalRect.origin;
        CGSize wordSize = originalRect.size;
        
        CGFloat distanceX = sin(rotationAngle) * wordSize.height;
        CGFloat distanceY = cos(rotationAngle) * wordSize.height;
        
        CGPoint leftTop = CGPointMake(origin.x + distanceX, origin.y);
        CGPoint leftBottom = CGPointMake(origin.x, origin.y + distanceY);
        
        CGPoint vector = CGPointMake(cos(rotationAngle) * wordSize.width, sin(rotationAngle) * wordSize.width);
        
        CGPoint rightBottom = CGPointMake(leftBottom.x + vector.x, leftBottom.y + vector.y);
        
        CGPoint showCenter = CGPointMake((leftTop.x + rightBottom.x) / 2.0 , (leftTop.y + rightBottom.y) / 2.0);
        
        realOriginalRect = CGRectMake(showCenter.x - wordSize.width / 2.0, showCenter.y - wordSize.height / 2.0 , wordSize.width, wordSize.height);
    }

    return realOriginalRect;
}


- (NSArray *)getDrawPointsArrayWithOriginalRect:(CGRect)originalRect rotationAngle:(double)rotationAngle rotationCenterPoint:(CGPoint)center
{
    NSMutableArray *drawPointsArray = [NSMutableArray array];
    
    BOOL canUse = YES;
    
    for (int y = originalRect.origin.y; y < CGRectGetMaxY(originalRect); y++) {
        for (int x = originalRect.origin.x; x < CGRectGetMaxX(originalRect); x++) {
            CGPoint currentPoint = CGPointMake(x, y);
            
            CGPoint newPoint = [self get2DRotationMatrixPointWithOriginalPoint:currentPoint rotationAngle:rotationAngle centerPoint:center];
            
            canUse = [self canUsePoint:newPoint];
            
            if (canUse) {
                [drawPointsArray addObject:[NSValue valueWithCGPoint:newPoint]];
            }else{
                break;
            }
        }
        
        if (!canUse) {
            break;
        }
    }
    
    if (!canUse) {
        [drawPointsArray removeAllObjects];
        drawPointsArray = nil;
    }
    
    return drawPointsArray;
}

/**
 如果倾斜角度非水平或者垂直，需要使用二维旋转矩阵，如下：
 (x, y)表示旋转前的点坐标，(x', y')表示旋转后的点坐标，(Cx, Cy)表示围绕旋转的中心点，θ表示旋转角，逆时针为正
 先平移向量(-Cx, -Cy)，使其当前中心点为坐标原点；然后根据如下公式得到旋转后的点，然后再平移向量(Cx, Cy)，得到真实点。
 
 x' = x*cosθ - y*sinθ;
 y' = x*sinθ + y*cosθ;
 
 @param point point description
 @param center center description
 @return return value description
 */
- (CGPoint)get2DRotationMatrixPointWithOriginalPoint:(CGPoint)point rotationAngle:(double)rotationAngle centerPoint:(CGPoint)center
{
    double angle = rotationAngle;

    CGPoint tempPoint = CGPointMake(point.x - center.x, point.y - center.y);
    
    NSInteger rotationX = tempPoint.x * cos(angle) - tempPoint.y * sin(angle);
    NSInteger rotationY = tempPoint.x * sin(angle) + tempPoint.y * cos(angle);
    
    NSInteger newPointX = rotationX + center.x;
    NSInteger newPointY = rotationY + center.y;
    
    CGPoint newPoint = CGPointMake(newPointX, newPointY);
    
    return newPoint;
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
    if (!pointsArray) {
        return;
    }
    
    [pointsArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint currentPoint = [obj CGPointValue];
        CGPoint intPoint = CGPointMake((int)currentPoint.x, (int)currentPoint.y);
        
        [_pointsStatusDic setObject:@(NO) forKey:NSStringFromCGPoint(intPoint)];
    }];
}

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


/**
 根据origin和最小size，判断是否存在可用区域，如果有，返回非zero的rect

 @param originPoint originPoint description
 @param minSize minSize description
 @return return value description
 */
- (CGRect)isExistCanUseRegionWithOriginPoint:(CGPoint)originPoint minSize:(CGSize)minSize
{
    if (![self canUsePoint:originPoint]) {
        return CGRectZero;
    }
    
    NSInteger maxWidth = 0;
    NSInteger maxHeight = 0;
    
    //根据当前的左上角点，计算可能的最大区域
    NSInteger maxX = originPoint.x + 1;
    
    while (maxX < _bgView.frame.size.width) {
        CGPoint tempPoint = CGPointMake(maxX, originPoint.y);
        
        if ([self canUsePoint:tempPoint]) {
            maxX++;
        }else{
            maxX--;
            break;
        }
    }
    
    maxWidth = maxX - originPoint.x;
    
    if (maxWidth < minSize.width) {
        return CGRectZero;
    }
    
    NSInteger maxY = originPoint.y + 1;

    while (maxY < _bgView.frame.size.height) {
        CGPoint tempPoint = CGPointMake(originPoint.x, maxY);
        
        if ([self canUsePoint:tempPoint]) {
            maxY++;
        }else{
            maxY--;
            break;
        }
    }
    
    maxHeight = maxY - originPoint.y;
    
    if (maxHeight < minSize.height) {
        return CGRectZero;
    }
    
    
    return CGRectMake(originPoint.x, originPoint.y, maxWidth, maxHeight);
}

/**
 判断区域是否可绘制

 @param rect rect description
 @return return value description
 */
- (BOOL)canUseRectAsShowRect:(CGRect)rect
{
    if (rect.origin.x < 0
        || rect.origin.y < 0
        || CGRectGetMaxX(rect) > _bgView.frame.size.width
        || CGRectGetMaxY(rect) > _bgView.frame.size.height) {
        return NO;
    }
    
    //扫描坐标点
    BOOL canUse = YES;
    
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

- (BOOL)canUseRegionWithPointsArray:(NSArray<NSValue*> *)pointsArray
{
    if (!pointsArray) {
        return NO;
    }
    
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
