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

//	[self performSelector:@selector(displayViews) withObject:nil afterDelay:3.0f];

- (void)done:(id)sender {
	[chatInput resignFirstResponder]; // temporary
}

// Reveal a Done button when editing starts
- (void)textViewDidBeginEditing:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));
}

- (void)textViewDidChange:(UITextView *)textView {
	if ([textView hasText]) {
		sendButton.enabled = YES;
		sendButton.titleLabel.alpha	= 1.0f;
		//		CGSize chatInputSize = [textView.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:chatInput.frame.size lineBreakMode:UILineBreakModeWordWrap];
		//		CGFloat newHeight = chatInputSize.height+10.0f + 18.0f;
		//		chatBar.frame = CGRectMake(chatBar.frame.origin.x, self.view.frame.origin.y+self.view.frame.size.height-newHeight, chatBar.frame.size.width, newHeight);
		chatContent.frame = CGRectMake(chatContent.frame.origin.x, chatContent.frame.origin.y, chatContent.frame.size.width, self.view.frame.size.height-80.f);
		chatBar.frame = CGRectMake(chatBar.frame.origin.x, self.view.frame.size.height - 80.f, self.view.frame.size.width, 80.f);
		chatInput.scrollEnabled = YES;
	} else {
		sendButton.enabled = NO;
		sendButton.titleLabel.alpha	= 0.5f;
		chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix bug, but is there a better way to fix this?
		// contentOffset never changes. It's something else. What is it?
		//		NSLog(@"%f, %f, %f, %f", chatInput.contentInset.top, chatInput.contentInset.right, chatInput.contentInset.bottom, chatInput.contentInset.left);
		//		NSLog(@"(%f, %f)", chatInput.contentOffset.x, chatInput.contentOffset.y);
		//		NSLog(@"%f x %f", chatInput.contentSize.width, chatInput.contentSize.height);
	}

}

// Prepare to resize for keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
//	NSDictionary *userInfo = [notification userInfo];
//	CGRect bounds;
//	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
//	// Resize text view
//	CGRect aFrame = chatInput.frame;
//	aFrame.size.height -= bounds.size.height;
//	chatInput.frame = aFrame;

	[self slideFrameUp];
	// These methods can do better.
	// They should check for version of iPhone OS.
	// And use appropriate methods to determine:
	//   animation movement, speed, duration, etc.
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification;
{
//	NSDictionary *userInfo = [notification userInfo];
//	CGRect bounds;
//	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];

	[self slideFrameDown];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];

	// create messages
	time_t now; time(&now);
	latestTimestamp = 0;
	Message *msg1 = [[Message alloc] init];
	msg1.text = @"text 1";
	msg1.timestamp = now - 10000;
	Message *msg2 = [[Message alloc] init];
	msg2.text = @"text 2 this is a longer message that should span two or more lines to show that resizing is working appropriately";
	msg2.timestamp = 0;
	Message *msg3 = [[Message alloc] init];
	msg3.text = @"text 3 a shorter message";
	msg3.timestamp = now - 7200;
	Message *msg4 = [[Message alloc] init];
	msg4.text = @"text 4 i want to add more messages here to see if the table view collapses nicely";
	msg4.timestamp = now - 4000;
	Message *msg5 = [[Message alloc] init];
	msg5.text = @"text 5 does it scroll well too?";
	msg5.timestamp = now - 2000;
	Message *msg6 = [[Message alloc] init];
	msg6.text = @"text 6 we are doing the resizing by resizing the UIView and setting its content sot autoresize";
	msg6.timestamp = now - 1500;

	latestTimestamp = msg6.timestamp;

	messages = [[NSMutableArray alloc] initWithObjects: msg1, msg2, msg3, msg4, msg5, msg6, nil];
	[msg1 release];
	[msg2 release];
	[msg3 release];
	[msg4 release];
	[msg5 release];
	[msg6 release];

	CGFloat viewWidth = self.view.frame.size.width;
	CGFloat viewHeight = self.view.frame.size.height;
	CGFloat chatBarHeight = 40.0f;

	NSLog(@"view.frame.size: %f x %f", viewWidth, viewHeight);

	// create chatContent
	chatContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, viewHeight - chatBarHeight)];
	chatContent.clearsContextBeforeDrawing = NO;
	chatContent.delegate = self;
	chatContent.dataSource = self;
	chatContent.backgroundColor = [UIColor chatBackgroundColor];
	chatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
	chatContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:chatContent];
	[chatContent release];

	// create chatBar
	chatBar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, viewHeight - chatBarHeight, viewWidth, chatBarHeight)];
	chatBar.clearsContextBeforeDrawing = NO;
	chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	chatBar.image = [[UIImage imageNamed:@"ChatBar.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
	chatBar.userInteractionEnabled = YES;

	// create chatInput
	chatInput = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 234.0f, 22.0f)];	
	chatInput.delegate = self;
	chatInput.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	chatInput.scrollEnabled = NO; // not initially
	chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, -3.0f);
	chatInput.clearsContextBeforeDrawing = NO;
	chatInput.font = [UIFont systemFontOfSize:14.0];
	chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
	chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	chatInput.contentOffset = CGPointMake(0, 0);
	chatInput.backgroundColor = [UIColor clearColor];
	chatInput.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[chatBar addSubview:chatInput];
	[chatInput release];

	// create sendButton
	sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	sendButton.clearsContextBeforeDrawing = NO;
	sendButton.frame = CGRectMake(250.0f, 8.0f, 64.0f, 26.0f);
	sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
	[sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
	[sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateDisabled];	
	sendButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	sendButton.titleLabel.alpha	= 0.5f;
	sendButton.backgroundColor = [UIColor clearColor];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(sendMSG:) forControlEvents:UIControlEventTouchUpInside];
	sendButton.layer.cornerRadius = 13; // not necessary now that we'are using background image
	sendButton.clipsToBounds = YES; // not necessary now that we'are using background image
	sendButton.enabled = NO; // not initially
	[chatBar addSubview:sendButton];
	[sendButton release];

	[self.view addSubview:chatBar];
	[self.view sendSubviewToBack: chatBar];
	[chatBar release];
	
	// Listen for keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)sendMSG:(id)sender {
	if (chatInput.text.length != 0) {
		Message *msg = [[Message alloc] init];
		msg.text = chatInput.text;
		time_t now; time(&now);
		if (now < latestTimestamp+780) { // show timestamp every 15 mins
			msg.timestamp = 0;
		} else {
			msg.timestamp = latestTimestamp = now;
		}
		[messages addObject: msg];
		[msg release];
		[chatContent reloadData];
		NSUInteger index = [messages count] - 1;
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
	
	if([messages count] > 0) {
		NSUInteger index = [messages count] - 1;
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
    return [messages count];
}


#define TIMESTAMP_TAG 1
#define TEXT_TAG 2
#define BACKGROUND_TAG 3
#define MESSAGE_TAG 4

CGFloat msgTimestampHeight;

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Message *msg = [messages objectAtIndex:indexPath.row];

    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		// Create messageView to contain subviews (boosts scrolling performance)
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height)];
		messageView.tag = MESSAGE_TAG;
		
		// Create message timestamp lable if appropriate
		msgTimestamp = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 12.0f)];
		msgTimestamp.clearsContextBeforeDrawing = NO;
		msgTimestamp.tag = TIMESTAMP_TAG;
		msgTimestamp.font = [UIFont boldSystemFontOfSize:11.0f];
		msgTimestamp.lineBreakMode = UILineBreakModeTailTruncation;
		msgTimestamp.textAlignment = UITextAlignmentCenter;
		msgTimestamp.backgroundColor = [UIColor chatBackgroundColor]; // clearColor slows performance
		msgTimestamp.textColor = [UIColor darkGrayColor];			
		[messageView addSubview:msgTimestamp];
		[msgTimestamp release];

		// Create message background image view
		msgBackground = [[UIImageView alloc] init];
		msgBackground.clearsContextBeforeDrawing = NO;
		msgBackground.tag = BACKGROUND_TAG;
		[messageView addSubview:msgBackground];
		[msgBackground release];

		// Create message text label
		msgText = [[UILabel alloc] init];
		msgText.clearsContextBeforeDrawing = NO;
		msgText.tag = TEXT_TAG;
		msgText.backgroundColor = [UIColor clearColor];
		msgText.numberOfLines = 0;
		msgText.lineBreakMode = UILineBreakModeWordWrap;
		msgText.font = [UIFont systemFontOfSize:14.0];
		[messageView addSubview:msgText];
		[msgText release];

		[cell.contentView addSubview:messageView];
		[messageView release];		
	} else {
		msgTimestamp = (UILabel *)[cell.contentView viewWithTag:TIMESTAMP_TAG];
		msgBackground = (UIImageView *)[[cell.contentView viewWithTag:MESSAGE_TAG] viewWithTag: BACKGROUND_TAG];
		msgText = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}

	if (msg.timestamp) {
		msgTimestampHeight = 20.0f;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Jan 1, 2010
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];  // 1:43 PM
		
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:msg.timestamp];
		
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]; // TODO: get locale from iPhone system prefs
		[dateFormatter setLocale:usLocale];
		[usLocale release];
		
		msgTimestamp.text = [dateFormatter stringFromDate:date];
		[dateFormatter release];
	} else {
		msgTimestampHeight = 0.0f;
		msgTimestamp.text = @"";
	}	

	CGSize size = [msg.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;

	if (indexPath.row % 2 == 0) {
		msgBackground.frame = CGRectMake(320.0f - (size.width + 35.0f), msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGreen.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
		msgText.frame = CGRectMake(298.0f - size.width, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
	} else {
		msgBackground.frame = CGRectMake(0.0f, msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGray.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
		msgText.frame = CGRectMake(22.0f, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
	}

	msgBackground.image = balloon;
	msgText.text = msg.text;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	Message *msg = [messages objectAtIndex:indexPath.row];
	msgTimestampHeight = msg.timestamp ? 20.0f : 0.0f;
	CGSize size = [msg.text sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];
	return size.height + 20.0f + msgTimestampHeight;
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
