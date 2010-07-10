#import "ChatAppDelegate.h"

@implementation ChatAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	ChatViewController *hwvc = [[ChatViewController alloc] init];
	[window addSubview:hwvc.view];	
    [window makeKeyAndVisible];
	return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
