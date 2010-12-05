#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ZTWebSocket.h"
#import "HTTPOperation.h"

@class Account;
@class WelcomeViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, ZTWebSocketDelegate, HTTPOperationDelegate> {
	Account *myAccount;

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
	WelcomeViewController *viewController;
	
	NSArray *Sexes;
	NSArray *Ethnicities;
	NSArray *Likes;
}

@property (nonatomic, retain) Account *myAccount;

@property (nonatomic, retain) ZTWebSocket *webSocket;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) WelcomeViewController *viewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

@property (nonatomic, retain) NSArray *Sexes;
@property (nonatomic, retain) NSArray *Ethnicities;
@property (nonatomic, retain) NSArray *Likes;

- (NSString *)applicationDocumentsDirectory;
- (void)findLocation;

@end
