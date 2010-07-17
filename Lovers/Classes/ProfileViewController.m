#import "ProfileViewController.h"

@implementation ProfileViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)saveProfile:(id)sender {
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor blueColor];

	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Profile"];
//	UIBarButtonItem *saveBtn = 
	navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile:)];
	[navBar pushNavigationItem:navItem animated:NO];
	[contentView addSubview:navBar];

//	// This didn't work, but is it possible to use the UsersViewController's
//	// navigationController's navBar instead of making a new one?
//    [contentView addSubview:self.parentViewController.navigationController.navigationBar];

//	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, 100.0f, 90.0f, 44.0f)];
//	[button setTitle:@"Save2" forState:UIControlStateNormal];
//	[button addTarget:self action:@selector(saveProfile:) forControlEvents:UIControlEventTouchUpInside];
//	[contentView addSubview:button];

	[navItem release];
	[navItem.leftBarButtonItem release];
	[navBar release];

	self.view = contentView;
	[contentView release];
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
