<img src=Image/title.png width=100% height=100% />

[![license](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)
![Pod Version](https://img.shields.io/badge/pod-v1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Language](https://img.shields.io/badge/language-ObjectC-green.svg)

> [中文文档](README_CN.md) 
## 介绍

        HLLPopupsManager is a general-purpose pop-up window scheduling management component, which is mainly used in some complex business projects to effectively manage the display scheduling between various types of pop-up windows in the APP. It is more like a traffic light system at a complex intersection, effectively managing the normal passage of vehicles and pedestrians in all directions.

|Demo|<img src=image/演示.gif /> 

## Feature

- Support pop-up view customization
- Support adaptive keyboard input scene
- Support the display of pop-up windows according to the priority mode
- Support basic show and hide animation
- Support mixed scheduling of multiple types of pop-up windows
- Support batch removal of pop-up windows
- Support pop-up windows disappearing at regular intervals

## Require

- iOS 9.0 or higher
- Xcode 11.0 or later
- CocoaPods 1.11.2 or later

## Install

```ruby
pod 'PopupsManager'
```

## Use

### first step

Usually, our pop-up windows realize the page of the pop-up window by customizing a subclass of UIView. All you need to do is to let your custom View implement a protocol `HLLPopupInterface`, which will require your pop-up window to implement One required method: `- (UIView *)supplyCustomPopupView;
` The function of this method is to return your pop-up View class object to `HLLPopupsManager`

```objc
//.h
@interface xxx : UIView <HLLPopupInterface>
@end

//.m
#pragma mark - HLLPopupViewInterface
- (UIView *)supplyCustomPopupView {
    return self;
}

```
If your pop-up window object View is related to some existing logic classes, and the transformation process cannot separate the View, then you can let your other logic-related classes implement this protocol, and then give you in the protocol method The custom pop-up View can be returned:

```objc
//.h
@interface xxx : NSObject <HLLPopupInterface>
@end

//.m
@property (nonatomic, strong) UIView *customPopupView;
#pragma mark - HLLPopupViewInterface
- (UIView *)supplyCustomPopupView {
    return self.customPopupView;
}
```

### The second step

To configure your popup window, `HLLPopupsManager` provides a lot of configuration properties for popup window types, just need to set them.

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

For some attributes of these knowledge configurations, see the reference source code for details.

### third step

Add the popup to the dispatch queue:

```objc
//配置对象
HLLPopupConfigure *configure = [[HLLPopupConfigure alloc] init];
configure.sceneStyle = HLLPopupSceneHalfPage;
//加入到弹窗调度中
[HLLPopupsManager addPopup:contextView options:configure];

```

`HLLPopupsManager` also provides several convenience methods, which can be used according to specific situations:

```objc
+ (void)addPopup:(id<HLLPopupInterface>)popup;

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

