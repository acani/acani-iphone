#import "LoversAppDelegate.h"
#import "LoversViewController.h"

@implementation LoversAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	viewController = [[LoversViewController alloc] init];
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
