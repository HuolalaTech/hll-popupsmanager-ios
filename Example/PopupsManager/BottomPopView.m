//
//  BottomPopView.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "BottomPopView.h"
#import <Masonry/Masonry.h>

@interface BottomPopView ()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation BottomPopView

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark - HLLPopupInterface

- (UIView *)supplyCustomPopupView {
    return self;
}

- (void)layoutWithSuperView:(UIView *)superView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(superView);
        make.height.mas_equalTo(220);
    }];
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomShare"]];
    }
    return _imgView;
}

@end
