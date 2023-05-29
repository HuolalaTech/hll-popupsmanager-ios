//
//  HLLShowViewController.m
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import "HLLShowViewController.h"
#import <HLLPopupsManager.h>
#import "CenterPopView.h"
#import "BottomPopView.h"
#import "FullPopView.h"
#import "TopBarPopView.h"
#import "KeyboardPopView.h"
#import <Masonry/Masonry.h>

@implementation HLLShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"演示效果";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"开始演示" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickShow) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"优先级覆盖" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(clickShow1) forControlEvents:UIControlEventTouchUpInside];
    button1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(button);
        make.top.equalTo(button.mas_bottom).offset(10);
    }];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"通知条覆盖" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(clickShow2) forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(button);
        make.top.equalTo(button1.mas_bottom).offset(10);
    }];
}

- (void)clickShow {
//    [self showFullAdvert];
//    [self showBottomShare1];
    [self showCenter1];
}

- (void)clickShow1 {
    [self showBottomShare1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showCenter1];
    });
}

- (void)clickShow2 {
    [self showTopbar];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showTopbar1];
    });
}

- (void)showMorePopView {
    NSTimeInterval time = 0.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showBottomShare];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showTopbar];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showCenter];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self showBottomKeyboard];                        
                    });
                });
            });
        });
    });
}

- (void)showCenter {
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneCenter;
    config.clickOutsideDismiss = YES;
    config.cornerRadius = 8;
    config.popAnimationStyle = HLLPopAnimationStyleScale;
    config.aloneMode = YES;
    CenterPopView *centerPopView = [[CenterPopView alloc] init];
    [HLLPopupsManager addPopup:centerPopView options:config];
}

- (void)showCenter1 {
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneCenter;
    config.clickOutsideDismiss = YES;
    config.cornerRadius = 8;
    config.popAnimationStyle = HLLPopAnimationStyleScale;
    config.priority = 200;
    CenterPopView *centerPopView = [[CenterPopView alloc] init];
    [HLLPopupsManager addPopup:centerPopView options:config];
}

- (void)showBottomShare {
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneHalfPage;
    config.clickOutsideDismiss = YES;
    config.cornerRadius = 8;
    config.popAnimationStyle = HLLPopAnimationStyleScale;
    config.dismissAnimationStyle = HLLDismissAnimationStyleFade;
    config.aloneMode = YES;
    BottomPopView *bottomSharePopView = [[BottomPopView alloc] init];
    [HLLPopupsManager addPopup:bottomSharePopView options:config];
}

- (void)showBottomShare1 {
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneHalfPage;
    config.clickOutsideDismiss = YES;
    config.cornerRadius = 8;
    config.popAnimationStyle = HLLPopAnimationStyleScale;
    config.dismissAnimationStyle = HLLDismissAnimationStyleFade;
    config.priority = 100;
    BottomPopView *bottomSharePopView = [[BottomPopView alloc] init];
    [HLLPopupsManager addPopup:bottomSharePopView options:config];
}

- (void)showFullAdvert{
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneFull;
    config.aloneMode = YES;
    config.dismissDuration = 3;
    FullPopView *popView = [[FullPopView alloc] init];
    popView.popViewDismissBlock = ^{
        [self showMorePopView];
    };
    [HLLPopupsManager addPopup:popView options:config];
}

- (void)showTopbar{
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneTopNoticeView;
    config.dismissDuration = 3;
    config.cornerRadius = 8;
    config.aloneMode = YES;
    TopBarPopView *topBar = [[TopBarPopView alloc] init];
    [HLLPopupsManager addPopup:topBar options:config];
}

- (void)showTopbar1{
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneTopNoticeView;
    config.dismissDuration = 3;
    config.cornerRadius = 8;
    config.priority = 100;
    TopBarPopView *topBar = [[TopBarPopView alloc] init];
    [HLLPopupsManager addPopup:topBar options:config];
}

- (void)showBottomKeyboard{
    HLLPopupConfigure *config = [[HLLPopupConfigure alloc] init];
    config.sceneStyle = HLLPopupSceneHalfPage;
    config.cornerRadius = 8;
    config.aloneMode = YES;
    config.clickOutsideDismiss = YES;
    KeyboardPopView *popView = [[KeyboardPopView alloc] init];
    [HLLPopupsManager addPopup:popView options:config];
}

- (void)dealloc {
    NSLog(@"控制器释放");
}

@end
