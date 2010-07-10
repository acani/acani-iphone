#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface ChatAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	ChatViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChatViewController *viewController;

@end
