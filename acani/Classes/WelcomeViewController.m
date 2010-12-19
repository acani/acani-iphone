#import "WelcomeViewController.h"


@implementation WelcomeViewController

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
	// Set up view.
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor lightGrayColor]; // default is nil (white)
	contentView.clearsContextBeforeDrawing = NO;

	// Add connect with Facebook button.
	UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	connectButton.clearsContextBeforeDrawing = NO;
	connectButton.frame = CGRectMake(40.0f, 360.0f, 240.0f, 44.0f);
//	UIImage *connectButtonBackground = [UIImage imageNamed:@"connectButton.png"];
//	[connectButton setBackgroundImage:connectButtonBackground forState:UIControlStateNormal];
//	[connectButton setBackgroundImage:connectButtonBackground forState:UIControlStateDisabled];	
	connectButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	connectButton.backgroundColor = [UIColor blueColor];
	[connectButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
	[connectButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
//	connectButton.layer.cornerRadius = 13; // not necessary now that we'are using background image
//	connectButton.clipsToBounds = YES; // not necessary now that we'are using background image
	[contentView addSubview:connectButton];

	self.view = contentView;
	[contentView release];	
}

- (void)connect {
	InterestsViewController *interestsView = [[InterestsViewController alloc] init];
	[self.navigationController pushViewController:interestsView animated:YES];
	[interestsView release];
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
