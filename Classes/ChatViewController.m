#import "ChatViewController.h"

@implementation ChatViewController

- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor lightGrayColor];

	self.view = contentView;
    [contentView release];
	
	ChatView *cv = [[ChatView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	[self.view addSubview:cv];	

	
	// For testing the console pane
	NSLog(@"Hello World!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

@end
