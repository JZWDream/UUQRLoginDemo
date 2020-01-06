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
@property (nonatomic, assign) CGSize showSize;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
