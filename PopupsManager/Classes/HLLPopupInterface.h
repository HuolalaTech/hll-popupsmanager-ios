//
//  HLLPopupViewInterface.h
//
//  Created by Kris on 2021/9/2.
//

#import "HLLPopupConfigure.h"

@protocol HLLPopupInterface <NSObject>

@required
/// 提供一个弹窗view对象
- (UIView *)supplyCustomPopupView;

@optional
/// 对自定义view进行布局
- (void)layoutWithSuperView:(UIView *)superView;

/// 执行自定义动画
- (void)executeCustomAnimation;

/// 提供一个需要设置圆角的view 默认是 supplyCustomPopupView 提供的view
- (UIView *)needSetCornerRadiusView;

/// 倒计时剩余时间回调
/// @param count count
- (void)countTimeWithCount:(NSInteger)count;

/* 弹窗的生命周期 */
- (void)popupViewDidAppear;
- (void)popupViewDidDisappear;
@end
