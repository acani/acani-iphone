#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "ChatViewController.h"
#import "User.h"
#import "Account.h"
#import "Message.h"
#import "ZTWebSocket.h"
#import "SBJSON.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize window;
@synthesize myAccount;
@synthesize navigationController;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize locationManager;
@synthesize viewController;
@synthesize webSocket;
@synthesize Sexes;
@synthesize Ethnicities;
@synthesize Likes;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Initialize Core Data's managedObjectContext
    if (![self managedObjectContext]) {
        // Handle the error.
		NSLog(@"managedObjectContext error!");
    }

	// Get myAccount.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSArray *accounts = [managedObjectContext executeFetchRequest:request error:&error];
	NSUInteger actCnt = [accounts count];
	[request release];
	if (accounts == nil || actCnt == 0) {
		// TODO: Handle the error appropriately.
		NSLog(@"fetch accounts error %@, %@", error, [error userInfo]);
	} else if (actCnt == 1) { // app ships with at least 1 account
		NSLog(@"got 1 account");
		self.myAccount = [accounts objectAtIndex:0];
		[webSocket open];
	} else if (actCnt > 1) {
		// Present account login screen to pick account
	}

	NSLog(@"myUser: %@", [myAccount user]);

	// Create window, navigationController & viewController
//	viewController = [[WelcomeViewController alloc] initWithMe:[myAccount user]];
//	viewController.managedObjectContext = managedObjectContext;

//	ChatViewController *chatViewController = [[ChatViewController alloc] init]; // for testing chat
//	chatViewController.managedObjectContext = managedObjectContext; // for testing chat

	navigationController = [[UINavigationController alloc]
							initWithRootViewController:[[WelcomeViewController alloc] init]];
//							initWithRootViewController:chatViewController]; [chatViewController release]; // for testing chat
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;

    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];


	webSocket = [[ZTWebSocket alloc] initWithURLString:@"ws://localhost:8124/" delegate:self];

//	[self findLocation];
	
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

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	 Called when the application is about to terminate.
	 See also applicationDidEnterBackground:.
	 */	
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
#pragma mark Location manager interactions

//- (void)findLocation {
//	// Should we use presentModelviewcontroller like urbanspoon to use last location?
//	self.locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//   
//    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//	[locationManager startUpdatingLocation];
//    //[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:[[setupInfo objectForKey:kSetupInfoKeyTimeout] doubleValue]];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//	if (locationMeasurements == nil) {
//		self.locationMeasurements = [[NSMutableArray alloc] init];
//	}
//	[locationMeasurements addObject:newLocation];
//	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//    if (locationAge > 5.0) return;
//	if (newLocation.horizontalAccuracy < 0) return;
//    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
//        // store the location as the "best effort" as well as setting viewController's CLlocation
//        self.bestEffortAtLocation = newLocation;
//		viewController.location = newLocation;
//                if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
//					[manager stopUpdatingLocation];
//            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
//			// [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
//        }
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    if ([error code] != kCLErrorLocationUnknown) {
//        [manager stopUpdatingLocation];
//    }
//}


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
	if (viewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON_TARGET(@"Login", viewController, @selector(login));
		viewController.navigationItem.leftBarButtonItem = logButton;
		[logButton release];
	}
}

- (void)webSocketDidOpen:(ZTWebSocket *)aWebSocket {
	NSLog(@"Connected");
	if (viewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON_TARGET(@"Logout", viewController, @selector(logout));
		viewController.navigationItem.leftBarButtonItem = logButton;
		[logButton release];
	}
	// should be mongodb _id for user, not device id.
	// So, open WebSocket after sinatra responds w my oid
	[webSocket send:[NSString stringWithFormat:@"{\"oid\":\"%@\"}",
					 [(User *)[myAccount user] oid]]];
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
	
	NSString *type = [msgDict valueForKey:@"type"];

	if ([type isEqualToString:@"login"]) {
		return;
	} else if ([type isEqualToString:@"txt"]) {
		Message *msg = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:managedObjectContext];
		[msg setTimestamp:[msgDict valueForKey:@"timestamp"]];
		//	NSLog(@"[[msgDict valueForKey:@\"timestamp\"] class]: %@", [[msgDict valueForKey:@"timestamp"] class]);
		//	NSLog(@"[[msg timestamp] class]: %@", [[msg timestamp] class]);
		//	NSLog(@"msg timestamp: %@", [msg timestamp]);
		//	NSLog(@"msg timestamp doubleValue: %d", [[msg timestamp] doubleValue]);
		
		[msg setChannel:[msgDict valueForKey:@"channel"]];

		// Fetch the msg sender based on the BSON ObjectId.
		NSString *senderOid = [msgDict valueForKey:@"sender"];
		User *sender = [User findByOid:senderOid];
		// If the sender is not found on the iPhone, request her asynchronously from the server.
		if (!sender) {
			NSLog(@"Get sender from Sinatra");
			sender = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User"
														   inManagedObjectContext:managedObjectContext];
			[sender setOid:senderOid];
			// TODO: Request other attributes from the server asynchronously.
		}

		[msg setSender:sender];
		[msg setText:[[[[msgDict valueForKey:@"text"]
						stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
					   stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]
					  stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"]];
		
		if ([navigationController.visibleViewController isKindOfClass:[ChatViewController class]]) {
			[msg setUnread:[NSNumber numberWithBool:NO]];
			ChatViewController *chatViewController = (ChatViewController *)navigationController.visibleViewController;
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
			// TODO: Handle the error appropriately.
			NSLog(@"ReceiveMsg error %@, %@", error, [error userInfo]);
		}		
	}
}

-(void)webSocketDidSendMessage:(ZTWebSocket *)webSocket {
	NSLog(@"Sent message.");
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
- (NSManagedObjectContext *)managedObjectContext {
	if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coord = [self persistentStoreCoordinator];
	if (!coord) return nil;
	
	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator:coord];

    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel) return managedObjectModel;

    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator) return persistentStoreCoordinator;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"acani.sqlite"];

	// If the expected store doesn't exist, copy the default store.
	// This is basically like shipping the app with a default user account
	// already created so that we can assume it exists.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"acani" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}

	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
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

	[myAccount release];

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

	[viewController release];
	[navigationController release];
	[window release];
    [super dealloc];
}

@end
