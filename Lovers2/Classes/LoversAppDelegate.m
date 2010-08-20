#import "LoversAppDelegate.h"
#import "HomeViewController.h"

@implementation LoversAppDelegate

@synthesize window, navigationController;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	homeViewController = [[HomeViewController alloc] init];
	navigationController= [[UINavigationController alloc] initWithRootViewController:homeViewController];
	[window addSubview:navigationController.view];	
    [window makeKeyAndVisible];	
	[self findLocation];
	return YES;
}


- (void)dealloc {
    [window release];
	[navigationController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Location manager interactions

- (void) findLocation {
	//ask matt if we should use presentModelviewcontroller like urbanspoon to use last location
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.delegate = self;
   
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationManager startUpdatingLocation];
    //[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:[[setupInfo objectForKey:kSetupInfoKeyTimeout] doubleValue]];
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (locationMeasurements == nil) {
		self.locationMeasurements = [NSMutableArray array];
	}
	[locationMeasurements addObject:newLocation];
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
	if (newLocation.horizontalAccuracy < 0) return;
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort" as well as setting HomeViewController's CLlocation
        self.bestEffortAtLocation = newLocation;
		homeViewController.location = newLocation;
                if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
					[manager stopUpdatingLocation];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
			// [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        [manager stopUpdatingLocation];
    }
}


@end
