//
//  KeyboardPopView.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "KeyboardPopView.h"
#import <Masonry/Masonry.h>

@interface KeyboardPopView ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation KeyboardPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
        [self addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(40);
            make.top.equalTo(self).offset(40);
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
        make.height.mas_equalTo(320);
    }];
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom"]];
    }
    return _imgView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"测试输出框";
        _textField.textAlignment = NSTextAlignmentCenter;
    }
    return _textField;
}

@end
