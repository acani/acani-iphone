#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "InterestsViewController.h"
#import "Account.h"
#import "User.h"
#import "Location.h"
#import "Interest.h"

@implementation WelcomeViewController

@synthesize managedObjectContext;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)loadView {
	// Create & configure contentView.
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor lightGrayColor]; // default is nil (white)
	contentView.clearsContextBeforeDrawing = NO;

	// Add connect with Facebook button.
	UIButton *FBConnectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	FBConnectButton.clearsContextBeforeDrawing = NO;
	FBConnectButton.frame = CGRectMake(40.0f, 360.0f, 240.0f, 44.0f);
//	UIImage *FBConnectButtonBackground = [UIImage imageNamed:@"connectButton.png"];
//	[FBConnectButton setBackgroundImage:connectButtonBackground forState:UIControlStateNormal];
//	[FBConnectButton setBackgroundImage:connectButtonBackground forState:UIControlStateDisabled];	
	FBConnectButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	FBConnectButton.backgroundColor = [UIColor blueColor];
	[FBConnectButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
	[FBConnectButton addTarget:self action:@selector(connectWithFB) forControlEvents:UIControlEventTouchUpInside];
//	FBConnectButton.layer.cornerRadius = 13; // not necessary now that we'are using background image
//	FBConnectButton.clipsToBounds = YES; // not necessary now that we'are using background image
	[contentView addSubview:FBConnectButton];

	self.view = contentView;
	[contentView release];	
}

- (void)connectWithFB {
	// Connect to Facebook.

	// Find user by Facebook ID.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbId == %@", @"1112"]; // use fbId
	[fetchRequest setPredicate:predicate];
	NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
//	NSLog(@"results = %@", results);
	[fetchRequest release];
	User *myUser;
	if ([results count] == 1) {
		myUser = [results objectAtIndex:0];
//		NSLog(@"myUser = %@", myUser);
	} else { // create myUser from Facebook info if not found
		Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:managedObjectContext];
		myUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
// TODO: set location & update in background
//		[location setLatitude:myLocation];
//		[location setLongitude:myLocation];
		[myUser setLocation:location];
		[account setUser:myUser];
		[myUser setOnlineStatus:[NSNumber numberWithInteger:1]];
	}

	// Find top-level Interest, with name "Interests."
	fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Interest" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Interests"];
	[fetchRequest setPredicate:predicate];
	results = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	[fetchRequest release];
	Interest *tlInterest;
	if ([results count] == 1) {
		tlInterest = [results objectAtIndex:0];
	} else { // create tlInterest if not found
		tlInterest = (Interest *)[NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:managedObjectContext];
		[tlInterest setOid:@"0"];
		[tlInterest setName:@"acani"];
	}

	// Save changes if any.
	NSError *error;
	if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
		// TODO: handle this error correctly.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	// Push interstsViewController with myUser & top-level Interest.
	UINavigationController *navController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
	InterestsViewController *interestsViewController = (InterestsViewController *)[navController topViewController];
	interestsViewController.myUser = myUser;
	interestsViewController.theInterest = tlInterest;
	interestsViewController.title = [tlInterest name];

	navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
