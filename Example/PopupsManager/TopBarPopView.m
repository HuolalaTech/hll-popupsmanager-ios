//
//  TopBarPopView.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "TopBarPopView.h"
#import <Masonry/Masonry.h>

@interface TopBarPopView ()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation TopBarPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
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
        make.left.equalTo(superView).offset(10);
        make.right.equalTo(superView).offset(-10);
        make.top.equalTo(superView).offset(40);
        make.height.mas_equalTo(80);
    }];
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbar"]];
    }
    return _imgView;
}

@end
