#import <UIKit/UIKit.h>

@class BubblesViewController;

@interface BubblesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BubblesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BubblesViewController *viewController;

@end
