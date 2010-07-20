#import "ChatViewController.h"
#import "Message.h"
#import "ColorUtils.h"
#include <time.h>
#import <QuartzCore/QuartzCore.h>

#define MAINLABEL	((UILabel *)self.navigationItem.titleView)
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation ChatViewController

#pragma mark -
#pragma mark Initialization


//- (id)initWithStyle:(UITableViewStyle)style {
//    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//    if ((self = [super initWithStyle:style])) {
//    }
//    return self;
//}

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView: (UIView *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
	for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	[outstring appendFormat:@"[%2d] %@\n", indent, [[aView class] description]];
	for (UIView *view in [aView subviews]) [self dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView
{
	NSMutableString *outstring = [[NSMutableString alloc] init];
	[self dumpView: self.view.window atIndent:0 into:outstring];
	return [outstring autorelease];
}

// Show the tree
- (void) displayViews
{
	CFShow([self displayViews: self.view.window]);
}


// Reveal a Done button when editing starts
- (void)textViewDidBeginEditing:(UITextView *)textView {
	[self performSelector:@selector(displayViews) withObject:nil afterDelay:3.0f];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", nil);
	[self slideFrameUp];
}

// Prepare to resize for keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
	NSLog(@"runit");

	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = textView.frame;
	aFrame.size.height -= bounds.size.height;
	textView.frame = aFrame;
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification;
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
	textView.frame = aFrame;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];

	// create messages
	Message *msg1 = [[Message alloc] init];
	msg1.text = @"text 1";
	//	msg1.timestamp = 399999;
	Message *msg2 = [[Message alloc] init];
	msg2.text = @"text 2 this is a longer message that should span two or more lines to show that resizing is working appropriately";
	//	msg2.timestamp = 399999;
	Message *msg3 = [[Message alloc] init];
	msg3.text = @"text 3 a shorter message";
	//	msg2.timestamp = 399999;
	messages = [[NSMutableArray alloc] initWithObjects: msg1, msg2, msg3, nil];
	[msg1 release];
	[msg2 release];
	
	// create tableview
	UITableView *chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 380.0)];
	chatTableView.delegate = self;
	chatTableView.dataSource = self;
	chatTableView.backgroundColor = [UIColor chatBackgroundColor];
	[self.view addSubview:chatTableView];
	[chatTableView release];

	// create toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 380.0, 320.0, 40.0)];
	
	// create textView
	textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 8.0, 240, 25)];
	textView.delegate = self;
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
	
//
//	// Listen for keyboard
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
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
-(void) slideFrameUp {
	[self slideFrame:YES];
}

-(void) slideFrameDown {
	[self slideFrame:NO];
}

// Decrease height of UIView when keyboard pops up
-(void) slideFrame:(BOOL)up {
	const int movementDistance = 210; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed
	
	int movement = (up ? -movementDistance : movementDistance);
	
	[UIView beginAnimations: @"anim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	CGRect viewFrame = self.view.frame;
	viewFrame.size.height += movement;
	self.view.frame = viewFrame;
	[UIView commitAnimations];
}



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
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
//	CGFloat height = [indexPath row] * 70;
//	return height;
	Message *msg = [messages objectAtIndex:indexPath.row];
	NSString *text = msg.text;
	CGSize size = [text sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];
	return size.height + 15 + 22;
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

		Message *msg = [messages objectAtIndex:indexPath.row];

		// Create timestampLabel
		timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 16.0)];
		timestampLabel.backgroundColor = [UIColor chatBackgroundColor]; // clearColor slows performance
		timestampLabel.tag = TIMESTAMP_TAG;
		timestampLabel.font = [UIFont boldSystemFontOfSize:12.0];
		timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
		timestampLabel.textAlignment = UITextAlignmentCenter;
		timestampLabel.textColor = [UIColor darkGrayColor];
		time_t t;
		time(&t);
		timestampLabel.text = [[NSString alloc] initWithFormat:@"%s", ctime(&t)];

		// Create text		
		textLabel = [[UILabel alloc] init];
		textLabel.tag = TEXT_TAG;
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.numberOfLines = 0;
		textLabel.lineBreakMode = UILineBreakModeWordWrap;
		textLabel.font = [UIFont systemFontOfSize:14.0];
		textLabel.text = msg.text; // @"This is just a hard-coded message.";


		// Create background
		backgroundImageView = [[UIImageView alloc] init];
		backgroundImageView.tag = BACKGROUND_TAG;

		CGSize size = [textLabel.text sizeWithFont: [UIFont systemFontOfSize:14.0]constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];
		UIImage *balloon;
		if (indexPath.row%2 == 0) {
			backgroundImageView.frame = CGRectMake(320.0f - (size.width + 28.0f), 22.0f, size.width +28.0f, size.height + 15.0f);
			backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			balloon = [[UIImage imageNamed:@"ChatBubbleGreen.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:13];
			
			textLabel.frame = CGRectMake(307.0f - (size.width + 5.0f), 28.0f, size.width + 5.0f, size.height);
			textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		} else {
			backgroundImageView.frame = CGRectMake(0.0, 22.0f, size.width +28.0f, size.height + 15.0f);
			backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
			balloon = [[UIImage imageNamed:@"ChatBubbleGray.png"]stretchableImageWithLeftCapWidth:23 topCapHeight:15];
			
			textLabel.frame = CGRectMake(16.0f, 28.0f, size.width + 5.0f, size.height);
			textLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		}

		backgroundImageView.image = balloon;

		// Create messageView and add to cell
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height)];
	    messageView.tag = MESSAGE_TAG;
		[messageView addSubview:timestampLabel];
		[messageView addSubview:backgroundImageView];
		[messageView addSubview:textLabel];
		messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[cell.contentView addSubview:messageView];
		
		[timestampLabel release];
		[backgroundImageView release];
		[textLabel release];
		[messageView release];
	} else {
		timestampLabel = (UILabel *)[cell.contentView viewWithTag:TIMESTAMP_TAG];
		backgroundImageView = (UIImageView *)[[cell.contentView viewWithTag:MESSAGE_TAG] viewWithTag: BACKGROUND_TAG];
		textLabel = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}
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
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
