#import "LoversAppDelegate.h"
#import "UsersViewController.h"
#import "ProfileViewController.h"
#import "ChatViewController.h"

@implementation LoversAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ChatViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	return YES;
}

@end
