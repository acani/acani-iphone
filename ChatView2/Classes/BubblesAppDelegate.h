//
//  BubblesAppDelegate.h
//  Bubbles
//
//  Created by Rsg on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BubblesViewController;

@interface BubblesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BubblesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BubblesViewController *viewController;

@end

