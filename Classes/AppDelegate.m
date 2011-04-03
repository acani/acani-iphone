#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "UsersViewController.h"
#import "ChatViewController.h"
#import "ProfileViewController.h"
#import "Account.h"
#import "User.h"
#import "Location.h"
#import "Message.h"
#import "ZTWebSocket.h"
#import "SBJSON.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize facebook;
@synthesize myAccount;
@synthesize window;
@synthesize navigationController;
@synthesize welcomeViewController;
@synthesize usersViewController;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize locationManager;
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

//	// To seed Core Data Database, run once after changing .xcdatamodel file.
//	// Delete Z_METADATA row.
//	Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:managedObjectContext];
//	User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
//	Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
//	[user setLocation:location];
//	[account setUser:user];
//	[user setOnlineStatus:[NSNumber numberWithInteger:1]];
//	NSError *error;
//	if ([managedObjectContext save:&error]) {
//		NSLog(@"Success! Seeded Core Data Database.");
//	} else {
//		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//	}
//	abort();
	
	// Initialize navigationController.
	navigationController = [[UINavigationController alloc]
							initWithRootViewController:usersViewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;

	// Create window, navigationController & usersViewController
	welcomeViewController = [[WelcomeViewController alloc] init];
	welcomeViewController.managedObjectContext = managedObjectContext;
	//	ChatViewController *chatViewController = [[ChatViewController alloc] init]; // for testing chat
	//	chatViewController.managedObjectContext = managedObjectContext; // for testing chat
	
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window addSubview:welcomeViewController.view];
    [window makeKeyAndVisible];

	facebook = [[Facebook alloc] initWithAppId:kAppId];
	
	webSocket = [[ZTWebSocket alloc] initWithURLString:@"ws://localhost:8124/" delegate:self];
	[webSocket open];

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
//	// Should we use presentModalViewController like urbanspoon to use last location?
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
//        // store the location as the "best effort" as well as setting usersViewController's CLlocation
//        self.bestEffortAtLocation = newLocation;
//		usersViewController.location = newLocation;
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
#pragma mark Button actions

#define TERMS_ALERT 901
#define	REVIEW 1
#define	LOGOUT_ALERT 902
#define LOGOUT 1

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)index {
	switch (alertView.tag) {
		case LOGOUT_ALERT:
			if (index == LOGOUT) {
				[webSocket close];
			}
			break;
		case TERMS_ALERT:
			if (index == REVIEW) {
				UIApplication *app = [UIApplication sharedApplication];
				[app openURL:[NSURL URLWithString:@"http://www.acani.com/terms"]];
			}
			break;
	}
	[alertView release];
}
- (void)showAlert:(NSString *)message {
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Logout" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	av.tag = LOGOUT_ALERT;
	[av show];
}

- (void)logout {
	// Only display this alert on first logout.
	if (YES) {
		[self showAlert:@"If you logout, you will no longer be visible in acani and will not be able to chat with other interests."];
	} else {
		[webSocket close];
		// Then go to loginView like Facebook iPhone app does.
	}
}

- (void)login {
	[webSocket open];
}

- (void)goToProfile {
	ProfileViewController *profileVC = [[ProfileViewController alloc] initWithMe:[myAccount user]];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[profileVC release];
	[usersViewController presentModalViewController:navController animated:YES];
	[navController release];
}


#pragma mark -
#pragma mark WebSocket delegate

- (void)webSocketDidClose:(ZTWebSocket *)webSocket {
	NSLog(@"Disconnected");
	if (usersViewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON(@"Login", @selector(login));
		usersViewController.navigationItem.leftBarButtonItem = logButton;
		[logButton release];
	}
}

- (void)webSocketDidOpen:(ZTWebSocket *)aWebSocket {
	NSLog(@"Connected");
	if (usersViewController != nil) {
		UIBarButtonItem *logButton = BAR_BUTTON(@"Logout", @selector(logout));
		usersViewController.navigationItem.leftBarButtonItem = logButton;
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
		User *sender = [User findByAttribute:@"oid" value:senderOid
								  entityName:@"User" inManagedObjectContext:managedObjectContext];
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
#pragma mark Facebook functions

- (void)fbLogin {
	[facebook authorize:[NSArray arrayWithObjects:@"read_stream", @"offline_access", nil]
			   delegate:self];
}

- (void)fbLogout {
	[facebook logout:self]; 
}

- (void)getUserInfo:(id)sender {
	// TODO: add ?fields=id,name,picture... to end of path
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}


/**
 * Example of REST API CAll
 *
 * This lets you make a REST API Call to get a user's public information with FQL.
 */
- (void)getPublicInfo:(id)sender {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"SELECT oid,name FROM user WHERE oid=4", @"query",
								   nil];
	[facebook requestWithMethodName:@"fql.query" 
						  andParams:params
					  andHttpMethod:@"POST" 
						andDelegate:self]; 
}

/**
 * Example of display Facebook dialogs
 *
 * This lets you publish a story to the user's stream. It uses UIServer, which is a consistent 
 * way of displaying user-facing dialogs
 */
- (void)publishStream:(id)sender {
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
														   @"Always Running",@"text",@"http://itsti.me/",@"href", nil], nil];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								@"a long run", @"name",
								@"The Facebook Running app", @"caption",
								@"it is fun", @"description",
								@"http://itsti.me/", @"href", nil];
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kAppId, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	
	[facebook dialog:@"stream.publish"
		   andParams:params
		 andDelegate:self];
	
}


- (void)uploadPhoto:(id)sender {
	NSString *path = @"http://www.facebook.com/images/devsite/iphone_connect_btn.jpg";
	NSURL    *url  = [NSURL URLWithString:path];
	NSData   *data = [NSData dataWithContentsOfURL:url];
	UIImage  *img  = [[UIImage alloc] initWithData:data];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   img, @"picture",
								   nil];
	[facebook requestWithMethodName:@"photos.upload" 
						  andParams:params
					  andHttpMethod:@"POST" 
						andDelegate:self]; 
	[img release];  
}

/**
 * Callback for facebook login
 */ 
- (void)fbDidLogin {
	NSLog(@"logged in");
	[self getUserInfo:self];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}

/**
 * Callback for facebook logout
 */ 
- (void)fbDidLogout {
	NSLog(@"logged out");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	//	[self.label setText:[error localizedDescription]];
	NSLog(@"error %@", [error localizedDescription]);
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0]; 
	} else if ([result objectForKey:@"owner"]) {
		NSLog(@"Photo upload Success. Response: %@", result);
		//		[self.label setText:@"Photo upload Success"];
	} else {
		NSLog(@"Result: %@", result);
		
		// Find user by Facebook ID.
		NSNumber *fbId = [NSNumber numberWithInteger:[[result valueForKey:@"id"] intValue]];
//		NSNumber *fbId = [[NSNumber alloc] initWithInteger:514417];
		User *myUser = (User *)[User findByAttribute:@"fbId" value:(id)fbId
										  entityName:@"User"
							  inManagedObjectContext:managedObjectContext];
		
		// Create myUser from Facebook info if not found.
		NSDate *now = [[NSDate alloc] init];
		if (!myUser) {
			myUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User"
														   inManagedObjectContext:managedObjectContext];
			[myUser setFbId:fbId];
			[myUser setUpdated:now];
		}
		[fbId release];
		
		// Create account for user if one doesn't already exist.
		if (![myUser account]) {
			Account *account = (Account *)[NSEntityDescription
										   insertNewObjectForEntityForName:@"Account"
										   inManagedObjectContext:managedObjectContext];
			[account setUser:myUser];
		}
		
		// Set user attributes: location, onlineStatus, lastOnline, etc.
		[myUser setOnlineStatus:[NSNumber numberWithInteger:1]];
		[myUser setLastOnline:now];
		[now release];
		
		Location *location = (Location *)[NSEntityDescription
										  insertNewObjectForEntityForName:@"Location"
										  inManagedObjectContext:managedObjectContext];
		// TODO: set location & update in background
		//		[location setLatitude:myLocation];
		//		[location setLongitude:myLocation];
		[myUser setLocation:location];
		
		// Set myUser's attributes according to Facebook's response.
		[myUser setFbUsername:[[result valueForKey:@"link"] lastPathComponent]];
		[myUser setName:[result valueForKey:@"name"]]; // full name
		[myUser setAbout:[result valueForKey:@"about"]]; // should this be headline?
		//	[myUser setHeadline:[result valueForKey:@"about"]];
		NSString *sex = [[result valueForKey:@"gender"] capitalizedString];
		[myUser setSex:[sex isEqualToString:@"Male"] ? [NSNumber numberWithInteger:2] :
		 [NSNumber numberWithInteger:1]];
		//	[myUser setLikes:[result valueForKey:@"v"]];
		//	[myUser setAge:[result valueForKey:@"y"]];		 
		
		
		// Find top-level Interest, with name "acani."
		NSString *tlInterestName = @"acani";
		Interest *tlInterest = (Interest *)[Interest findByAttribute:@"name" value:(id)tlInterestName
														  entityName:@"Interest"
											  inManagedObjectContext:managedObjectContext];
		
		// Create top-level interest if not found
		if (!tlInterest) {
			tlInterest = (Interest *)[NSEntityDescription
									  insertNewObjectForEntityForName:@"Interest"
									  inManagedObjectContext:managedObjectContext];
			[tlInterest setOid:@"0"];
			[tlInterest setName:tlInterestName];
		}
		
		// Save changes if any.
		NSError *error;
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// TODO: handle this error correctly.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
		// Push usersViewController with myUser & top-level Interest.
		usersViewController.myUser = myUser;
		usersViewController.theInterest = tlInterest;
		usersViewController.title = tlInterestName;
		
		navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[welcomeViewController presentModalViewController:navigationController animated:YES];
	}
};

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {	
    return [facebook handleOpenURL:url]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/** 
 * Called when a UIServer Dialog successfully return
 */
- (void)dialogDidComplete:(FBDialog*)dialog{
	//	[self.label setText:@"publish successfully"];
	NSLog(@"publish successfully");
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

	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"acani.sqlite"];

//	// If the expected store doesn't exist, copy the default store, which
//	// contains initialized data.
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	if (![fileManager fileExistsAtPath:storePath]) {
//		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"acani" ofType:@"sqlite"];
//		if (defaultStorePath) {
//			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
//		}
//	}
	
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
	
	[facebook release];
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
