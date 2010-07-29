#import "UsersViewController.h"
#import "ProfileViewController.h"
#import "PhotoViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation UsersViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)goToProfile:(id)sender {
	ProfileViewController *profileVC = [[[ProfileViewController alloc] init] autorelease];
//	[self.navigationController pushViewController:pvc animated:YES];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[navController setNavigationBarHidden:NO];
	
	[self presentModalViewController:navController animated:YES];
	NSLog(@"GoToProfile!");
}

- (void)goToPhoto:(id)sender {
	PhotoViewController *photoVC = [[[PhotoViewController alloc] init] autorelease];
	[self.navigationController pushViewController:photoVC animated:YES];
}

- (void)logout:(id)sender {
	// Discoonect
	NSLog(@"Logout");
}

- (void)loadView {
	self.navigationController.navigationBar.tintColor = [UIColor clearColor];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Profile", @selector(goToProfile:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Logout", @selector(logout:));

	UIView *contentView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor lightGrayColor];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
    label.text = @"Users View (TableView)";
    label.center = contentView.center;
	label.backgroundColor = [UIColor lightGrayColor];
	label.textAlignment = UITextAlignmentCenter;

	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, 100.0f, 120.0f, 44.0f)];
	[button setTitle:@"Photo View" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(goToPhoto:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:button];
	[button release];

    [contentView addSubview:label];
    [label release];

	self.view = contentView;
	[contentView release];
}

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
