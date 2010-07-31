//
//  LoversAppDelegate.h
//  Lovers
//
//  Created by Abhinav Sharma on 7/18/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeViewController;

//enum downloadType {
//	json = 0,
//	thumbnail,
//	profilepic
//} downloadData;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	HomeViewController *controller;
	UINavigationController *navigationController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HomeViewController *controller;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

