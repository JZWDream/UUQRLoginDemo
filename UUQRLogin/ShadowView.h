//
//  ShadowView.h
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShadowView : UIView
@property (nonatomic, assign) CGSize uu_showSize;//透明矩形的尺寸

/// 开始扫码
- (void)uu_scanStart;

/// 停止扫码
- (void)uu_scanStop;

@end

NS_ASSUME_NONNULL_END
