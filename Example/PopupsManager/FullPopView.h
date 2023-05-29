//
//  FullPopView.h
//  PopupsManager_Example
//
//  Created by Kris on 2023/3/29.
//  Copyright © 2023 liuzf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HLLPopupsManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface FullPopView : UIView<HLLPopupInterface>
@property (nonatomic, copy) dispatch_block_t popViewDismissBlock;
@end

NS_ASSUME_NONNULL_END
