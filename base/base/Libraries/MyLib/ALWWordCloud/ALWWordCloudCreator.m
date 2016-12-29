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

@property (nonatomic, strong) NSArray<UIColor*>     *wordColorArray;
@property (nonatomic, strong) NSArray<NSString*>    *wordTextArray;
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

@property (nonatomic, strong) NSMutableArray<ALWWordCloudLabelContainer*>   *occupiedPathsArray;

@end

@implementation ALWWordCloudCreator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化变量
        self.wordMaxFontSize = 30;
        self.wordMinFontSize = 5;
        self.wordFontStepValue = 5;
        self.wordMinInset = 5;
        
        self.wordColorArray = @[[UIColor redColor],
                                [UIColor greenColor],
                                [UIColor grayColor],
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
        
        //目前先支持水平和垂直方向
        self.wordAngleArray = @[@(0), @(M_PI_2), @(-M_PI_2)];
    }
    
    return self;
}

#pragma mark -- Getter/Setter
- (NSMutableArray<ALWWordCloudLabelContainer *> *)occupiedPathsArray
{
    if (!_occupiedPathsArray) {
        _occupiedPathsArray = [NSMutableArray array];
    }
    
    return _occupiedPathsArray;
}

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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self identifyWhiteAndBlackPointsWithImage:currentImage];
        
        [self buildContainerArrayAndCalculateWordCircleRadiusArray];
        
        //扫描坐标点
        for (int y = 0; y < _bgView.frame.size.height; y++) {
            for (int x = 0; x < _bgView.frame.size.width; x++) {
                CGPoint originPoint = CGPointMake(x, y);
                NSLog(@"当前点坐标：%@", NSStringFromCGPoint(originPoint));
                
                BOOL canUse = [[_pointsDic objectForKey:NSStringFromCGPoint(originPoint)] boolValue];
                
                if (!canUse) {
                    continue;
                }
                
                //根据点得到能填充的标签
                ALWWordCloudLabelContainer *showContainer = [self randomCurrentWordCloudContainerWithOriginPoint:originPoint];
                if (showContainer) {
                    //标记占用的点
                    for (int usedY = showContainer.currentRect.origin.y; usedY <= CGRectGetMaxY(showContainer.currentRect); usedY++) {
                        for (int usedX = showContainer.currentRect.origin.x; usedX <= CGRectGetMaxX(showContainer.currentRect); usedX++) {
                            [_pointsDic setObject:@(NO) forKey:NSStringFromCGPoint(CGPointMake(usedX, usedY))];
                        }
                    }
                    
                    //添加到已占用的path数组
                    [self.occupiedPathsArray addObject:showContainer];
                    
                    //绘制标签
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
                    
                    x = CGRectGetMaxX(showContainer.currentRect) + _wordMinInset;
                }
            }
            
            y += _wordMinInset;
        }
        
        if (completion) {
            completion();
        }
    });
    
    return _bgView;
}

#pragma mark -- Private methods
- (UIFont *)getCurrentShowFontWithFontSize:(CGFloat)fontSize
{
    UIFont *showFont = [UIFont systemFontOfSize:fontSize];
    
    return showFont;
}

- (void)buildContainerArrayAndCalculateWordCircleRadiusArray
{
    NSMutableArray *tempLabelContainerArray = [NSMutableArray array];
    NSMutableArray *tempWordCircleRadiusArray = [NSMutableArray array];
    NSMutableArray *tempWordShowSizeArray = [NSMutableArray array];
    
    for (NSString *text in self.wordTextArray) {
        for (int i = _wordMinFontSize; i <= _wordMaxFontSize; ) {
            UIFont *currentFont = [self getCurrentShowFontWithFontSize:i];
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
                
                if (angle == M_PI_2
                    || angle == -M_PI_2) {
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
            
            i+=_wordFontStepValue;
            
            //最大字体
            if (i > _wordMaxFontSize && i - _wordMaxFontSize <_wordFontStepValue) {
                i = _wordMaxFontSize;
            }
        }
    }
    
    self.labelContainerArray = [NSMutableArray arrayWithArray:tempLabelContainerArray];
    self.wordCircleRadiusArray = [NSMutableArray arrayWithArray:tempWordCircleRadiusArray];
    self.wordShowSizeArray = [NSMutableArray arrayWithArray:tempWordShowSizeArray];
}

/**
 分辨可绘制和不可绘制点

 @param bgImage bgImage description
 */
- (void)identifyWhiteAndBlackPointsWithImage:(UIImage *)bgImage
{
    NSMutableArray *tempWhitePointsArray = [NSMutableArray array];
    NSMutableArray *tempBlackPointsArray = [NSMutableArray array];
    NSMutableDictionary *tempPointsDic = [NSMutableDictionary dictionary];
    
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
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    CGPoint point = CGPointMake(j / 2, i / 2);
                    
                    [tempWhitePointsArray addObject:[NSValue valueWithCGPoint:point]];
                    [tempPointsDic setObject:@(NO) forKey:NSStringFromCGPoint(point)];
                }
            } else {
                // Area to draw
//                data[i] = data[i + 1] = data[i + 2] = 0;
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
    
//    cgimage = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
    self.whitePointsArray = [NSArray arrayWithArray:tempWhitePointsArray];
    self.blackPointsArray = [NSArray arrayWithArray:tempBlackPointsArray];
    self.pointsDic = tempPointsDic;
}

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
        
        //是否包含不可用点
        if ([self isRectContainCannotUsePoint:showRect]) {
            [mutShowSizeArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //是否与已占用区域重叠
        if ([self isRectCrossWithOccupiedPath:showRect]) {
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
        
        if (randomContainer.currentAngle == M_PI_2
            || randomContainer.currentAngle == -M_PI_2) {
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

- (BOOL)isRectContainCannotUsePoint:(CGRect)rect
{
    for (NSValue *value in _whitePointsArray) {
        CGPoint point = [value CGPointValue];
        
        if (CGRectContainsPoint(rect, point)) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (BOOL)isRectCrossWithOccupiedPath:(CGRect)rect
{
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGFloat maxRadius = [[_wordCircleRadiusArray lastObject] floatValue];
    
    NSArray<ALWWordCloudLabelContainer*> *partOccupiedPathArray = [self getPartOfOccupiedPathsByCurrentCenter:center currentRadius:maxRadius];
    
    for (ALWWordCloudLabelContainer *occupiedContainer in partOccupiedPathArray) {
        if (CGRectIntersectsRect(occupiedContainer.currentRect, rect)
            || CGRectContainsRect(occupiedContainer.currentRect, rect)
            || CGRectContainsRect(rect, occupiedContainer.currentRect)) {
            return YES;
            break;
        }
    }
    
    return NO;
}

/**
 根据圆心和半径筛选出需要比较的已占用区域

 @param center center description
 @param radius radius description
 @return return value description
 */
- (NSArray<ALWWordCloudLabelContainer*> *)getPartOfOccupiedPathsByCurrentCenter:(CGPoint)center currentRadius:(CGFloat)radius
{
    NSMutableArray *needComparedContainerArray = [NSMutableArray array];
    for (ALWWordCloudLabelContainer *tempContainer in self.occupiedPathsArray) {
        //计算两个圆心距离
        CGFloat distance = sqrtf(powf(tempContainer.currentCenter.x - center.x, 2) + powf(tempContainer.currentCenter.y - center.y, 2));
        
        if (distance < tempContainer.currentRadius + radius) {
            [needComparedContainerArray addObject:tempContainer];
        }
    }
    
    return needComparedContainerArray;
}

@end
