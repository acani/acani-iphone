#import "UsersViewController.h"
#import "ProfileViewController.h"
#import "PhotoViewController.h"
#import "LoversAppDelegate.h"
#import "Constants.h"
#import "User.h"
#import "Account.h"
#import "ThumbsCell.h"
#import "JSON.h"


@implementation UsersViewController

@synthesize columnCount;

@synthesize me;

@synthesize managedObjectContext;
@synthesize fetchedResultsController;

@synthesize location; // TODO: change this to sharedLocation in appDelegate
@synthesize userData;


#pragma mark -
#pragma mark Initialization


- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
		self.wantsFullScreenLayout = YES;
		// TODO: make the navBar title a logo.
		self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// Add Profile button as rightBarButtonItem.
	UIBarButtonItem *profileButton = BAR_BUTTON(@"Profile", @selector(goToProfile));
	[profileButton setEnabled:NO]; // Enable once we get me.
	self.navigationItem.rightBarButtonItem = profileButton;

	// Fetch me & other users from Core Data.
	if (self.me = [User findByUid:@"myid"]) {
		[profileButton setEnabled:YES];
	}
	[profileButton release];	
	
	// Create and configure a fetch request.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

//	// TODO: Set the predicate to only fetch users from this group.
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@", group];
//	[fetchRequest setPredicate:predicate];
	
	// TODO: What should we sort by? Last diplayed?
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastOnline" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[sortDescriptor release];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	// Create and initialize the fetchedResultsController.
	NSFetchedResultsController *aFetchedResultsController = \
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:managedObjectContext
										  sectionNameKeyPath:nil // only generate one section
												   cacheName:@"User"];
	[fetchRequest release];
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	fetchedResultsController.delegate = self;
	
	NSError *error;
	if (![fetchedResultsController performFetch:&error]) {
		// TODO: Handle the error appropriately.
		NSLog(@"fetch users error %@, %@", error, [error userInfo]);
	}
//	NSLog(@"fetched sections count: %i", [[fetchedResultsController sections] count]);
//	NSLog(@"fetched objects first: %@", [[fetchedResultsController fetchedObjects] objectAtIndex:0]);

	// GET nearest users from server; limit => 20.
	NSString *myUid = [(User *)[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] user] uid]; // make shared me variable so this is easier to get
	NSString *string = [[NSString alloc] initWithFormat:@"http://%@/users/%@/%@/%f/%f",
						SINATRA,
						myUid == nil ? @"0" : myUid, // nil if it's first time using app
						[[UIDevice currentDevice] uniqueIdentifier],
						50.0f, 50.0f];
//						location.coordinate.latitude, location.coordinate.longitude];
	NSURL *url = [[NSURL alloc] initWithString:string];
	[string	release];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url
													 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
												 timeoutInterval:60.0]; // default
	[url release];
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	[urlRequest release];
	if (urlConnection) {
		self.userData = [NSMutableData data];
	} else {
		// Inform the user that the connection failed.
		NSLog(@"Failure to create URL connection.");
	}

    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

//	self.loadUsers;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	// Set login button if connected to WebSocket.
	ZTWebSocket *webSocket = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket];	
	UIBarButtonItem *loginButton;
	if ([webSocket connected]) {
		loginButton = BAR_BUTTON(@"Logout", @selector(logout));
	} else {
		loginButton = BAR_BUTTON(@"Login", @selector(login));
	}
	self.navigationItem.leftBarButtonItem = loginButton;
	[loginButton release];	
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Button actions


#define TERMS_ALERT 901
#define	REVIEW 1
#define	LOGOUT_ALERT 902
#define LOGOUT 1

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)index {
	printf("User selected button %d\n", index);
	switch (alertView.tag) {
		case LOGOUT_ALERT:
			if (index == LOGOUT) {
				[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
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
		[self showAlert:@"If you logout, you will no longer be visible in acani and will not be able to chat with other users."];
	} else {
		[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
		// Then go to loginView like Facebook iPhone app does.
	}
}

- (void)login {
	[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] open];
}

- (void)goToProfile {
	ProfileViewController *profileVC = [[ProfileViewController alloc] initWithMe:me];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[profileVC release];
	[self presentModalViewController:navController animated:YES];
	[navController release];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[fetchedResultsController fetchedObjects] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ThumbsCell";
    
    UITableViewCell *thumbsCell = (ThumbsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (thumbsCell == nil) {
        thumbsCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
//    UITableViewCell *thumbsCell = (ThumbsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (thumbsCell == nil) {
//        thumbsCell = [[[ThumbsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }

//	thumbsCell.setUp;

	// Configure the cell to show the name of user.
	User *user = [fetchedResultsController objectAtIndexPath:indexPath];

	thumbsCell.textLabel.text = [user name]; // temporary

    return thumbsCell;
}

//- (void)loadUsers {
//	// If connected to internet, fetch remote users.
//	[self fetchUsers];
//}
//
//// Get users from server.
//- (void)fetchUsers {
//	
//}
//
//- (void)reload {
//	
//}
//
//- (void)loadMoreUsers {
//	
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	User *user = [fetchedResultsController objectAtIndexPath:indexPath];
	PhotoViewController *photoViewController = [(PhotoViewController *)[PhotoViewController alloc] initWithUser:user];
	[self.navigationController pushViewController:photoViewController animated:YES];
	[photoViewController release];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Users"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [userData setLength:0]; // reset data
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [userData appendData:data]; // append incoming data
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release]; [userData release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // If we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	// TODO: Use performance tools to determine if we should use NSOperation to
	// parse JSON & create users in managedObjectContext. See top apps example.

	// Parse userData to JSON object.
	NSString *usersJson = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
	[userData release];
	NSArray *users = [usersJson JSONValue];
	[usersJson release];

	// Insert users into managedObjectContext.
	NSEnumerator *e = [users objectEnumerator];

	// Insert me first, then the others.
	me = [User insertWithDictionary:[e nextObject] 
			 inManagedObjectContext:managedObjectContext];
	[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] setUser:me];
	if (![self.navigationItem.rightBarButtonItem isEnabled] && me) {
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	}
	NSDictionary *user;
	while (user = [e nextObject]) {
		[User insertWithDictionary:user
			inManagedObjectContext:managedObjectContext];
	}

	// Save. In memory-changes trump conflicts in external store.
	[managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
//	[managedObjectContext save:nil]; // this breaks currently
}


#pragma mark -
#pragma mark Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];	
	self.fetchedResultsController = nil;	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[me release];

	[fetchedResultsController release];
	[managedObjectContext release];

	[location release];
//	[userData release]; // How should we release this?
    [super dealloc];
}

@end
