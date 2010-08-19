#import <CoreLocation/CoreLocation.h>

@class HomeViewController;



@interface LoversAppDelegate : NSObject <UIApplicationDelegate,  CLLocationManagerDelegate> {
	UIWindow *window;
	HomeViewController *controller;
	UINavigationController *navigationController;
	CLLocationManager *locationManager;
	NSMutableArray *locationMeasurements;
	CLLocation *bestEffortAtLocation;
	HomeViewController *homeViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HomeViewController *controller;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;


- (void) findLocation;

@end
