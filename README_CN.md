<img src=Image/title.png width=100% height=100% />

[![license](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)

> [英文文档](README.md) 

## 介绍

        HLLPopupsManager是一个通用的弹窗调度管理组件，主要应用在一些业务复杂的项目中，来有效管理APP中各种类型弹窗之间的显示调度。它更像是一个复杂十字路口的红绿灯系统，有效管理各个方向的车辆和行人正常通行。

|Demo|<img src=image/演示.gif />

## 特点

- 支持弹窗视图自定义
- 支持自适应键盘输入场景
- 支持弹窗按照优先级模式展示
- 支持基础的显示隐藏动画
- 支持多种类型弹窗混合调度
- 支持弹窗批量移除
- 支持弹窗定时消失

## 要求

- iOS 9.0 或更高版本
- Xcode 11.0 或更高版本
- CocoaPods 1.11.2 或更高版本


## 安装

```ruby
pod 'PopupsManager'
```

## 使用

### 第一步

通常我们的弹窗都是通过自定义一个继续UIView的子类来实现弹窗的页面，你需要做的就是让你的自定义View来实现一个协议`HLLPopupInterface` 该协议会要求你的弹窗实现一个必要方法：`- (UIView *)supplyCustomPopupView;
` 这个方法的作用就是需要把你的弹窗View类对象给返回给`HLLPopupsManager`


```objc
//.h
//遵守指定协议
@interface xxx : UIView <HLLPopupInterface>
@end

//.m
#pragma mark - HLLPopupViewInterface
- (UIView *)supplyCustomPopupView {
    return self;
}

```
如果你的弹窗对象View和现有的一些逻辑类有关联，改造的过程没法把View单独出来，那么你可以让你的其他逻辑相关的类去实现这个协议，然后在协议方法中给你的自定义弹窗View返回即可：

```objc
//.h
//逻辑类
@interface xxx : NSObject <HLLPopupInterface>
@end

//.m
@property (nonatomic, strong) UIView *customPopupView;//自定义的弹窗View
#pragma mark - HLLPopupViewInterface
- (UIView *)supplyCustomPopupView {
    return self.customPopupView;
}
```

### 第二步

给你的弹窗进行配置，`PopupsManager` 提供了很多应对弹窗类型的配置属性，只需要设置即可。

```objc
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

···

```

这些知识配置的一部分属性，详情看参考源码进行查阅。

### 第三步

将弹窗加入到调度队列：

```objc
//配置对象
HLLPopupConfigure *configure = [[HLLPopupConfigure alloc] init];
configure.sceneStyle = HLLPopupSceneHalfPage;
//加入到弹窗调度中
[HLLPopupsManager addPopup:contextView options:configure];

```

`PopupsManager`还提供了几种便捷方法，可以根据具体情况具体使用：

```objc
//采用默认配置，无需创建一个配置对象了
+ (void)addPopup:(id<HLLPopupInterface>)popup;

//只用到优先级配置属性，可以这样调用
+ (void)addPopup:(id<HLLPopupInterface>)popup priority:(HLLPopupStrategyPriority)priority;
```

## Author 
 [HUOLALA mobile technology team](https://juejin.cn/user/1768489241815070).
## License
```
Copyright 2023 Huolala, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
