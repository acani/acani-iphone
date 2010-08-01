#import "PhotoViewController.h"
#import "ChatViewController.h"

@implementation PhotoViewController

#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

- (void)goToChat:(id)sender {
	ChatViewController *chatView = [[[ChatViewController alloc] init] autorelease];
	[self.navigationController pushViewController:chatView animated:YES];
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor cyanColor];
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Chat", @selector(goToChat:));
	
	self.view = contentView;
	[contentView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	overlay = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 150, 150)];
	overlay.backgroundColor = [UIColor clearColor];
	
	UIButton * moveMe = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	moveMe.frame = CGRectMake(100, 100, 70, 30);
	
	moveMe.backgroundColor = [UIColor whiteColor];
	moveMe.titleLabel.text = @"move";
	moveMe.titleLabel.textColor = [UIColor blackColor];
	[moveMe addTarget:self action:@selector(moveOverlay:) forControlEvents:UIControlEventTouchUpInside];
	
	[overlay addSubview:moveMe];
	
	//UILabel *userInfo = [UILabel alloc] initwithFrame: CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
	[self.view addSubview:overlay];
	
}

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

- (IBAction)backButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moveOverlay:(id)sender {
	if (self.view.window!=nil) {
		[UIView beginAnimations: @"move_Overlay" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		
		//headerView.alpha = 0.0;
		overlay.frame = CGRectMake(-90.0, overlay.frame.origin.y, overlay.frame.size.width, overlay.frame.size.height) ;
		//backBtn.alpha = 0.0;
		
		[UIView commitAnimations];
	}
}

@end
