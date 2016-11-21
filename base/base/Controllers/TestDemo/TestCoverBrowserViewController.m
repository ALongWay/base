//
//  TestCoverBrowserViewController.m
//  base
//
//  Created by 李松 on 2016/11/18.
//  Copyright © 2016年 alongway. All rights reserved.
//

#import "TestCoverBrowserViewController.h"

static NSString *const kCollectionViewCellIdentifier = @"collectionViewCell";
static const NSInteger kTestItemCount = 4;

@interface TestCoverBrowserViewController ()<ALWCoverBrowserDelegate>{
    NSMutableArray          *_testData;
}

@end

@implementation TestCoverBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"CoverBrowser";
    
    _testData = [NSMutableArray arrayWithCapacity:kTestItemCount];
    for (int i = 0; i < kTestItemCount; i++) {
        [_testData addObject:@(i)];
    }
    
    ALWCoverBrowser *cBView = [[ALWCoverBrowser alloc] init];
    cBView.delegate = self;
    cBView.center = CGPointMake(cBView.center.x, self.view.center.y - 64);
    [cBView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    [self.view addSubview:cBView];
}

#pragma mark -- ALWCoverBrowserDelegate
- (NSInteger)alwCoverBrowserNumberOfItems:(ALWCoverBrowser *)coverBrowser
{
    return _testData.count;
}

- (UICollectionViewCell *)alwCoverBrowser:(ALWCoverBrowser *)coverBrowser reuseCollectionViewCell:(UICollectionViewCell *)cell cellForItemAtIndex:(NSInteger)index
{
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    if (!label) {
        label = [[UILabel alloc] init];
        [label setBackgroundColor:COLOR(240, 240, 240)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:COLOR(0, 0, 0)];
        label.tag = 1;
        [cell.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    
    NSInteger value = [_testData[index] integerValue];
    NSLog(@"real index:%d , value: %d", (int)index, (int)value);
    
    [label setText:[NSString stringWithFormat:@"%d", (int)value]];
    
    return cell;
}

- (void)alwCoverBrowser:(ALWCoverBrowser *)coverBrowser didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"clicked index: %d", (int)index);
}

@end
