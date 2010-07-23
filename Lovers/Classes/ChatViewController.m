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
	[outstring appendFormat:@"[%2d] %@ - (%f, %f) - %f x %f \n", indent, [[aView class] description], aView.frame.origin.x, aView.frame.origin.y, aView.bounds.size.width, aView.bounds.size.height];
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

- (void)done:(id)sender {
	[chatInput resignFirstResponder]; // temporary
	[self slideFrameDown];
}

// Reveal a Done button when editing starts
- (void)textViewDidBeginEditing:(UITextView *)textView {
	[self performSelector:@selector(displayViews) withObject:nil afterDelay:3.0f];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));
	[self slideFrameUp];
	[textView scrollRangeToVisible:NSMakeRange(0,0)];
}

// Prepare to resize for keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
	NSLog(@"runit");

	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = chatInput.frame;
	aFrame.size.height -= bounds.size.height;
	chatInput.frame = aFrame;
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification;
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
	chatInput.frame = aFrame;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];

	// create storedMsgs
	Message *msg1 = [[Message alloc] init];
	msg1.text = @"text 1";
	//	msg1.timestamp = 399999;
	Message *msg2 = [[Message alloc] init];
	msg2.text = @"text 2 this is a longer message that should span two or more lines to show that resizing is working appropriately";
	//	msg2.timestamp = 399999;
	Message *msg3 = [[Message alloc] init];
	msg3.text = @"text 3 a shorter message";
	//	msg3.timestamp = 399999;
	Message *msg4 = [[Message alloc] init];
	msg4.text = @"text 4 i want to add more storedMsgs here to see if the table view collapses nicely";
	//	msg4.timestamp = 399999;
	Message *msg5 = [[Message alloc] init];
	msg5.text = @"text 5 does it scroll well too?";
	//	msg5.timestamp = 399999;
	Message *msg6 = [[Message alloc] init];
	msg6.text = @"text 6 we are doing the resizing by resizing the UIView and setting its content sot autoresize";
	//	msg6.timestamp = 399999;
	storedMsgs = [[NSMutableArray alloc] initWithObjects: msg1, msg2, msg3, msg4, msg5, msg6, nil];
	[msg1 release];
	[msg2 release];

	CGFloat viewWidth = self.view.frame.size.width;
	CGFloat viewHeight = self.view.frame.size.height;
	CGFloat chatFooterHeight = 33.0f;

	NSLog(@"view.frame.size: %f x %f", viewWidth, viewHeight);

	// create tableview
	chatContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, viewHeight - chatFooterHeight)];
	chatContent.clearsContextBeforeDrawing = NO;
	chatContent.delegate = self;
	chatContent.dataSource = self;
	chatContent.backgroundColor = [UIColor chatBackgroundColor];
	chatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
	chatContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:chatContent];
	[chatContent release];

	// create toolbar
	chatFooter = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, viewHeight - chatFooterHeight, viewWidth, chatFooterHeight)];
	chatFooter.clearsContextBeforeDrawing = NO;
	chatFooter.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

	// create textView
	chatInput = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 6.0f, 240.0f, 22.0f)];
	chatInput.clearsContextBeforeDrawing = NO;
	chatInput.delegate = self;
	chatInput.font = [UIFont systemFontOfSize:14.0];
	chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
	chatInput.layer.cornerRadius = 12;
	chatInput.clipsToBounds = YES;
	chatInput.userInteractionEnabled = YES;
	[chatFooter addSubview:chatInput];
	[chatInput release];

	// create send button
	UIButton *sendButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	sendButton.clearsContextBeforeDrawing = NO;
	sendButton.frame = CGRectMake(270.0f, 5.0f, 40.0f, 24.0f);
	sendButton.titleLabel.font = [UIFont systemFontOfSize: 14];
	sendButton.backgroundColor = [UIColor clearColor];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(sendMSG:) forControlEvents:UIControlEventTouchUpInside];
	[chatFooter addSubview:sendButton];
	[sendButton release];

	[self.view addSubview:chatFooter];
	[chatFooter release];
	
//
//	// Listen for keyboard
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)sendMSG:(id)sender {
	if (chatInput.text.length != 0) {
		Message *msg = [[Message alloc] init];
		msg.text = chatInput.text;
		time_t t; time(&t);
		msg.timestamp = ctime(&t);
		[storedMsgs addObject: msg];
		[msg release];
		[chatContent reloadData];
		NSUInteger index = [storedMsgs count] - 1;
		[chatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		chatInput.text = @"";
	}
}

-(void) slideFrameUp {
	[self slideFrame:YES];
}

-(void) slideFrameDown {
	[self slideFrame:NO];
}

// Shorten height of UIView when keyboard pops up
-(void) slideFrame:(BOOL)up {
	const int movementDistance = 216; // set to keyboard variable	
	int movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	CGRect viewFrame = self.view.frame;
	viewFrame.size.height += movement;	
	self.view.frame = viewFrame;
	[UIView commitAnimations];	
	
	if([storedMsgs count] > 0) {
		NSUInteger index = [storedMsgs count] - 1;
		[chatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
	
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
    return [storedMsgs count];
}


#define TIMESTAMP_TAG 1
#define TEXT_TAG 2
#define BACKGROUND_TAG 3
#define MESSAGE_TAG 4

CGFloat msgTimestampHeight = 24.0f; // 24.0f;

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		// Create message timestamp lable
		msgTimestamp = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 6.0, 320.0, 14.0)];
		msgTimestamp.clearsContextBeforeDrawing = NO;
		msgTimestamp.tag = TIMESTAMP_TAG;
		msgTimestamp.font = [UIFont boldSystemFontOfSize:12.0];
		msgTimestamp.lineBreakMode = UILineBreakModeTailTruncation;
		msgTimestamp.textAlignment = UITextAlignmentCenter;
		msgTimestamp.backgroundColor = [UIColor chatBackgroundColor]; // clearColor slows performance
		msgTimestamp.textColor = [UIColor darkGrayColor];
		time_t t;
		time(&t);
		msgTimestamp.text = [[NSString alloc] initWithFormat:@"%s", ctime(&t)];

		// Create text		
		msgText = [[UILabel alloc] init];
		msgText.clearsContextBeforeDrawing = NO;
		msgText.tag = TEXT_TAG;
		msgText.backgroundColor = [UIColor clearColor];
		msgText.numberOfLines = 0;
		msgText.lineBreakMode = UILineBreakModeWordWrap;
		msgText.font = [UIFont systemFontOfSize:14.0];

		// Create background
		msgBackground = [[UIImageView alloc] init];
		msgBackground.clearsContextBeforeDrawing = NO;
		msgBackground.tag = BACKGROUND_TAG;

		// Create messageView and add to cell
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height)];
		messageView.tag = MESSAGE_TAG;
		[messageView addSubview:msgTimestamp];
		[messageView addSubview:msgBackground];
		[messageView addSubview:msgText];
		messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[cell.contentView addSubview:messageView];
		
		[msgTimestamp release];
		[msgBackground release];
		[msgText release];
		[messageView release];		
	} else {
		msgTimestamp = (UILabel *)[cell.contentView viewWithTag:TIMESTAMP_TAG];
		msgBackground = (UIImageView *)[[cell.contentView viewWithTag:MESSAGE_TAG] viewWithTag: BACKGROUND_TAG];
		msgText = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}

	Message *msg = [storedMsgs objectAtIndex:indexPath.row];
	CGSize size = [msg.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;

	if (indexPath.row % 2 == 0) {
		msgBackground.frame = CGRectMake(320.0f - (size.width + 28.0f), msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		msgBackground.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		balloon = [[UIImage imageNamed:@"ChatBubbleGreen.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:13];
		
		msgText.frame = CGRectMake(305.0f - size.width, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
		msgText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	} else {
		msgBackground.frame = CGRectMake(0.0f, msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		msgBackground.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		balloon = [[UIImage imageNamed:@"ChatBubbleGray.png"]stretchableImageWithLeftCapWidth:23 topCapHeight:15];
		
		msgText.frame = CGRectMake(22.0f, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
		msgText.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	}
	
	//		if(indexPath.row % 2 == 0) {
	//			msgBackground.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
	//			balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
	//			msgText.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
	//		} else {
	//			msgBackground.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);
	//			balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
	//			msgText.frame = CGRectMake(16, 8, size.width + 5, size.height);
	//		}
	
	msgBackground.image = balloon;
	msgText.text = msg.text;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	Message *msg = [storedMsgs objectAtIndex:indexPath.row];
	CGSize size = [msg.text sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];
	return size.height + 22.0f + msgTimestampHeight/2.0f;
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
