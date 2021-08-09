//
//  AppDelegate.m
//  FaceTest
//
//  Created by guojianheng on 2020/7/13.
//  Copyright © 2020 guojianheng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)


@interface AppDelegate ()

@end

@implementation AppDelegate

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation == 1) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.allowRotation = 0;
    
    self.window = [[UIWindow alloc]init];
        ViewController * vc = [[ViewController alloc]init];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    //    self.window.rootViewController = [[ViewController alloc]init]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
