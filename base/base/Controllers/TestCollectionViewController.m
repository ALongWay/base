//
//  TestCollectionViewController.m
//  base
//
//  Created by 李松 on 16/10/26.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestCollectionViewController.h"

#define kCountPerRow                4
#define kItemSize                   CGSizeMake(60, 60)
#define kTestCollectionViewCell     @"TestCollectionViewCell"

@interface TestCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel       *textLabel;

@end

@implementation TestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setTextColor:COLOR(255, 255, 255)];
        [_textLabel setBackgroundColor:COLOR(0, 0, 0)];
        [self.contentView addSubview:_textLabel];
    }
    
    return self;
}

- (void)resetCellWithText:(NSString *)text
{
    _textLabel.frame = self.bounds;
    [_textLabel setText:text];
}

@end

#pragma mark -
@interface TestCollectionViewController ()<ALWCollectionViewDelegate, ALWCollectionViewDataSource>{
    ALWCollectionViewFlowLayout  *_layout;
    UICollectionView             *_collectionView;
    
    NSMutableArray               *_dataArray;
    NSMutableArray               *_sizeArray;
}

@end

@implementation TestCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"测试CollectionView";
    
    [self buildUI];
}

- (void)buildUI
{
    //50-60
    NSInteger count = arc4random() % 10 + 50;
    _dataArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        [_dataArray addObject:@(i)];
    }
    
    //+0~60
    _sizeArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSInteger addedWidth = arc4random() % 60;
        NSInteger addedHeight = arc4random() % 60;

        [_sizeArray addObject:[NSValue valueWithCGSize:CGSizeMake(kItemSize.width + addedWidth, kItemSize.height + addedHeight)]];
    }
    
    _layout = [[ALWCollectionViewFlowLayout alloc] initWithCountPerLine:4 itemFixedSide:kItemSize.width flowLayoutType:ALWCollectionViewFlowLayoutTypeFill];
//    _layout = [[ALWCollectionViewFlowLayout alloc] init];
    _layout.enableCustomDragGesture = YES;
//    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.minimumLineSpacing = 10;
    _layout.minimumInteritemSpacing = 10;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - StatusBarHeight - NaviBarHeight) collectionViewLayout:_layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:kTestCollectionViewCell];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter];
    [_collectionView setBackgroundColor:COLOR(240, 240, 240)];
    [self.view addSubview:_collectionView];
}

#pragma mark -- UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTestCollectionViewCell forIndexPath:indexPath];
    
    NSString *text = [NSString stringWithFormat:@"%ld", (long)[_dataArray[indexPath.row] integerValue]];
    [cell resetCellWithText:text];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
        [view setBackgroundColor:[UIColor redColor]];
        return view;
    } else {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
        [view setBackgroundColor:[UIColor blueColor]];
        return view;
    }
}


#pragma mark -- ALWCollectionViewDelegateFlowLayout
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section
{
    return [UIColor brownColor];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSValue *value = [_sizeArray objectAtIndex:indexPath.row];
    
    switch (_layout.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
            return CGSizeMake(kItemSize.width, [value CGSizeValue].height);
            break;
        }
        case UICollectionViewScrollDirectionHorizontal: {
            return CGSizeMake([value CGSizeValue].width, kItemSize.height);
            break;
        }
    }
  
//    return kItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (_layout.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
            return CGSizeMake(DeviceWidth, 40);
            break;
        }
        case UICollectionViewScrollDirectionHorizontal: {
            return CGSizeMake(40, DeviceHeight);
            break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    switch (_layout.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
            return CGSizeMake(DeviceWidth, 40);
            break;
        }
        case UICollectionViewScrollDirectionHorizontal: {
            return CGSizeMake(40, DeviceHeight);
            break;
        }
    }
}

#pragma mark -- ALWCollectionViewDelegate
- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"will begin dragging : %@", indexPath);
}

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did begin dragging : %@", indexPath);
}

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"will end dragging : %@", indexPath);
}

- (void)alw_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did end dragging : %@", indexPath);
}

#pragma mark -- ALWCollectionViewDataSource
//决定item是否可以移动或者被移动
- (BOOL)alw_collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{    
    return YES;
}

//此方法用于数据源交换数据
- (void)alw_collectionView:(UICollectionView *)collectionView willMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSObject *temp = [_dataArray objectAtIndex:sourceIndexPath.row];
    [_dataArray removeObjectAtIndex:sourceIndexPath.row];
    [_dataArray insertObject:temp atIndex:destinationIndexPath.row];
    
    temp = [_sizeArray objectAtIndex:sourceIndexPath.row];
    [_sizeArray removeObjectAtIndex:sourceIndexPath.row];
    [_sizeArray insertObject:temp atIndex:destinationIndexPath.row];
}

//此方法可用于刷新
- (void)alw_collectionView:(UICollectionView *)collectionView didMovedItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [_collectionView reloadData];
}

@end
