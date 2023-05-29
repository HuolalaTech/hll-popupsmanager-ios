//
//  CenterPopView.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "CenterPopView.h"
#import <Masonry/Masonry.h>

@interface CenterPopView ()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation CenterPopView

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
        make.left.equalTo(superView).offset(50);
        make.right.equalTo(superView).offset(-50);
        make.centerY.equalTo(superView);
        make.height.mas_equalTo(400);
    }];
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"center"]];
    }
    return _imgView;
}
@end
