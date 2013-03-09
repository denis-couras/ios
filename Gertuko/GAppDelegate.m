//
//  GAppDelegate.m
//  Gertuko
//
//  Created by Nick Bender on 3/8/13.
//  Copyright (c) 2013 AngryMeerkat. All rights reserved.
//

#import "GAppDelegate.h"

#import "GViewController.h"

@implementation GAppDelegate

@synthesize window;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [[GViewController alloc] initWithNibName: nil bundle:nil]];
    
            [self.window makeKeyAndVisible];
    
    return YES;
}


@end
