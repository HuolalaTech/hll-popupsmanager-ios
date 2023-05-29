//
//  FullPopView.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "FullPopView.h"
#import <Masonry/Masonry.h>

@interface FullPopView ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *timeCountLabl;
@end

@implementation FullPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
        [self addSubview:self.timeCountLabl];
        [self.timeCountLabl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

    }
    return self;
}

#pragma mark - HLLPopupInterface

- (UIView *)supplyCustomPopupView {
    return self;
}

- (void)layoutWithSuperView:(UIView *)superView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).with.insets(UIEdgeInsetsZero);
    }];
}

- (void)countTimeWithCount:(NSInteger)count {
    self.timeCountLabl.text = [NSString stringWithFormat:@"测试剩余：%lds",(long)count];
}

- (void)popupViewDidDisappear {
    NSLog(@"闪屏广告消失了");
    if (self.popViewDismissBlock) {
        self.popViewDismissBlock();
    }
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FullAdver"]];
    }
    return _imgView;
}

- (UILabel *)timeCountLabl {
    if (!_timeCountLabl) {
        _timeCountLabl = [[UILabel alloc] init];
        _timeCountLabl.backgroundColor = [UIColor blackColor];
        _timeCountLabl.textColor = [UIColor whiteColor];
        _timeCountLabl.font = [UIFont systemFontOfSize:30];
        _timeCountLabl.text = @"测试剩余：3s";
    }
    return _timeCountLabl;
}

@end
