#import "LoversAppDelegate.h"
#import "UsersViewControllerOld.h"
#import "ChatViewController.h"
#import "Account.h"
#import "User.h"
#import "Message.h"
#import "ZTWebSocket.h"
#import "SBJSON.h"
#import "Constants.h"

@implementation LoversAppDelegate

@synthesize window;
@synthesize myAccount;
@synthesize navigationController;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize locationManager;
@synthesize usersViewController;
@synthesize webSocket;
@synthesize Sexes;
@synthesize Ethnicities;
@synthesize Likes;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create window, navigationController & usersViewController
	usersViewController = [[UsersViewControllerOld alloc] init];
	navigationController = [[UINavigationController alloc]
							initWithRootViewController:usersViewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;

    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

	// Initialize Core Data's managedObjectContext
	NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
		NSLog(@"managedObjectContext error!");
    }

//	// Pass the managed object context to the view controller.
//    usersViewController.managedObjectContext = context;

	webSocket = [[ZTWebSocket alloc] initWithURLString:@"ws://localhost:8124/" delegate:self];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSMutableArray *accounts = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (accounts == nil) {
		// Handle the error.
	}
	[request release];

	// We should ship the app with a default account already
	// created so that we can assume it exists.
	if ([accounts count] == 0) {
		// Create account
		myAccount = (Account *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:managedObjectContext];
		[myAccount setEmail:@""];
		[myAccount setUsername:@""];
		[myAccount setPassword:@""];
//		[myAccount setUser:(User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext]];
	} else if ([accounts count] == 1) {
		myAccount = [accounts objectAtIndex:0];
		[webSocket open];
	} else if ([accounts count] > 1) {
		// Present account login screen to pick account
	}

	[self findLocation];
	
	// Setup profileValues decoder arrays: Maybe these should just be in one NSDictionary?
	// Also, these are already in pickerOptions.
	Sexes = [[NSArray alloc] initWithObjects:@"Do Not Show", @"Female", @"Male", nil];
	Ethnicities = [[NSArray alloc] initWithObjects:@"Do Not Show", @"Asian", @"Black", @"Latino",
				   @"Middle Eastern", @"Mixed", @"Native American", @"White", @"Other", nil];
	Likes = [[NSArray alloc] initWithObjects:@"Do Not Show", @"Women", @"Men", @"Both", nil];

//	// make a function to convert height in cm to ft, etc.
//	// http://stackoverflow.com/questions/2324125/objective-c-string-formatter-for-distances
//	// Returns a string representing the distance in the correct units.
//	// If distance is greater than convert max in feet or meters, 
//	// the distance in miles or km is returned instead
//	NSString* getDistString(float distance, int convertMax, BOOL includeUnit) {
//		NSString * unitName;
//		if (METRIC) {
//			unitName = @"m";
//			if (convertMax != -1 && distance > convertMax) {
//				unitName = @"km";
//				distance = distance / 1000;
//			}
//		} else {
//			unitName = @"ft";
//			if (convertMax != -1 && distance > convertMax) {
//				unitName = @"mi";
//				distance = distance / 5280;
//			}
//			distance = metersToFeet(distance);
//		}
//		
//		if (includeUnit) return [NSString stringWithFormat:@"%@ %@", formatDecimal_1(distance), unitName];
//		
//		return formatDecimal_1(distance);
//		
//	}
//	// returns a string if the number with one decimal place of precision
//	// sets the style (commas or periods) based on the locale
//	NSString * formatDecimal_1(float num) {
//		static NSNumberFormatter *numFormatter;
//		if (!numFormatter) {
//			numFormatter = [[[NSNumberFormatter alloc] init] retain];
//			[numFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//			[numFormatter setLocale:[NSLocale currentLocale]];
//			[numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//			[numFormatter setMaximumFractionDigits:1];
//			[numFormatter setMinimumFractionDigits:1];
//		}
//		
//		return [numFormatter stringFromNumber:F(num)];
//		
//	}
	
	return YES;
}


#pragma mark -
#pragma mark Location manager interactions

- (void)findLocation {
	// Should we use presentModelviewcontroller like urbanspoon to use last location?
	self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
   
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationManager startUpdatingLocation];
    //[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:[[setupInfo objectForKey:kSetupInfoKeyTimeout] doubleValue]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (locationMeasurements == nil) {
		self.locationMeasurements = [[NSMutableArray alloc] init];
	}
	[locationMeasurements addObject:newLocation];
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
	if (newLocation.horizontalAccuracy < 0) return;
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort" as well as setting UsersViewController's CLlocation
        self.bestEffortAtLocation = newLocation;
		usersViewController.location = newLocation;
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


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark HTTPOperation delegate

- (void)doneWithPut:(NSString *)outstring {
	//	[activity stopAnimating];
	//	showAlert(outstring);
	//	[button setEnabled:YES];
	//	[self showButtons];
	NSLog(@"Response from server: %@", outstring);
}


#pragma mark -
#pragma mark WebSocket delegate

- (void)webSocketDidClose:(ZTWebSocket *)webSocket {
	NSLog(@"Disconnected");
	if (usersViewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON_TARGET(@"Login", usersViewController, @selector(login:));
		usersViewController.navigationItem.leftBarButtonItem = logButton;
		[logButton release];
	}
}

- (void)webSocketDidOpen:(ZTWebSocket *)aWebSocket {
	NSLog(@"Connected");
	if (usersViewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON_TARGET(@"Logout", usersViewController, @selector(logout:));
		usersViewController.navigationItem.leftBarButtonItem = logButton;
		[logButton release];
	}
	// should be mongodb _id for user, not device id.
	// So, open WebSocket after sinatra responds w my uid
	[webSocket send:[NSString stringWithFormat:@"{\"uid\":\"%@\"}",
					 [(User *)[myAccount user] uid]]];
}

- (void)webSocket:(ZTWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (error.code == ZTWebSocketErrorConnectionFailed) {
		NSLog(@"Connection failed");
    } else if (error.code == ZTWebSocketErrorHandshakeFailed) {
		NSLog(@"Handshake failed");
    } else {
		NSLog(@"Error");
    }
}

- (void)webSocket:(ZTWebSocket *)webSocket didReceiveMessage:(NSString*)msgJson {
	NSLog(@"Received jsonMessage: %@", msgJson);
	
	NSError *error = nil;
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *msgDict = [json objectWithString:msgJson error:&error];
	[json release];
	
	NSLog(@"Message dictionary: %@", msgDict);
	
	Message *msg = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:managedObjectContext];
	[msg setTimestamp:[msgDict valueForKey:@"timestamp"]];
	//	NSLog(@"[[msgDict valueForKey:@\"timestamp\"] class]: %@", [[msgDict valueForKey:@"timestamp"] class]);
	//	NSLog(@"[[msg timestamp] class]: %@", [[msg timestamp] class]);
	//	NSLog(@"msg timestamp: %@", [msg timestamp]);
	//	NSLog(@"msg timestamp doubleValue: %d", [[msg timestamp] doubleValue]);
	
	[msg setChannel:[msgDict valueForKey:@"channel"]];
	[msg setSender:[msgDict valueForKey:@"sender"]];
	[msg setText:[[[[msgDict valueForKey:@"text"]
					stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
				   stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]
				  stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"]];
	
	if ([navigationController.visibleViewController isKindOfClass:[ChatViewController class]]) {
		[msg setUnread:[NSNumber numberWithBool:NO]];
		ChatViewController *chatViewController = (ChatViewController *)navigationController.visibleViewController;
//		[chatViewController addMessage];
		[chatViewController.messages addObject:msg];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[chatViewController.messages count]-1 inSection:0];
		[chatViewController.chatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						   withRowAnimation:UITableViewRowAnimationNone];
		[chatViewController scrollToBottomAnimated:YES];
	}

	// Play sound or buzz, depending on user settings.
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:@"basicsound" ofType:@"wav"];
	CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sndpath];
	AudioServicesCreateSystemSoundID (baseURL, &receiveMessageSound);
	AudioServicesPlaySystemSound(receiveMessageSound);
//	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // explicit vibrate

	// Save message to database
	error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Error saving message! %@", error);
	}
}

-(void)webSocketDidSendMessage:(ZTWebSocket *)webSocket {
	//    messages--;
	//    if (messages == 0) {
	//        [activityIndicator stopAnimating];
	//    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Lovers.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	if (receiveMessageSound) AudioServicesDisposeSystemSoundID(receiveMessageSound);

	[Sexes release];
	[Ethnicities release];
	[Likes release];
	
	[webSocket release];

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
	[locationManager release];
	[locationMeasurements release];
	[bestEffortAtLocation release];

	[usersViewController release];
	[navigationController release];
	[window release];
    [super dealloc];
}

@end
