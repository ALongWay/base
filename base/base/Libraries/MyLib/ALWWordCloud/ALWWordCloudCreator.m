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

@property (nonatomic, assign) CGSize        originalSize;

@property (nonatomic, assign) CGPoint       currentCenter;//包围矩形边框的外接圆圆心
@property (nonatomic, assign) CGRect        originalRect;//偏转前的rect
@property (nonatomic, assign) CGRect        currentRect;//偏转后的rect
@property (nonatomic, assign) CGFloat       currentRadius;//包围矩形边框的外接圆半径
@property (nonatomic, assign) CGFloat       currentAngle;//偏转角度
@property (nonatomic, assign) CGPathRef     currentPath;//偏转后实际的path

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
//保留全部可能的labelcontainer对象
@property (nonatomic, strong) NSArray<ALWWordCloudLabelContainer*>  *labelContainerArray;

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
        self.wordMaxFontSize = 25;
        self.wordMinFontSize = 5;
        self.wordFontStepValue = 2;
        self.wordMinInset = 2;
        
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
- (void)createWordCloudViewWithImageView:(UIImageView *)imageView completionBlock:(void (^)(UIView *))completion
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
        
        CGFloat minRadius = [[_wordCircleRadiusArray firstObject] floatValue];
        CGFloat maxRadius = [[_wordCircleRadiusArray lastObject] floatValue];
        
        NSInteger count = _labelContainerArray.count;
        
        for (int i = 0; i < count; i++) {
            NSInteger randomIndex = arc4random() % _blackPointsArray.count;
            CGPoint currentPoint = [_blackPointsArray[randomIndex] CGPointValue];
            
            //根据中心点得到能填充的标签
            ALWWordCloudLabelContainer *tempContainer = [self randomCurrentWordCloudContainerWithCenterPoint:currentPoint];
            if (tempContainer) {
                //添加到已占用的path数组
                [self.occupiedPathsArray addObject:tempContainer];
                
                //绘制标签
                UILabel *wordLabel = [[UILabel alloc] initWithFrame:tempContainer.originalRect];
                wordLabel.transform = CGAffineTransformMakeRotation(tempContainer.currentAngle);
                [wordLabel setText:tempContainer.wordText];
                [wordLabel setTextColor:tempContainer.wordColor];
                [wordLabel setFont:tempContainer.wordFont];
                [_bgView addSubview:wordLabel];
            }
        }
        
//        
//        for (int i = 0; i < _blackPointsArray.count; ) {
//            NSLog(@"_blackPointsArray index: %d", (int)i);
//
//            CGPoint currentPoint = [_blackPointsArray[i] CGPointValue];
//            
//            //根据中心点得到能填充的标签
//            ALWWordCloudLabelContainer *tempContainer = [self randomCurrentWordCloudContainerWithCenterPoint:currentPoint];
//            if (tempContainer) {
//                //添加到已占用的path数组
//                [self.occupiedPathsArray addObject:tempContainer];
//                
//                //绘制标签
//                UILabel *wordLabel = [[UILabel alloc] initWithFrame:tempContainer.currentRect];
//                wordLabel.transform = CGAffineTransformMakeRotation(tempContainer.currentAngle);
//                [wordLabel setText:tempContainer.wordText];
//                [wordLabel setTextColor:tempContainer.wordColor];
//                [wordLabel setFont:tempContainer.wordFont];
//                [_bgView addSubview:wordLabel];
//                
//                i += tempContainer.currentRadius;;
//            }else{
//                i += minRadius;
//            }
//        }
        
        if (completion) {
            completion(_bgView);
        }
    });
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
                CGFloat angle = [value floatValue];
                
                ALWWordCloudLabelContainer *container = [[ALWWordCloudLabelContainer alloc] init];
                container.wordText = text;
                container.wordFont = currentFont;
                container.originalSize = currentSize;
                
                container.currentRadius = sqrtf(powf(currentSize.width, 2) + powf(currentSize.height, 2)) / 2.0;//包围矩形边框的外接圆半径
                container.currentAngle = angle;//偏转角度
                
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
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    [tempWhitePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(j / 2, i / 2)]];
                }
            } else {
                // Area to draw
//                data[i] = data[i + 1] = data[i + 2] = 0;
//                data[i + 3] = 255;
                
                if (i % 2 == 0
                    && j % 2 == 0) {
                    [tempBlackPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(j / 2, i / 2)]];
                }
            }
        }
    }
    
//    cgimage = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
    self.whitePointsArray = [NSArray arrayWithArray:tempWhitePointsArray];
    self.blackPointsArray = [NSArray arrayWithArray:tempBlackPointsArray];
}

//随机选择标签容器
- (ALWWordCloudLabelContainer *)randomCurrentWordCloudContainerWithCenterPoint:(CGPoint)center
{
    if ([self isCenterInOccupiedRegion:center]) {
        return nil;
    }
    
    NSMutableArray *mutContainerArray = [NSMutableArray arrayWithArray:self.labelContainerArray];
    
    while (mutContainerArray.count > 0) {
        NSInteger randomIndex = arc4random() % mutContainerArray.count;
        ALWWordCloudLabelContainer *randomContainer = mutContainerArray[randomIndex];
        
        ALWWordCloudLabelContainer *tempContainer = [[ALWWordCloudLabelContainer alloc] init];
        tempContainer.wordText = randomContainer.wordText;
        tempContainer.wordFont = randomContainer.wordFont;
        tempContainer.originalSize = randomContainer.originalSize;
        
        tempContainer.currentRadius = randomContainer.currentRadius;
        tempContainer.currentAngle = randomContainer.currentAngle;

        tempContainer.currentCenter = center;
        
        //重新计算的属性
        CGSize size = randomContainer.originalSize;
        tempContainer.originalRect = CGRectMake(center.x - size.width / 2.0, center.y - size.height / 2.0, size.width, size.height);
        
        if (randomContainer.currentAngle == M_PI_2
            || randomContainer.currentAngle == -M_PI_2) {
            tempContainer.currentRect = CGRectMake(center.x - size.height / 2.0, center.y - size.width / 2.0, size.height, size.width);
        }else{
            tempContainer.currentRect = tempContainer.originalRect;
        }
        
//        CGAffineTransform transform = CGAffineTransformMakeRotation(tempContainer.currentAngle);        
//        CGPathRef path = CGPathCreateWithRect(tempContainer.originalRect, &transform);
//        
//        tempContainer.currentPath = path;//偏转后实际的path
        
        //判断临时的标签是否可以用于显示
        //是否超出了最大区域
        if (tempContainer.currentRect.origin.x < 0
            || tempContainer.currentRect.origin.y < 0
            || CGRectGetMaxX(tempContainer.currentRect) > self.bgView.frame.size.width
            || CGRectGetMaxY(tempContainer.currentRect) > self.bgView.frame.size.height) {
            [mutContainerArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //是否包含不可用点
        if ([self isRectContainCannotUsePoint:tempContainer.currentRect]) {
            [mutContainerArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //是否与已占用区域重叠
        if ([self isContainerCrossWithOccupiedPath:tempContainer]) {
            [mutContainerArray removeObjectAtIndex:randomIndex];
            continue;
        }
        
        //可以使用
        NSInteger randomColorIndex = arc4random() % self.wordColorArray.count;
        tempContainer.wordColor = [self.wordColorArray objectAtIndex:randomColorIndex];
        
        return tempContainer;
        break;
    }
    
    return nil;
}

/**
 是否在已占用区域

 @param center center description
 @return return value description
 */
- (BOOL)isCenterInOccupiedRegion:(CGPoint)center
{
    __block BOOL canUse = NO;
    
    CGFloat maxRadius = [[_wordCircleRadiusArray lastObject] floatValue];
    NSArray *partOccupiedPathsArray = [self getPartOfOccupiedPathsByCurrentCenter:center currentRadius:maxRadius];
    
    [partOccupiedPathsArray enumerateObjectsUsingBlock:^(ALWWordCloudLabelContainer * _Nonnull occupiedContainer, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (CGRectContainsPoint(occupiedContainer.currentRect, center)) {
            canUse = YES;
            *stop = YES;
        }
    }];
    
    return canUse;
}

- (BOOL)isRectContainCannotUsePoint:(CGRect)rect
{
    for (NSValue *value in self.whitePointsArray) {
        CGPoint point = [value CGPointValue];
        
        if (CGRectContainsPoint(rect, point)) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (BOOL)isContainerCrossWithOccupiedPath:(ALWWordCloudLabelContainer *)container
{
    //根据圆心和半径筛选出需要比较的已占用区域
    NSArray<ALWWordCloudLabelContainer*> *partOccupiedPathArray = [self getPartOfOccupiedPathsByCurrentCenter:container.currentCenter currentRadius:container.currentRadius];
    
    for (ALWWordCloudLabelContainer *occupiedContainer in partOccupiedPathArray) {
        if (CGRectIntersectsRect(occupiedContainer.currentRect, container.currentRect)) {
            return YES;
            break;
        }
    }
    
    return NO;
    
    //------------------暂时不用
    //1.检查自己的顶点是否在其他path范围内
    
    //找出自己frame内所有点
    NSMutableArray *myPointsArray = [NSMutableArray array];

    CGPoint origin = container.currentRect.origin;
    for (int originY = origin.y; originY <= CGRectGetMaxY(container.currentRect); originY++) {
        for (int originX = origin.x; originX <= CGRectGetMaxX(container.currentRect); originX++) {
            [myPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, originY)]];
        }
    }

//    CGAffineTransform tranform = CGAffineTransformMakeRotation(container.currentAngle);

    for (ALWWordCloudLabelContainer *occupiedContainer in partOccupiedPathArray) {
        for (NSValue *value in myPointsArray) {
            CGPoint currentPoint = [value CGPointValue];
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:occupiedContainer.currentPath];
            [bezierPath applyTransform:CGAffineTransformMakeRotation(-container.currentAngle)];
            if ([bezierPath containsPoint:currentPoint]) {
                return YES;
                break;
            }

            
//            if (CGPathContainsPoint(occupiedContainer.currentPath, &tranform, currentPoint, NO)) {
//                return YES;
//                break;
//            }
        }
    }
    
    //2.检查其他标签顶点是否在自己的path范围内
    for (ALWWordCloudLabelContainer *occupiedContainer in partOccupiedPathArray) {
        //找出其他标签的frame内所有点
        NSMutableArray *anotherPointsArray = [NSMutableArray array];
        
        CGPoint origin = occupiedContainer.currentRect.origin;
        for (int originY = origin.y; originY <= CGRectGetMaxY(occupiedContainer.currentRect); originY++) {
            for (int originX = origin.x; originX <= CGRectGetMaxX(occupiedContainer.currentRect); originX++) {
                [anotherPointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(originX, originY)]];
            }
        }
        
//        CGAffineTransform tranform = CGAffineTransformMakeRotation(occupiedContainer.currentAngle);
        
        for (NSValue *value in anotherPointsArray) {
            CGPoint currentPoint = [value CGPointValue];
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:occupiedContainer.currentPath];
            [bezierPath applyTransform:CGAffineTransformMakeRotation(-container.currentAngle)];
            if ([bezierPath containsPoint:currentPoint]) {
                return YES;
                break;
            }
            
//            if (CGPathContainsPoint(container.currentPath, &tranform, currentPoint, NO)) {
//                return YES;
//                break;
//            }
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
