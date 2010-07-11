//
//  BubblesAppDelegate.m
//  Bubbles
//
//  Created by Rsg on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"

@implementation BubblesAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
