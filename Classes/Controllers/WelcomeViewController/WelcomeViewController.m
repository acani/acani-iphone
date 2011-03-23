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
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];
	if ([facebook isSessionValid]) {
		[appDelegate getUserInfo:appDelegate];
	} else {
		[appDelegate fbLogin];
	}
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
	[managedObjectContext release];
    [super dealloc];
}


@end
