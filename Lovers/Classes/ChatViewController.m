#import "ChatViewController.h"
#import "Message.h"
#import "ColorUtils.h"
#include <time.h>
#import <QuartzCore/QuartzCore.h>

#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

@implementation ChatViewController

#pragma mark -
#pragma mark Initialization


//- (id)initWithStyle:(UITableViewStyle)style {
//    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//    if ((self = [super initWithStyle:style])) {
//    }
//    return self;
//}


#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor chatBackgroundColor];

	// create tableview
	UITableView *tableView = [[UITableView alloc] init];
	tableView.frame = CGRectMake(0.0, 0.0, 320,380.0);
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	[tableView release];

	// create toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 380.0, 320.0, 40.0)];
	
	// create textView
	textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 8.0, 240, 25)];
	textView.layer.cornerRadius = 15;
	textView.clipsToBounds = YES;
	textView.textAlignment = UITextAlignmentCenter;
	textView.userInteractionEnabled = YES;
	[toolbar addSubview:textView];
	[textView release];

	// create send button
	UIButton *sendButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	sendButton.frame = CGRectMake(260.0f, 7.0f, 40.0f, 26.0f);
	sendButton.titleLabel.font = [UIFont systemFontOfSize: 14];
	sendButton.backgroundColor = [UIColor clearColor];
	
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:self action:NO forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:sendButton];
	[sendButton release];

	[self.view addSubview:toolbar];
	[toolbar release];
}

//- (void)send:(id)sender {
//	if (textView.text.length != 0) {
//		NSLog(@"push function");
//		Message *mesg2 = [[Message alloc] init];
//		mesg2.text = textView.text;
//		//mesg2.timestamp = time(NULL);
//		mesg2.timestamp = timestampLabel.text;
//		[messages addObject: mesg2];
//		[mesg2 release];
//		[tbl reloadData]; 
//		textView.text = @""; // clear textView after send
//		
//		// Scroll up tableView
//		NSInteger nSections = [tbl numberOfSections];
//		NSInteger nRows = [tbl numberOfRowsInSection:nSections - 1];
//		NSIndexPath * indexPath = [NSIndexPath indexPathForRow:nRows - 1 inSection:nSections - 1];
//		[tbl scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//	}
//}
//
//-(IBAction) slideFrameUp {
//	[self slideFrame:YES];
//}
//
//-(IBAction) slideFrameDown {
//	[self slideFrame:NO];
//}
//
//// Shrink tableView when keyboard pops up
//-(void) slideFrame:(BOOL) up
//{
//	const int movementDistance = 210; // tweak as needed
//	const float movementDuration = 0.3f; // tweak as needed
//	
//	int movement = (up ? -movementDistance : movementDistance);
//	
//	[UIView beginAnimations: @"anim" context: nil];
//	[UIView setAnimationBeginsFromCurrentState: YES];
//	[UIView setAnimationDuration: movementDuration];
//	offset = tbl.contentOffset;
//	CGRect viewFrame = tbl.frame;
//	viewFrame.size.height += movement;
//	tbl.frame = viewFrame;
//	toolBar.frame = CGRectOffset(toolBar.frame, 0, movement);
//	NSInteger nSections = [tbl numberOfSections];
//	NSInteger nRows = [tbl numberOfRowsInSection:nSections - 1];
//	NSIndexPath * indexPath = [NSIndexPath indexPathForRow:nRows - 1 inSection:nSections - 1];
//	[tbl scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//	[UIView commitAnimations];
//}



/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	CGFloat height = [indexPath row] * 70;
	return height;
} 


#define TIMESTAMP_TAG 1
#define TEXT_TAG 2
#define BACKGROUND_TAG 3
#define MESSAGE_TAG 4

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageCell";

	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

//		Message *msg = [messages objectAtIndex:indexPath.row];

		// Create timestampLabel
		UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 16.0)];
		timestampLabel.backgroundColor = [UIColor chatBackgroundColor]; // clearColor slows performance
		timestampLabel.tag = TIMESTAMP_TAG;
		timestampLabel.font = [UIFont boldSystemFontOfSize:12.0];
		timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
		timestampLabel.textAlignment = UITextAlignmentCenter;
		timestampLabel.textColor = [UIColor darkGrayColor];
		time_t t;
		time(&t);
		timestampLabel.text = [[NSString alloc] initWithFormat:@"%s", ctime(&t)];


		//    UIImageView *backgroundImage;


//		// Create text		
//		UILabel *textLabel = [[UILabel alloc] init];
//		textLabel.tag = TEXT_TAG;
//		textLabel.backgroundColor = [UIColor clearColor];
//		textLabel.numberOfLines = 0;
//		textLabel.lineBreakMode = UILineBreakModeWordWrap;
//		textLabel.font = [UIFont systemFontOfSize:14.0];
//		textLabel.text = msg.text;
		
	
		// Create messageView and add to cell
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height)];
	    messageView.tag = MESSAGE_TAG;
		[messageView addSubview:timestampLabel];
//		[messageView addSubview:backgroundImage];
//		[messageView addSubview:textLabel];
		messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[cell.contentView addSubview:messageView];

		[timestampLabel release];
		[messageView release];		
	}
    
    // Configure the cell...
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

