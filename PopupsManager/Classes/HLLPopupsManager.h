//
//  HLLWindowManager.h
//
//  Created by Kris on 2021/8/24.
//

#import <Foundation/Foundation.h>
#import "HLLPopupInterface.h"
#import "HLLPopupConfigure.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 HLLWindowManager：一个负责管理APP整个生命周期内，所有以弹窗样式展示的视图。
 */
@class HLLPopupViewInterface;

@interface HLLPopupsManager : NSObject

//单例对象
+ (instancetype)defaultManager;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

//当前所有队列中的弹窗
@property(nonatomic, strong, readonly) NSArray<id<HLLPopupInterface>> *allPopups;

/// 增加弹窗 （快速调用API方法，优先级和配置对象都采用默认）
/// @param popup popup:一个遵守了指定协议的类，该类不限制是否是UIView的子类，只要业务代码中保证实现了协议中的必选方法即可，在方法中告诉弹窗调度你
/// 真正的内容视图对象即可
+ (void)addPopup:(id<HLLPopupInterface>)popup;

/// 增加弹窗
/// @param popup popup target
/// @param priority 优先级：弹窗调度会根据不同优先级的弹窗来决定是否需要立即展示，高优先级的弹窗总是会先于低优先级的弹窗展示
+ (void)addPopup:(id<HLLPopupInterface>)popup priority:(HLLPopupStrategyPriority)priority;

/// 增加弹窗
/// @param popup popup target
/// @param options configure：一个弹窗配置对象，里面提供了涵哥各种弹窗场景的属性供调用者设置
+ (void)addPopup:(id<HLLPopupInterface>)popup options:(HLLPopupConfigure * _Nullable )options;

/// 移除指定弹窗
/// @param popup popup：触发弹窗时传入的遵守协议的对象
+ (void)dismissWithPopup:(id<HLLPopupInterface>)popup;

/// 移除指定弹窗
/// @param identifier identifier: 业务调用中设置的唯一标识符
+ (void)dismissPopupWithIdentifier:(NSString *)identifier;

/// 从指定容器中移除所有的弹窗
/// @param containerView 指定容器，传nil则移除当前APP的keywindow上的
+ (void)removeAllPopupFromContainerView:(UIView *)containerView;

/// 移除调度管理中之前加入的所有弹窗
+ (void)removeAllPopup;

/// 获取指定容器中的所有弹窗个数
/// @param containerView 容器view
+ (NSInteger)getAllPopupCountFromContainerView:(UIView *)containerView;

/// 获取所有容器中的弹窗个数
+ (NSInteger)getTotalPopupCount;

@end

NS_ASSUME_NONNULL_END
