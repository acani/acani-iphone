#import <CoreLocation/CoreLocation.h>

@class HomeViewController;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	UIWindow *window;
	UINavigationController *navigationController;
	CLLocationManager *locationManager;
	NSMutableArray *locationMeasurements;
	CLLocation *bestEffortAtLocation;
	HomeViewController *homeViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) HomeViewController *homeViewController;

- (void)findLocation;

@end
