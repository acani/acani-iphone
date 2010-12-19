#import "UsersViewController.h"
#import "ProfileViewController.h"
#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "User.h"
#import "Location.h"
#import "ThumbView.h"
#import "JSON.h"

#define CELL_HEIGHT 77.0f
#define THUMB_SIZE 75.0f
#define THUMB_PADDING 4.0f
#define MAX_USERS 3000
#define MIN_ORDER -32660
#define MAX_ORDER 32760


@implementation UsersViewController

@synthesize myUser;
@synthesize theInterest;

@synthesize managedObjectContext;
@synthesize fetchedResultsController;

@synthesize location; // TODO: change this to sharedLocation in appDelegate
@synthesize urlData;


#pragma mark -
#pragma mark Initialization

- (id)initWithMe:(User *)user interest:(Interest *)interest {
	if (!(self = [super initWithStyle:UITableViewStylePlain])) return self;
	self.wantsFullScreenLayout = YES;
	self.myUser = user;
	self.theInterest = interest;
	columnCount = 4; // TODO: make variable (4,6), based on orientation
	// TODO: make the navBar title a logo.
	self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// Create a toolbar to have two buttons on the right.
	// http://osmorphis.blogspot.com/2009/05/multiple-buttons-on-navigation-bar.html
	UIToolbar *tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 103.0f, 44.01f)]; // 44.01f shifts up by 1px
	tools.clearsContextBeforeDrawing = NO;
	tools.clipsToBounds = NO;
	tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // eye estimate. TODO: make perfect.
	tools.barStyle = -1; // clear background
	NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];

	// Create a standard refresh button.
	UIBarButtonItem *bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	[buttons addObject:bi];
	[bi release];

	// Create a spacer.
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	bi.width = 12.0f;
	[buttons addObject:bi];
	[bi release];

	// Add profile button.
	bi = BAR_BUTTON(@"Profile", @selector(goToProfile));
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];
	
	// Add buttons to toolbar and toolbar to nav bar.
	[tools setItems:buttons animated:NO];
	[buttons release];
	UIBarButtonItem *twoButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];
	self.navigationItem.rightBarButtonItem = twoButtons;
	[twoButtons release];

	// Fetch 20 closest users from Core Data.
	// Create and configure a fetch request.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

//	// TODO: Set the predicate to only fetch users from this group.
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@", group];
//	[fetchRequest setPredicate:predicate];
	
	// TODO: What should we sort by? Last diplayed?
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
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

	[self refresh];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	// Set login button if connected to WebSocket.
	ZTWebSocket *webSocket = [(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket];	
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
				[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
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
		[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
		// Then go to loginView like Facebook iPhone app does.
	}
}

- (void)login {
	[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] open];
}

- (void)goToProfile {
	ProfileViewController *profileVC = [[ProfileViewController alloc] initWithMe:myUser];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[profileVC release];
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

// GET nearest users from server if connected to internet; limit => 20.
- (void)refresh {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@/users/%@/%@/%@/%@",
						   SINATRA,
						   [[myUser oid] length] ? [myUser oid] : @"0", // @"" if it's first time using app
						   [[UIDevice currentDevice] uniqueIdentifier],
						   [[myUser location] latitude],
						   [[myUser location] longitude]];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString	release];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
													 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData // dynamic response
												 timeoutInterval:60.0]; // default
	[url release];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	if (connection) {
		urlData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		NSLog(@"Failure to create URL connection.");
	}

    // Start network activity spinner in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
}

- (void)loadMore {
	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger num_rows = [[fetchedResultsController fetchedObjects] count] / columnCount;
	return num_rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ThumbsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		// Add thumbViews as subviews.
		CGFloat x_pos = THUMB_PADDING;
		NSUInteger i = [indexPath row] * columnCount;
		NSUInteger usersCount = [[fetchedResultsController fetchedObjects] count];
		for (NSUInteger j = 0; j < columnCount && i < usersCount; ++j) {
			ThumbView *thumbView = [[ThumbView alloc]
									initWithFrame:CGRectMake(x_pos, 1.0f, THUMB_SIZE, THUMB_SIZE)
									user:[fetchedResultsController objectAtIndexPath:
										  [NSIndexPath indexPathForRow:i inSection:[indexPath section]]]];
			[cell.contentView addSubview:thumbView];
			[thumbView release];
			x_pos += THUMB_SIZE + THUMB_PADDING; ++i;
		}
	}

	[self configureCell:cell atIndexPath:indexPath];

    return cell;
}

// Configure the cell to show the name of user.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSUInteger i = [indexPath row] * columnCount;
	for (ThumbView *thumbView in cell.contentView.subviews) {
		thumbView.user = [fetchedResultsController objectAtIndexPath:
						  [NSIndexPath indexPathForRow:i++ inSection:[indexPath section]]];
	}
//    cell.textLabel.text = [user name];
//	[cell setNeedsLayout];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	return THUMB_SIZE + THUMB_PADDING;
} 

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
    [urlData setLength:0]; // reset data
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [urlData appendData:data]; // append incoming data
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release]; [urlData release];
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

	// Parse urlData to JSON object.
	NSString *usersJson = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	[urlData release];
	NSArray *usrDicts = [usersJson JSONValue];
	[usersJson release];
	
	// Update myUser first.
	[myUser updateWithDictionary:[usrDicts objectAtIndex:0]];

	// Fetch matching local users and update their attributes if necesary.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	// Create predicate with oids of users fetched from server.
	NSUInteger index = -1; // so we can pre-increment (faster?)
	NSMutableArray *servedOids = [[NSMutableArray alloc] initWithCapacity:[usrDicts count]];
	for (NSDictionary *usrDict in usrDicts) {
		if (++index != 0) {
			[servedOids addObject:[[usrDict valueForKey:@"_id"] valueForKey:@"$oid"]];
		}
	}
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"oid IN %@", servedOids]];

	// Perform the fetch.
	NSError *error = nil;
	NSArray *fetchedUsers = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (fetchedUsers == nil) {
		// TODO: Handle the error appropriately.
		NSLog(@"batch fetch users error %@, %@", error, [error userInfo]);
	} else {
		// Store served users in Core Data.
		// Set the order attribute.
		NSInteger oIndex = [[myUser order] integerValue] - index;
		[myUser setOrder:[NSNumber numberWithInteger:oIndex]];		
		
		if ([fetchedUsers count] > 0) {

			// Store fetched users in dictionary with oids as keys.
			NSMutableDictionary *oidFetc = [[NSMutableDictionary alloc]
											initWithCapacity:[fetchedUsers count]];
			for (User *fUsr in fetchedUsers) {
				[oidFetc setObject:fUsr forKey:[fUsr oid]];
			}

			// Iterate over served Users 
			index = -1; User *usrObj;
			NSUInteger sIndex = -1;
			for (NSDictionary *usrDict in usrDicts) {
				if (++index != 0) {
					// Check if served user is already stored on iPhone.
					if(usrObj = [oidFetc objectForKey:[servedOids objectAtIndex:++sIndex]]) {
						// Update each fetched user only if served user is more recent.
						if ([[usrObj updated] timeIntervalSince1970] <
							[[usrDict valueForKey:@"t"] doubleValue]) {
							[usrObj updateWithDictionary:usrDict];
							[usrObj setOrder:[NSNumber numberWithInteger:++oIndex]];
						}
					} else { // insert new served user
						User *oUsr = [User insertWithDictionary:usrDict
										 inManagedObjectContext:managedObjectContext];
						[oUsr setOrder:[NSNumber numberWithInteger:++oIndex]];
					}
				}
			}
			[oidFetc release];
		} else { // insert all served users cause none found locally
			index = -1;
			for (NSDictionary *usrDict in usrDicts) {
				if (++index != 0) {
					User *oUsr = [User insertWithDictionary:usrDict
									 inManagedObjectContext:managedObjectContext];
					[oUsr setOrder:[NSNumber numberWithInteger:++oIndex]];
				}
			}
		}
		
		[self cleanUpUsers];
	}
	[servedOids release];

	// Save. In memory-changes trump conflicts in external store.
	// In case user edits profile before data just received from server,
	// the line below keeps user edits over downloaded data.
	[managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	[managedObjectContext save:nil];
}


#pragma mark -
#pragma mark Fetched results maintenance

// TODO: This should probably be run in background with NSOperationQueue.
- (void)cleanUpUsers {
	NSArray *users = [fetchedResultsController fetchedObjects];

	// If order index is within 100 of min, reorder users.
	if ([[myUser order] integerValue] < MIN_ORDER) { // -32768 is min
		NSInteger oIndex = MAX_ORDER - [users count]; // 32767 is max
		for (User *oUsr in [fetchedResultsController fetchedObjects]) {
			[oUsr setOrder:[NSNumber numberWithInteger:++oIndex]];
		}
	}
	
	// If users count is over 1,000, delete however many got served.
	NSUInteger numUsers = [users count];
	if (numUsers > MAX_USERS) {
		for (NSUInteger i = numUsers; i > numUsers-30; --i) {
			[managedObjectContext deleteObject:[users objectAtIndex:i]];
		}
	}
}


#pragma mark -
#pragma mark Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
//		// TODO: fix updates
//		case NSFetchedResultsChangeInsert:
//			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//			break;
//
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
//	[self.tableView endUpdates];
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
	[myUser release];
	[theInterest release];

	[fetchedResultsController release];
	[managedObjectContext release];

	[location release];
//	[urlData release]; // How should we release this?
    [super dealloc];
}

@end
