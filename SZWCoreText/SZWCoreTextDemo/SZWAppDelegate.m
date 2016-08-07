//
//  SZWRootViewController.m
//  SZWCoreText
//
//  GitHub:https://github.com/szweee
//  Blog:  http://www.szweee.com
//
//  Created by 索泽文 on 15/7/03.
//  Copyright © 2016年 索泽文. All rights reserved.
//

#import "SZWAppDelegate.h"
#import "SZWRootViewController.h"

@interface SZWNavBar : UINavigationBar
@end

@implementation SZWNavBar

- (CGSize)sizeThatFits:(CGSize)size{
    size = [super sizeThatFits:size];
    // 如果状态栏隐藏 NAVBar的高度返回64
    if ([UIApplication sharedApplication].statusBarHidden) {
        size.height = 64;
    }
    return size;
}

@end


@interface SZWNavController : UINavigationController
@end

@implementation SZWNavController

// 是否允许屏幕旋转
- (BOOL)shouldAutorotate{
    return YES;
}

// 支持屏幕旋转的方向 此处可直接返回UIInterfaceOrientationMask类型  可以返回多个
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // 仅支持竖屏
}

// 屏幕初始显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait; //竖屏
}

@end


@implementation SZWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SZWRootViewController *root = [SZWRootViewController new];
    SZWNavController *nav = [[SZWNavController alloc] initWithNavigationBarClass:[SZWNavBar class] toolbarClass:nil];
    [nav pushViewController:root animated:NO];
    
    self.rootViewController = nav;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.rootViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
