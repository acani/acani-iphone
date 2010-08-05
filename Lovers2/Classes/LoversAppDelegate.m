#import "LoversAppDelegate.h"
#import "HomeViewController.h"

@implementation LoversAppDelegate

@synthesize window,controller,navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	navigationController= [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
	[window addSubview:navigationController.view];	
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
