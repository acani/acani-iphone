#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "ZTWebSocket.h"

@class UsersViewController;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, ZTWebSocketDelegate> {
	ZTWebSocket *webSocket;

	CLLocationManager *locationManager;
	NSMutableArray *locationMeasurements;
	CLLocation *bestEffortAtLocation;

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

	UIWindow *window;
	UINavigationController *navigationController;
	UsersViewController *usersViewController;
}

@property (nonatomic, retain) ZTWebSocket *webSocket;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UsersViewController *usersViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

- (NSString *)applicationDocumentsDirectory;
- (void)findLocation;

@end
