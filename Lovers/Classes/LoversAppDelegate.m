#import "LoversAppDelegate.h"
#import "LoversViewController.h"

@implementation LoversAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[LoversViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	return YES;
}

@end
