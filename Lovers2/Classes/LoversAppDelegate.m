//
//  LoversAppDelegate.m
//  Lovers
//
//  Created by Abhinav Sharma on 7/18/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import "LoversAppDelegate.h"

@implementation LoversAppDelegate

@synthesize window,controller,navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [window release];
	[controller release];
	[navigationController release];
    [super dealloc];
}


@end
