//
//  AppDelegate.m
//  DroppableViewTest
//
//  Created by Markus Emrich on 25.03.12.
//  Copyright 2012 Markus Emrich. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    // setup controller
    TestViewController* viewController = [[TestViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
