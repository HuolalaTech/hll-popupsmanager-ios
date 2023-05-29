//
//  HLLWindowManager.m
//
//  Created by Kris on 2021/8/24.
//

#import "HLLPopupsManager.h"

/* 弹窗背景视图 */
@interface HLLPopViewBgView : UIView
//是否隐藏背景 default:NO
@property (nonatomic, assign, getter=isHiddenBg) BOOL hiddenBg;
@end

@implementation HLLPopViewBgView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && self.isHiddenBg){
        return nil;
    }
    return hitView;
}
@end

/** 弹窗对象模型 */
@interface HLLPopupModel : NSObject<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id popupObj;//弹窗内容对象
@property (nonatomic, strong) HLLPopupConfigure *config;//弹窗的配置
@property (nonatomic, strong) HLLPopViewBgView *popupBgView;//弹窗背景
@property (nonatomic, assign) BOOL isValidModel;//校验模型是否有效
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) NSTimer *timer;//定时器
@property (nonatomic, assign) NSTimeInterval dismissTime;
@end

@implementation HLLPopupModel

- (BOOL)isValidModel {
    if (!self.config ||
        !self.popupBgView ||
        !_popupObj ||
        CGSizeEqualToSize(_popupBgView.bounds.size, CGSizeZero)) {
        return NO;
    }
    return YES;
}

- (void)setConfig:(HLLPopupConfigure *)config {
    _config = config;
    if (config.dismissDuration > 0) {
        _dismissTime = config.dismissDuration;
    }
}

- (UIView *)contentView {
    return (UIView *)[_popupObj supplyCustomPopupView];
}

//给自定义的弹窗内容设置圆角
- (void)setupCustomViewCorners {
    [self.popupBgView layoutIfNeeded];
    BOOL isSetCorner = NO;
    if (self.config.rectCorners & UIRectCornerTopLeft) {
        isSetCorner = YES;
    }
    if (self.config.rectCorners & UIRectCornerTopRight) {
        isSetCorner = YES;
    }
    if (self.config.rectCorners & UIRectCornerBottomLeft) {
        isSetCorner = YES;
    }
    if (self.config.rectCorners & UIRectCornerBottomRight) {
        isSetCorner = YES;
    }
    if (self.config.rectCorners & UIRectCornerAllCorners) {
        isSetCorner = YES;
    }
    
    if (isSetCorner && self.config.rectCorners > 0) {
        UIView *cornerRadiusView = [self contentView];
        if ([self.popupObj respondsToSelector:@selector(needSetCornerRadiusView)]) {
            UIView *view = [self.popupObj needSetCornerRadiusView];
            if (view && CGSizeEqualToSize(view.bounds.size, CGSizeZero) != YES) {
                cornerRadiusView = view;
            }
        }
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:cornerRadiusView.bounds
                                                    byRoundingCorners:self.config.rectCorners
                                                          cornerRadii:CGSizeMake(self.config.cornerRadius, self.config.cornerRadius)];
        CAShapeLayer * layer = [[CAShapeLayer alloc]init];
        layer.frame = cornerRadiusView.bounds;
        layer.path = path.CGPath;
        cornerRadiusView.layer.mask = layer;
    }
}

//开始倒计时
- (void)startCountTime {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerLoopExecute) userInfo:nil repeats:YES];
    //加入runloop循环池
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    //开启定时器
    [_timer fire];
}

- (void)closeTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _dismissTime = self.config.dismissDuration;//定时器计数复原
}

- (void)timerLoopExecute {
    if (self.dismissTime < 1) {
        [self closeTimer];
        //关闭弹窗
        [HLLPopupsManager dismissWithPopup:self.popupObj];
        return;
    }
    self.dismissTime --;
    if ([self.popupObj respondsToSelector:@selector(countTimeWithCount:)]) {
        [self.popupObj countTimeWithCount:self.dismissTime];
    }
}

#pragma mark - 手势处理

//添加相关手势
- (void)addGestureRecognizer {
    //弹窗背景添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popupBgViewTap:)];
    tap.delegate = self;
    [self.popupBgView addGestureRecognizer:tap];
    
    //添加上滑手势
    if (self.config.needNoticeBarPanGesture) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(popupBgViewPan:)];
        panGesture.delegate = self;
        [self.popupBgView addGestureRecognizer:panGesture];
    }

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:[self contentView]] && self.config.sceneStyle != HLLPopupSceneTopNoticeView) {
        return NO;
    }
    return YES;
}

//背景手势回调
- (void)popupBgViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.config.clickOutsideDismiss) {
        [self.popupBgView endEditing:YES];
        [HLLPopupsManager dismissWithPopup:self.popupObj];
    }
}

- (void)popupBgViewPan:(UIPanGestureRecognizer *)gestureRecognizer {
    // 获取手指的偏移量
    CGPoint transP = [gestureRecognizer translationInView:[self contentView]];
    CGRect originFrame = self.originalFrame;
    if (transP.y < 0) {
        CGFloat offy = (originFrame.origin.y + originFrame.size.height/2) - ABS(transP.y);
        [self contentView].layer.position = CGPointMake([self contentView].layer.position.x, offy);
    }else{
        [self contentView].frame = self.originalFrame;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (ABS(transP.y) >= (self.originalFrame.size.height/2)) {
            //向上滑动了至少内容的一半高度，触发关闭弹窗
            [HLLPopupsManager dismissWithPopup:self.popupObj];
        }else{
            [self contentView].frame = self.originalFrame;//复原
        }
    }
}

#pragma mark - Keyboard

- (void)addKeyboardMonitor {
    id observer = self;
    //键盘将要显示
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //键盘显示完毕
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    //键盘frame将要改变
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    //键盘frame改变完毕
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    //键盘将要收起
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //键盘收起完毕
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

#pragma mark - 键盘事件处理

- (void)keyboardWillShow:(NSNotification *)notification{
    self.config.keyboardWillShowCallback ? self.config.keyboardWillShowCallback() : nil;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardMaxY = keyboardEedFrame.origin.y;
    CGPoint popViewPoint = [self contentView].layer.position;
    CGFloat currMaxY = popViewPoint.y + [self contentView].frame.size.height/2;
    CGFloat offY = currMaxY - keyboardMaxY;
    if (keyboardMaxY < currMaxY) {//键盘被遮挡
        //执行动画
        CGPoint originPoint = [self contentView].layer.position;
        [UIView animateWithDuration:duration animations:^{
            [self contentView].layer.position = CGPointMake(originPoint.x, originPoint.y - offY);
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
    self.config.keyboardDidShowCallback ? self.config.keyboardDidShowCallback() : nil;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.config.keyboardWillHideCallback ? self.config.keyboardWillHideCallback() : nil;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self contentView].frame = self.originalFrame;
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    self.config.keyboardDidHideCallback ? self.config.keyboardDidHideCallback() : nil;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    if (self.config.keyboardFrameWillChange) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.config.keyboardFrameWillChange(keyboardBeginFrame,keyboardEedFrame,duration);
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
    if (self.config.keyboardFrameDidChange) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.config.keyboardFrameDidChange(keyboardBeginFrame,keyboardEedFrame,duration);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - 弹窗调度管理器
@interface HLLPopupsManager ()
//window弹窗存放的缓存队列
@property (nonatomic, strong) NSMutableArray<HLLPopupModel *> *windowQueue;
//等待删除的弹窗模型
@property (nonatomic, strong) NSHashTable <HLLPopupModel *> *waitRemovePool;
@end

@implementation HLLPopupsManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static HLLPopupsManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self defaultManager];
}

#pragma mark - Public API

+ (void)addPopup:(id<HLLPopupInterface>)popup {
    HLLPopupsManager *manage = [HLLPopupsManager defaultManager];
    [manage addPopup:popup
                   priority:0
                    options:nil];
}

+ (void)addPopup:(id<HLLPopupInterface>)popup priority:(HLLPopupStrategyPriority)priority{
    HLLPopupsManager *manage = [HLLPopupsManager defaultManager];
    [manage addPopup:popup
                   priority:priority
                    options:nil];
}

+ (void)addPopup:(id<HLLPopupInterface>)popup options:(HLLPopupConfigure *)options{
    HLLPopupsManager *manage = [HLLPopupsManager defaultManager];
    [manage addPopup:popup
                   priority:0
                    options:options];
}

//新增弹窗
- (void)addPopup:(id<HLLPopupInterface>)popup priority:(HLLPopupStrategyPriority)priority options:(HLLPopupConfigure *)options{
    if (!popup || ![[self class] checkMainThread]) {
        return;
    }
    //弹窗配置对象
    HLLPopupConfigure *config = [HLLPopupConfigure new];
    if (options) {
        config = [options copy];
    }else{
        if (priority != 0) {
            config.priority = priority;
        }
    }
    [config configureDefaultParams];//配置默认参数
    config.containerView = config.containerView ? config.containerView : [UIApplication sharedApplication].keyWindow;
    CGRect popupFrame = config.containerView.bounds;
    if (CGSizeEqualToSize(popupFrame.size, CGSizeZero)) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        popupFrame =  CGRectMake(0, 0, size.width, size.height);
    }

    //弹窗数据模型
    HLLPopupModel *model = [[HLLPopupModel alloc] init];
    model.config = config;
    model.popupObj = popup;
    HLLPopViewBgView *bgView = [[HLLPopViewBgView alloc] initWithFrame:popupFrame];
    bgView.backgroundColor = config.backgroundColor;
    bgView.hiddenBg = config.isHiddenBackgroundView;
    model.popupBgView = bgView;
    
    if (![popup conformsToProtocol:@protocol(HLLPopupInterface)]) {
        return;
    }
    //将弹窗内容视图添加到弹窗背景视图中
    [model.popupBgView addSubview:[popup supplyCustomPopupView]];
    //增加相关手势处理
    [model addGestureRecognizer];
    //适配键盘
    [model addKeyboardMonitor];
    //pop
    [self popWithModel:model isRecover:NO];
}

+ (void)dismissWithPopup:(id<HLLPopupInterface>)popup {
    if (!popup || ![self checkMainThread]) {
        return;
    }
    HLLPopupModel *model = [[HLLPopupsManager defaultManager] getModelWithPopup:popup];
    if (model) {
        [[HLLPopupsManager defaultManager] dismissWithModel:model];
    }
}

+ (void)dismissPopupWithIdentifier:(NSString *)identifier {
    if (!identifier || identifier.length < 1 || ![self checkMainThread]) {
        return;
    }
    HLLPopupModel *model = [[HLLPopupsManager defaultManager] getModelWithIdentifirer:identifier];
    if (model) {
        [[HLLPopupsManager defaultManager] dismissWithModel:model];
    }
}

+ (void)removeAllPopupFromContainerView:(UIView *)containerView {
    if (![self checkMainThread]) {
        return;
    }
    UIView *view = containerView;
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    NSArray *arr = [[HLLPopupsManager defaultManager] getAllPopViewFromContainerView:view];
    if (arr.count < 1) {
        return;
    }
    NSMutableArray *waitRemoveArr = [[NSMutableArray alloc] initWithArray:arr];
    //移除之前所有的弹窗
    while (waitRemoveArr.count) {
        HLLPopupModel *model = waitRemoveArr.lastObject;
        if ([model.popupObj respondsToSelector:@selector(popupViewDidDisappear)]) {
            [model.popupObj popupViewDidDisappear];
        }
        [model.popupBgView removeFromSuperview];
        [waitRemoveArr removeLastObject];
    }
    [[HLLPopupsManager defaultManager].windowQueue removeObjectsInArray:arr];
}

+ (void)removeAllPopup {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (HLLPopupModel *itemModel in [HLLPopupsManager defaultManager].windowQueue) {
        //剔除通知条类型的
        if (itemModel.config.sceneStyle != HLLPopupSceneTopNoticeView) {
            [array addObject:itemModel];
        }
    }
    NSMutableArray *waitRemoveArr = [[NSMutableArray alloc] initWithArray:array];
    //移除之前所有的弹窗
    while (waitRemoveArr.count) {
        HLLPopupModel *model = waitRemoveArr.lastObject;
        if ([model.popupObj respondsToSelector:@selector(popupViewDidDisappear)]) {
            [model.popupObj popupViewDidDisappear];
        }
        [model.popupBgView removeFromSuperview];
        [waitRemoveArr removeLastObject];
    }
    [[HLLPopupsManager defaultManager].windowQueue removeObjectsInArray:array];

}

+ (NSInteger)getAllPopupCountFromContainerView:(UIView *)containerView {
    if (![self checkMainThread]) {
        return 0;
    }
    UIView *view = containerView;
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    NSArray *arr = [[HLLPopupsManager defaultManager] getAllPopViewFromContainerView:view];
    return arr.count;
}

+ (NSInteger)getTotalPopupCount {
    if (![self checkMainThread]) {
        return 0;
    }
    return [HLLPopupsManager defaultManager].windowQueue.count;
}

#pragma mark - Pop

- (void)popWithModel:(HLLPopupModel *)model isRecover:(BOOL)isRecover {
    if (!model || !model.isValidModel) {
        return;
    }
    //移除掉前面指定数组内的弹窗
    void(^clearAgoPopsBlock)(NSArray *) = ^(NSArray *list){
        if (list.count < 1) {
            return;
        }
        NSMutableArray *waitRemoveArr = [[NSMutableArray alloc] initWithArray:list];
        //移除之前所有的弹窗
        while (waitRemoveArr.count) {
            [self dismissWithModel:waitRemoveArr.lastObject isRemoveQueue:YES];
            [waitRemoveArr removeLastObject];
        }
    };
    
    if (model.config.isAloneMode) {//isAloneMode模式只会把相同的Group下的弹窗移除
        NSArray *popupsList = [self getPopupsFromAllPopupsWithGroupId:model.config.groupID];
        clearAgoPopsBlock(popupsList);
    }
    
    if(model.config.isTerminatorMode){//isTerminatorMode模式把不同的Group下的弹窗都给移除
        NSArray *popupsList = self.windowQueue;
        clearAgoPopsBlock(popupsList);
    }else{
        //根据优先级叠加展示，被叠加的弹窗会隐藏看不到,无论是加到哪个容器里面的弹窗都会放到一起进行优先级比对
        NSArray *allPopModelArr = [self getPopupsFromAllPopupsWithGroupId:model.config.groupID];
        if (allPopModelArr.count && !isRecover) {
            HLLPopupModel *lastModel = allPopModelArr.lastObject;
            //如果新进来的弹窗优先级比当前展示的弹窗优先级高
            if (model.config.priority >= lastModel.config.priority) {
                [lastModel.popupBgView endEditing:YES];
                //当前组展示的弹窗被优先级高的顶替掉了
                [self dismissWithModel:lastModel isRemoveQueue:NO];
            }else{
                [self enterPopWindsQueueWithModel:model];//先入列排队等待展示
                return;
            }
        }
    }
    if (!model.popupBgView.superview) {
        [model.config.containerView addSubview:model.popupBgView];
        [model.config.containerView bringSubviewToFront:model.popupBgView];
    }
    //弹窗内容自定义布局
    if ([model.popupObj respondsToSelector:@selector(layoutWithSuperView:)]) {
        [model.popupObj layoutWithSuperView:model.popupBgView];
    }
    //获取到业务中ContentView的frame
    [model.popupBgView layoutIfNeeded];
    //缓存弹窗内容的原始frame
    model.originalFrame = [model.popupObj supplyCustomPopupView].frame;
    //开启定时器
    if (model.config.dismissDuration >= 1) {
        [model startCountTime];
    }
    //pop动画
    [self popAnimationWithPopViewModel:model isNeedAnimation:YES];
    //入列
    if (!isRecover) {
        [self enterPopWindsQueueWithModel:model];
    }
    //配置圆角
    [model setupCustomViewCorners];
    //将要展示回调
    model.config.popViewDidShowCallback ? model.config.popViewDidShowCallback() : nil;
    if ([model.popupObj respondsToSelector:@selector(popupViewDidAppear)]) {
        [model.popupObj popupViewDidAppear];
    }
}

//执行pop动画
- (void)popAnimationWithPopViewModel:(HLLPopupModel *)model isNeedAnimation:(BOOL)isNeedAnimation {
    if (!isNeedAnimation) {
        //不需要动画就基础渐隐展示即可
        [self baseAlphaChangeWithModel:model isPop:YES];
        return;
    }
    if ([model.popupObj respondsToSelector:@selector(executeCustomAnimation)]) {
        [self baseAlphaChangeWithModel:model isPop:YES];
        [model.popupObj executeCustomAnimation];
        return;
    }
    //背景动画执行
    model.popupBgView.backgroundColor = [self drawBackgroundViewColorWith:model.config.backgroundColor
                                                                     alpha:0
                                                                 withModel:model];
    [model contentView].alpha = 1.0f;
    [UIView animateWithDuration:model.config.popAnimationTime animations:^{
        model.popupBgView.backgroundColor = [self drawBackgroundViewColorWith:model.config.backgroundColor
                                                                         alpha:model.config.backgroundAlpha
                                                                     withModel:model];
    }];
    CGSize popViewSize = model.originalFrame.size;
    CGPoint originPoint = model.originalFrame.origin;
    CGPoint startPosition = CGPointMake(originPoint.x + popViewSize.width/2, originPoint.y + popViewSize.height/2);
    switch (model.config.sceneStyle) {
        case HLLPopupSceneHalfPage:{
            UIView *contentView = [model contentView];
            contentView.layer.position = CGPointMake(contentView.layer.position.x, CGRectGetMaxY(model.popupBgView.frame) + model.originalFrame.size.height*0.5);
            [UIView animateWithDuration:model.config.popAnimationTime
                                  delay:0
                 usingSpringWithDamping:1
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                contentView.layer.position = startPosition;
            } completion:nil];

        }break;
        case HLLPopupSceneTopNoticeView:{
            UIView *contentView = [model contentView];
            contentView.layer.position = CGPointMake(contentView.layer.position.x,-(model.originalFrame.size.height*0.5));
            [UIView animateWithDuration:model.config.popAnimationTime
                                  delay:0
                 usingSpringWithDamping:1
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                
                contentView.layer.position = startPosition;
            } completion:nil];
        }break;
        case HLLPopupSceneCenter:{
            [self handlePopAnimaationForCenterSceneWithModel:model];
        }break;
        default:
            break;
    }
}

//执行center scene 类型的配置动画
- (void)handlePopAnimaationForCenterSceneWithModel:(HLLPopupModel *)model {
    UIView *contentView = [model contentView];
    CGPoint startPosition = contentView.layer.position;
    switch (model.config.popAnimationStyle) {
        case HLLPopAnimationStyleFade:{
            //基础渐显动画
            [self baseAlphaChangeWithModel:model isPop:YES];
            return;
        }break;
        case HLLPopAnimationStyleFallTop:{
            contentView.layer.position = CGPointMake(contentView.layer.position.x, CGRectGetMidY(model.popupBgView.frame) - model.originalFrame.size.height*0.5);
        }break;
        case HLLPopAnimationStyleRiseBottom:{
            contentView.layer.position = CGPointMake(contentView.layer.position.x, CGRectGetMaxY(model.popupBgView.frame) + model.originalFrame.size.height*0.5);
        }break;
        case HLLPopAnimationStyleScale:{
            [self baseAlphaChangeWithModel:model isPop:YES];
            //先变大后恢复至原始大小
            [self animationWithLayer:[model contentView].layer
                            duration:(model.config.popAnimationTime)
                              values:@[@0.0, @1.2, @1.0]];
            return;
        }break;
        default:
            break;
    }
    
    [UIView animateWithDuration:model.config.popAnimationTime
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        contentView.layer.position = startPosition;
    } completion:nil];
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values {
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = duration;
    popAnimation.values = @[
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.timingFunctions = @[
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [layer addAnimation:popAnimation forKey:nil];
}


//搭配动画展示
- (void)baseAlphaChangeWithModel:(HLLPopupModel *)model isPop:(BOOL)isPop {
    if (isPop) {
        model.popupBgView.backgroundColor = [self drawBackgroundViewColorWith:model.config.backgroundColor
                                                                         alpha:0
                                                                     withModel:model];
        [model contentView].alpha = 0.0f;
        [UIView animateWithDuration:model.config.popAnimationTime animations:^{
            model.popupBgView.backgroundColor = [self drawBackgroundViewColorWith:model.config.backgroundColor
                                                                             alpha:model.config.backgroundAlpha
                                                                         withModel:model];
            [model contentView].alpha = 1.0f;
        }];
    }else{
        [UIView animateWithDuration:model.config.dismissAnimationTime animations:^{
            model.popupBgView.backgroundColor = [self drawBackgroundViewColorWith:model.config.backgroundColor
                                                                             alpha:0
                                                                         withModel:model];
            [model contentView].alpha = 0.0f;
        }];
    }
}


#pragma mark - Dismiss

- (void)dismissWithModel:(HLLPopupModel *)model {
    [self dismissWithModel:model isRemoveQueue:YES];
}

- (void)dismissWithModel:(HLLPopupModel *)model isRemoveQueue:(BOOL)isRemoveQueue {
    if (isRemoveQueue) {
        [self divertToWaitRemoveQueueWithModel:model];//存放入待移除的队列中
    }
    NSInteger queueCount = [self getPopupsFromAllPopupsWithGroupId:model.config.groupID].count;
    if (!model.config.isAloneMode && (isRemoveQueue && queueCount >= 1)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(model.config.dismissAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (queueCount >= 1) {
                //如果当前移除的弹窗之前还有被覆盖的，则把之前的重新展示出来
                NSArray *allArr = [self getPopupsFromAllPopupsWithGroupId:model.config.groupID];
                HLLPopupModel *lastItem = allArr.lastObject;
                //开启定时器
                if (lastItem.config.dismissDuration >= 1) {
                    [lastItem startCountTime];
                }
                //pop动画
                [self popAnimationWithPopViewModel:lastItem isNeedAnimation:YES];
            }
        });
    }
    //执行动画
    BOOL needDismissAnimation = YES;
    if ((model.config.sceneStyle == HLLPopupSceneTopNoticeView || model.config.sceneStyle == HLLPopupSceneCenter) && !isRemoveQueue) {
        needDismissAnimation = NO;
    }
    [self dismissAnimationWithPopViewModel:model isNeedAnimation:needDismissAnimation];
    if (model.config.dismissDuration > 0) {
        [model closeTimer];
    }
    if (isRemoveQueue) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(model.config.dismissAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //将要关闭
            model.config.popViewDidDismissCallback ? model.config.popViewDidDismissCallback() : nil;
            if ([model.popupObj respondsToSelector:@selector(popupViewDidDisappear)]) {
                [model.popupObj popupViewDidDisappear];
            }
            [model closeTimer];
            [model.popupBgView removeFromSuperview];
        });
    }
}

- (void)dismissAnimationWithPopViewModel:(HLLPopupModel *)model isNeedAnimation:(BOOL)isNeedAnimation {
    [self baseAlphaChangeWithModel:model isPop:NO];
    if (!isNeedAnimation) {
        return;
    }
    switch (model.config.sceneStyle) {
        case HLLPopupSceneHalfPage:{
            UIView *contentView = [model contentView];
            [UIView animateWithDuration:model.config.dismissAnimationTime
                             animations:^{
                contentView.layer.position = CGPointMake(contentView.layer.position.x, CGRectGetMaxY(model.popupBgView.frame) + model.originalFrame.size.height*0.5);
            }];
        }break;
        case HLLPopupSceneTopNoticeView:{
            UIView *contentView = [model contentView];
            [UIView animateWithDuration:model.config.dismissAnimationTime
                             animations:^{
                contentView.layer.position = CGPointMake(contentView.layer.position.x,-(model.originalFrame.size.height*0.5));
            }];
        }break;
        default:
            break;
    }
}

#pragma mark - Getter

- (NSMutableArray<HLLPopupModel *> *)windowQueue {
    if (!_windowQueue) {
        _windowQueue = [[NSMutableArray alloc] init];
    }
    return _windowQueue;
}

- (NSHashTable<HLLPopupModel *> *)waitRemovePool {
    if (!_waitRemovePool) {
        _waitRemovePool = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _waitRemovePool;
}

#pragma mark - Helper

- (NSArray *)getPopupsFromAllPopupsWithGroupId:(NSString *)groupId {
    return [self getSameGroupPopupsWithGroupId:groupId popupList:self.windowQueue];
}

//筛选出给定弹窗数组中相同GroupID的弹窗模型
- (NSArray *)getSameGroupPopupsWithGroupId:(NSString *)groupId popupList:(NSArray *)popupList {
    if (popupList.count < 1) {
        return nil;
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    for (HLLPopupModel *itemModel in popupList) {
        if (itemModel.config.groupID == nil && groupId == nil) {
            [resultArr addObject:itemModel];//没有设置分组，即为同一默认组
            continue;
        }
        if ([itemModel.config.groupID isEqualToString:groupId]) {
            [resultArr addObject:itemModel];
            continue;
        }

    }
    return [resultArr copy];
}

//取出同一容器内的相同Group的弹窗
- (NSArray *)getAllPopViewWithModel:(HLLPopupModel *)model {
    NSArray *allPops = [self getAllPopViewFromContainerView:model.config.containerView];
    return [self getSameGroupPopupsWithGroupId:model.config.groupID popupList:allPops];
}

//获取同一个容器中的所有未移除的弹窗（包含所有Group）
- (NSArray *)getAllPopViewFromContainerView:(UIView *)containerView {
    NSMutableArray *fromArr = self.windowQueue;
    NSMutableArray *toArr = [NSMutableArray array];
    for (HLLPopupModel *item in fromArr) {
        if ([item.config.containerView isEqual:containerView]) {
            [toArr addObject:item];
        }
    }
    return [NSArray arrayWithArray:toArr];
}

//进入队列的元素都要进行优先级排序，优先级最高的放到数组的末尾
- (void)enterPopWindsQueueWithModel:(HLLPopupModel *)model {
    for (HLLPopupModel *item in self.windowQueue) {
        if (item == model) {
            return;
        }
    }
    [self.windowQueue addObject:model];
    if (self.windowQueue.count < 2) {
        return;
    }
    //插入排序进行优先级调整
    HLLPopupModel *lastModel = self.windowQueue.lastObject;
    NSInteger i = self.windowQueue.count - 1;
    NSInteger j = i-1;
    while (j >= 0 && self.windowQueue[j].config.priority > lastModel.config.priority) {
        [self.windowQueue replaceObjectAtIndex:j+1 withObject:self.windowQueue[j]];
        j--;
    }
    self.windowQueue[j+1] = lastModel;
}

//将需要移除的弹窗转移到另外一个队列
- (void)divertToWaitRemoveQueueWithModel:(HLLPopupModel *)model {
    NSArray *allArr = [self getAllPopViewFromContainerView:model.config.containerView];
    [allArr enumerateObjectsUsingBlock:^(HLLPopupModel *obj, NSUInteger idx, BOOL * stop) {
        if ([obj.popupObj isEqual:model.popupObj]) {
            [self.waitRemovePool addObject:model];
            [self.windowQueue removeObject:model];
        }
    }];
}

- (HLLPopupModel *)getModelWithPopup:(id<HLLPopupInterface>)popup {
    if (!popup) {
        return nil;
    }
    for (HLLPopupModel *itemModel in self.windowQueue) {
        if (itemModel.popupObj == popup) {
            return itemModel;
        }
    }
    return nil;
}

- (HLLPopupModel *)getModelWithIdentifirer:(NSString *)identifirer {
    if (!identifirer || identifirer.length < 1) {
        return nil;
    }
    for (HLLPopupModel *itemModel in self.windowQueue) {
        if ([itemModel.config.identifier isEqualToString:identifirer]) {
            return itemModel;
        }
    }
    return nil;
}

- (UIColor *)drawBackgroundViewColorWith:(UIColor *)color alpha:(CGFloat)alpha withModel:(HLLPopupModel *)model {
    if (model.popupBgView.isHiddenBg) {
        return UIColor.clearColor;
    }
    if (model.config.backgroundColor == UIColor.clearColor) {
        return UIColor.clearColor;
    }
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat resAlpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&resAlpha];
    UIColor *resColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return resColor;
}

- (NSArray<id<HLLPopupInterface>> *)allPopups {
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:self.windowQueue.count];
    for (HLLPopupModel *itemModel in self.windowQueue) {
        if (itemModel.popupObj) {
            [res addObject:itemModel.popupObj];
        }
    }
    return [res copy];
}

+ (BOOL)checkMainThread {
    BOOL isMainThread = [NSThread currentThread].isMainThread;
    if (!isMainThread) {
        NSLog(@"⚠️弹窗调度使用必须在主线程中进行");
    }
    return isMainThread;
}

@end
