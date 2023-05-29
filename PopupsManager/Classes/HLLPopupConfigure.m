//
//  HLLPopoverWidgetConfigure.m
//
//  Created by Kris on 2021/9/22.
//

#import "HLLPopupConfigure.h"
#import <YYModel/YYModel.h>

@implementation HLLPopupConfigure

- (instancetype)init
{
    self = [super init];
    if (self) {
        //弹窗配置初始化
        _clickOutsideDismiss = NO;
        _sceneStyle = HLLPopupSceneCenter;
        _popAnimationStyle = HLLPopAnimationStyleFade;
        _dismissAnimationStyle = HLLDismissAnimationStyleFade;
        _priority = 0;
        _aloneMode = NO;
        _backgroundColor = [UIColor blackColor];
        _backgroundAlpha = 0.25;
        _popAnimationTime = 0.3;
        _dismissAnimationTime = 0.3;
        _keyboardVSpace = 10;
    }
    return self;
}

- (void)configureDefaultParams {
    if (_cornerRadius > 0 && _rectCorners == 0) {
        _rectCorners = UIRectCornerAllCorners;
    }
    //通知条场景默认进行独立分组
    if (_sceneStyle == HLLPopupSceneTopNoticeView && _groupID == nil) {
        _groupID = @"PopupSceneTopNoticeBar";
        _hiddenBackgroundView = YES;
    }
    //通知条默认自带上滑关闭手势
    if (_sceneStyle == HLLPopupSceneTopNoticeView) {
        _needNoticeBarPanGesture = YES;
        _clickOutsideDismiss = NO;
    }
    //底部半页
    if (_sceneStyle == HLLPopupSceneHalfPage) {
        _keyboardVSpace = 0.f;
    }
}

- (void)setPopAnimationTime:(NSTimeInterval)popAnimationTime {
    if (popAnimationTime > 0 && popAnimationTime < 3) {
        _popAnimationTime = popAnimationTime;
    }
}

- (void)setDismissAnimationTime:(NSTimeInterval)dismissAnimationTime {
    if (dismissAnimationTime > 0 && dismissAnimationTime < 3) {
        _dismissAnimationTime = dismissAnimationTime;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        [self yy_modelInitWithCoder:decoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [self yy_modelEncodeWithCoder:encoder];
}

@end
