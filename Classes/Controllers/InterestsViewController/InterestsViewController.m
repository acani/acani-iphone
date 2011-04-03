#import "ProfileViewController.h"
#import "InterestsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "User.h"
#import "Interest.h"
#import "ThumbView.h"
#import "JSON.h"

#define CELL_HEIGHT 77.0f
#define THUMB_SIZE 75.0f
#define THUMB_PADDING 4.0f
#define MAX_USERS 3000
#define MIN_ORDER -32660
#define MAX_ORDER 32760


@implementation InterestsViewController

@synthesize myUser;
@synthesize theInterest;

@synthesize managedObjectContext;
@synthesize fetchedResultsController;

@synthesize urlData;


#pragma mark -
#pragma mark Initialization

- (id)initWithMe:(User *)user interest:(Interest *)interest {
	if (!(self = [super initWithStyle:UITableViewStylePlain])) return self;
	self.myUser = user;
	self.theInterest = interest;
	// TODO: add switch at top for My Interests / All Interests
	// UIBarButtonItem * segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView: segmentedControl] autorelease];
	// self.navigationItem.leftBarButtonItem = segmentBarItem;
	// self.navigationItem.titleView = segmentBarItem;
	self.title = [theInterest name];
	self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// TODO: Refactor out the code below that adds refresh button.
	// It's the same as in the usersViewController
	// displayRefreshButton(self, @"Profile", @selector(goToProfile));

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
	
	// Fetch interests from Core Data.
	// Create and configure a fetch request.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Interest"
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	// Only fetch this interest and it's grandchildren.
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"oid == %@ OR parent.oid == %@",
							  [theInterest oid], [theInterest oid]];
	[fetchRequest setPredicate:predicate];

	// Sort alphabetical by interest name
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[sortDescriptor release];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	// Create and initialize the fetchedResultsController.
	NSFetchedResultsController *aFetchedResultsController = \
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:managedObjectContext
										  sectionNameKeyPath:nil // @"parent.name"
												   cacheName:nil];
	[fetchRequest release];
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	fetchedResultsController.delegate = self;
	
	NSError *error;
	if (![fetchedResultsController performFetch:&error]) {
		// TODO: Handle the error appropriately.
		NSLog(@"fetch interests error %@, %@", error, [error userInfo]);
	}
	
	[self refresh];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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

// GET nearest interests from server if connected to Internet.
- (void)refresh {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@/interests", kHost];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString	release];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url
												  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData // dynamic response
											  timeoutInterval:60.0]; // default
	[url release];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	[urlRequest release];
	if (connection) {
		urlData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		NSLog(@"Failure to create URL connection.");
	}
    // Start network activity spinner in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[fetchedResultsController sections] count];
    if (count == 0) count = 1;
	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]
														objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// TODO: Only put disclosure indicator on cells with children
		// cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

// Configure the cell to show the name of child interest.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    Interest *interest = (Interest *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [interest name];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
//	return 30.0f;
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
	Interest *interest = [fetchedResultsController objectAtIndexPath:indexPath];
	if ([[interest children] count] == 0 || ([indexPath section] == 0 && [indexPath row] == 0)) { // TODO fix
		[[self parentViewController] dismissModalViewControllerAnimated:YES];
	} else {
//		// The line below fixes error: "You have illegally mutated the NSFetchedResultsController's
//		// fetch request, its predicate, or its sort descriptor without either disabling caching or
//		// using +deleteCacheWithName:"
//		[NSFetchedResultsController deleteCacheWithName:@"Interest"];
		InterestsViewController *interestsViewController = [[InterestsViewController alloc] initWithMe:myUser interest:interest];
		[self.navigationController pushViewController:interestsViewController animated:YES];
		[interestsViewController release];		
	}
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Interests"
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
	// parse JSON & create interests in managedObjectContext. See top apps example.
	
	// Parse urlData to JSON object.
	NSString *jsonString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
	[urlData release];
	NSArray *interestDicts = [jsonString JSONValue];
	[jsonString release];

	// Delete all interests and insert them again. Update theInterest from server.
	NSString *theInterestOid = [theInterest oid]; // store because we delete theInterest next
//	[managedObjectContext deleteObject:theInterest]; // since we fetch again next
	[self clearInterests];
	Interest *tempInterest;
	for (NSDictionary *interestDict in interestDicts) {
		tempInterest = [Interest insertWithDictionary:interestDict
							   inManagedObjectContext:managedObjectContext];
		if ([theInterestOid isEqualToString:[tempInterest oid]]) {
			self.theInterest = tempInterest;
		}
	}
	[managedObjectContext save:nil];
//	self.theInterest = [Interest findByAttribute:@"oid" value:[theInterest oid]
//									  entityName:@"Interest"
//						  inManagedObjectContext:managedObjectContext];
}

- (void)clearInterests {	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Interest"
											  inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
	
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted: %@", @"Interest", managedObject);
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error: %@", @"Interest", error);
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
	
	//	[urlData release]; // How should we release this?
    [super dealloc];
}

@end
