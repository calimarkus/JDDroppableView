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
    mWindow = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    mWindow.backgroundColor = [UIColor whiteColor];
    
    TestViewController* viewController = [[TestViewController alloc] init];
    [mWindow addSubview: viewController.view];
    
    [mWindow makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc
{
    [mWindow release];
    [mViewController release];
    
    [super dealloc];
}

@end
