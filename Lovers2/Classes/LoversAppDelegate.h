@class HomeViewController;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	HomeViewController *controller;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HomeViewController *controller;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
