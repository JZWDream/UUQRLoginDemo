//
//  UUTool.m
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import "UUTool.h"

@implementation UUTool

+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    
    UIWindow* window = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].delegate.window;
    }
    
    UIViewController *rootVC = window.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)rootVC visibleViewController];
    } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)rootVC selectedViewController];
    } else if ([rootVC isKindOfClass:[UIViewController class]]) {
        result = rootVC;
    } else {
        
    }
    
    return result;
}

@end
