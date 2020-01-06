//
//  UUTool.h
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUTool : NSObject


/// 获取当前window的控制器
+ (UIViewController *)getCurrentVC;

@end

NS_ASSUME_NONNULL_END
