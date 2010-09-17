#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ZTWebSocket.h"

@class User;
@class UsersViewController;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, ZTWebSocketDelegate> {
	User *me;

	SystemSoundID receiveMessageSound;

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

@property (nonatomic, retain) User *me;

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
