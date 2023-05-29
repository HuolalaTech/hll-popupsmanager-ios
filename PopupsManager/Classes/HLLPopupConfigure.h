//
//  HLLPopoverWidgetConfigure.h
//
//  Created by Kris on 2021/9/22.
//

/*弹窗元素配置类 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HLLPopupInterface.h"

///弹窗场景类型
typedef NS_ENUM(NSInteger, HLLPopupScene) {
    HLLPopupSceneCenter = 0,//中心弹窗
    HLLPopupSceneHalfPage,//底部半页弹窗
    HLLPopupSceneTopNoticeView,//顶部通知条
    HLLPopupSceneFull,//全屏广告
};

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, HLLPopAnimationStyle) {
    HLLPopAnimationStyleFade = 0,       //渐隐渐变出现
    HLLPopAnimationStyleFallTop,        //顶部降落 适用：（HLLPopupSceneCenter）
    HLLPopAnimationStyleRiseBottom,     //底部升起 适用：（HLLPopupSceneHalfPage）
    HLLPopAnimationStyleScale,          //比例动画
};

/** 消失动画样式 */
typedef NS_ENUM(NSInteger, HLLDismissAnimationStyle) {
    HLLDismissAnimationStyleFade = 0,      //渐隐渐变消失
    HLLDismissAnimationStyleNO,            //无动画
};

typedef CGFloat HLLPopupStrategyPriority;//优先级类型
typedef dispatch_block_t HLLPopupCallback;
typedef void (^HLLPopupKeyBoardChange)(CGRect beginFrame,CGRect endFrame,CGFloat duration);//键盘信息回调

NS_ASSUME_NONNULL_BEGIN

@interface HLLPopupConfigure : NSObject<NSCopying>

/// 弹窗唯一标识
@property (nonatomic, copy) NSString *identifier;

/// 优先级 范围0~1000 (默认0,遵循先进先出)
@property (nonatomic, assign) CGFloat priority;

/// 弹窗场景风格
@property (nonatomic, assign) HLLPopupScene sceneStyle;

/// 点击弹窗背景（弹窗内容之外的区域）弹窗是否消失 default NO
@property (nonatomic, assign, getter=isClickOutsideDismiss) BOOL clickOutsideDismiss;

/// 弹窗的容器视图，默认是当前APP的keywindow,可以设置成其他容器
@property (nonatomic, weak) UIView *containerView;

/// 持续时长 设置后会在设定时间结束后自动dismiss,不设置不会自动消失
@property (nonatomic, assign) NSTimeInterval dismissDuration;

/// 该属性默认NO。设置YES会让之前的所有同组弹窗全部清除掉（优先级属性失效)
@property (nonatomic, assign, getter=isAloneMode) BOOL aloneMode;

/// 和aloneMode模式类似，不过terminatorMode会清除掉之前所有分组的弹窗
@property (nonatomic, assign, getter=isTerminatorMode) BOOL terminatorMode;

/// pop/dismiss动画样式
@property (nonatomic, assign) HLLPopAnimationStyle popAnimationStyle;
@property (nonatomic, assign) HLLDismissAnimationStyle dismissAnimationStyle;

/// 弹窗视图后面的背景色，通常是默认的半透明黑色，可自定义设置
@property (nonatomic, strong) UIColor *backgroundColor;

/// 背景透明度
@property (nonatomic, assign) CGFloat backgroundAlpha;

/* 分组ID，如果设置了分组ID，不同分组ID的弹窗不受影响,独立调度展示，
 HLLPopupSceneTopNoticeView 类型的默认自带分组（因为顶部通知条可覆盖普通弹窗）*/
@property (nonatomic, copy) NSString *groupID;

/// 弹窗内容圆角方向,默认UIRectCornerAllCorners,当cornerRadius>0时生效
@property (nonatomic, assign) UIRectCorner rectCorners;

/// 弹窗内容圆角大小
@property (nonatomic, assign) CGFloat cornerRadius;

/// 顶部通知条支持上滑关闭 默认YES
@property (nonatomic, assign) BOOL needNoticeBarPanGesture;

//不设置内部会默认根据动画类型设置
@property (nonatomic, assign) NSTimeInterval popAnimationTime;
@property (nonatomic, assign) NSTimeInterval dismissAnimationTime;

/// 是否隐藏背景
@property (nonatomic, assign,getter=isHiddenBackgroundView) BOOL hiddenBackgroundView;

/// 键盘和弹窗之间的垂直间距,通常默认为10，底部弹窗默认0
@property (nonatomic, assign) CGFloat keyboardVSpace;

#pragma mark - 事件回调
/// 点击背景回调
@property (nullable, nonatomic, copy) HLLPopupCallback clickBgCallback;

#pragma mark - 弹窗显示生命周期
@property (nullable, nonatomic, copy) HLLPopupCallback popViewDidShowCallback;
@property (nullable, nonatomic, copy) HLLPopupCallback popViewDidDismissCallback;

#pragma mark - 键盘处理
@property (nullable, nonatomic, copy) HLLPopupCallback keyboardWillShowCallback;
@property (nullable, nonatomic, copy) HLLPopupCallback keyboardDidShowCallback;
@property (nullable, nonatomic, copy) HLLPopupKeyBoardChange keyboardFrameWillChange;
@property (nullable, nonatomic, copy) HLLPopupKeyBoardChange keyboardFrameDidChange;
@property (nullable, nonatomic, copy) HLLPopupCallback keyboardWillHideCallback;
@property (nullable, nonatomic, copy) HLLPopupCallback keyboardDidHideCallback;

/// 配置默认参数(业务中无需调用)
- (void)configureDefaultParams;
@end

NS_ASSUME_NONNULL_END
