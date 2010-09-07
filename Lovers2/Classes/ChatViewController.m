#import "ChatViewController.h"
#import "LoversAppDelegate.h"
#import "Message.h"
#import "Constants.h"
#include <time.h>
#import <QuartzCore/QuartzCore.h>
#import "ZTWebSocket.h"
#import "SBJSON.h"

#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

#define CHAT_BAR_HEIGHT_1	40.0f
#define CHAT_BAR_HEIGHT_4	94.0f
#define VIEW_WIDTH	self.view.frame.size.width
#define VIEW_HEIGHT	self.view.frame.size.height

#define RESET_CHAT_BAR_HEIGHT	SET_CHAT_BAR_HEIGHT(CHAT_BAR_HEIGHT_1)
#define EXPAND_CHAT_BAR_HEIGHT	SET_CHAT_BAR_HEIGHT(CHAT_BAR_HEIGHT_4)
#define	SET_CHAT_BAR_HEIGHT(HEIGHT) \
	CGRect chatContentFrame = chatContent.frame; \
	chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT; \
	[UIView beginAnimations:nil context:NULL]; \
	[UIView setAnimationDuration:0.1f]; \
	chatContent.frame = chatContentFrame; \
	chatBar.frame = CGRectMake(chatBar.frame.origin.x, chatContentFrame.size.height, VIEW_WIDTH, HEIGHT); \
	[UIView commitAnimations]; \

#define ENABLE_SEND_BUTTON	SET_SEND_BUTTON(YES, 1.0f)
#define DISABLE_SEND_BUTTON	SET_SEND_BUTTON(NO, 0.5f)
#define SET_SEND_BUTTON(ENABLED, ALPHA) \
	sendButton.enabled = ENABLED; \
	sendButton.titleLabel.alpha = ALPHA

@implementation ChatViewController

@synthesize channel;
@synthesize messages;
@synthesize latestTimestamp;

@synthesize chatContent;
@synthesize msgTimestamp;
@synthesize msgBackground;
@synthesize msgText;

@synthesize chatBar;
@synthesize chatInput;
@synthesize lastContentHeight;
@synthesize chatInputHadText;
@synthesize sendButton;


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
	self.navigationItem.rightBarButtonItem = nil;
}

// Reveal a Done button when editing starts
- (void)textViewDidBeginEditing:(UITextView *)textView {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
								   target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)textViewDidChange:(UITextView *)textView {
	CGFloat contentHeight = textView.contentSize.height - 12.0f;

	NSLog(@"contentOffset: (%f, %f)", textView.contentOffset.x, textView.contentOffset.y);
	NSLog(@"contentInset: %f, %f, %f, %f", textView.contentInset.top, textView.contentInset.right, textView.contentInset.bottom, textView.contentInset.left);
	NSLog(@"contentSize.height: %f", contentHeight);

	if ([textView hasText]) {
		if (!chatInputHadText) {
			ENABLE_SEND_BUTTON;
			chatInputHadText = YES;
		}

		if (textView.text.length > 1024) { // truncate text to 1024 chars
			textView.text = [textView.text substringToIndex:1024];
		}

		// Resize textView to contentHeight
		if (contentHeight != lastContentHeight) {
			if (contentHeight <= 76.0f) { // Limit chatInputHeight <= 4 lines
				CGFloat chatBarHeight = contentHeight + 18.0f;
				SET_CHAT_BAR_HEIGHT(chatBarHeight);
				if (lastContentHeight > 76.0f) {
					textView.scrollEnabled = NO;
				}
				textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
			} else if (lastContentHeight <= 76.0f) { // grow
				textView.scrollEnabled = YES;
				textView.contentOffset = CGPointMake(0.0f, contentHeight-68.0f); // shift to bottom
				if (lastContentHeight < 76.0f) {
					EXPAND_CHAT_BAR_HEIGHT;
				}
			}
		}	
	} else { // textView is empty
		if (chatInputHadText) {
			DISABLE_SEND_BUTTON;
			chatInputHadText = NO;
		}
		if (lastContentHeight > 22.0f) {
			RESET_CHAT_BAR_HEIGHT;
			if (lastContentHeight > 76.0f) {
				textView.scrollEnabled = NO;
			}
		}		
		textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk			
	}
	lastContentHeight = contentHeight;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	return YES;
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
- (void)keyboardWillHide:(NSNotification *)notification {
//	NSDictionary *userInfo = [notification userInfo];
//	CGRect bounds;
//	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];

	[self slideFrameDown];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];
	NSLog(@"channel: %@", channel);

//	UIView *self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
//	self.view.backgroundColor = [UIColor lightGrayColor];

//	// create messages
//	time_t now; time(&now);
//	latestTimestamp = 0;
//	Message *msg1 = [[Message alloc] init];
//	msg1.text = @"text 1";
//	msg1.timestamp = now - 10000;
//	Message *msg2 = [[Message alloc] init];
//	msg2.text = @"text 2 this is a longer message that should span two or more lines to show that resizing is working appropriately";
//	msg2.timestamp = 0;
//	Message *msg3 = [[Message alloc] init];
//	msg3.text = @"text 3 a shorter message";
//	msg3.timestamp = now - 7200;
//	Message *msg4 = [[Message alloc] init];
//	msg4.text = @"text 4 i want to add more messages here to see if the table view collapses nicely";
//	msg4.timestamp = now - 4000;
//	Message *msg5 = [[Message alloc] init];
//	msg5.text = @"text 5 does it scroll well too?";
//	msg5.timestamp = now - 2000;
//	Message *msg6 = [[Message alloc] init];
//	msg6.text = @"text 6 we are doing the resizing by resizing the UIView and setting its content sot autoresize";
//	msg6.timestamp = now - 1500;
//
//	latestTimestamp = msg6.timestamp;
//
//	messages = [[NSMutableArray alloc] initWithObjects: msg1, msg2, msg3, msg4, msg5, msg6, nil];
//	[msg1 release];
//	[msg2 release];
//	[msg3 release];
//	[msg4 release];
//	[msg5 release];
//	[msg6 release];

	NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel == %@", channel];
	[request setPredicate:predicate];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];

	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	[self setMessages:mutableFetchResults];
	[mutableFetchResults release];
	[request release];

	// create chatContent
	NSLog(@"Create chatContent");
	chatContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, VIEW_WIDTH, VIEW_HEIGHT - CHAT_BAR_HEIGHT_1)];
	chatContent.clearsContextBeforeDrawing = NO;
	chatContent.delegate = self;
	chatContent.dataSource = self;
	chatContent.backgroundColor = CHAT_BACKGROUND_COLOR;
	chatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
	chatContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:chatContent];
	[chatContent release];

	// create chatBar
	chatBar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, VIEW_HEIGHT - CHAT_BAR_HEIGHT_1, VIEW_WIDTH, CHAT_BAR_HEIGHT_1)];
	chatBar.clearsContextBeforeDrawing = NO;
	chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	chatBar.image = [[UIImage imageNamed:@"ChatBar.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:20];
	chatBar.userInteractionEnabled = YES;

	// create chatInput
	chatInput = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 234.0f, 22.0f)];
	chatInput.contentSize = CGSizeMake(234.0f, 22.0f);
	chatInput.delegate = self;
	chatInput.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	chatInput.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	chatInput.scrollEnabled = NO; // not initially
	chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 4.0f, -2.0f);
	chatInput.clearsContextBeforeDrawing = NO;
	chatInput.font = [UIFont systemFontOfSize:14.0];
	chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
	chatInput.backgroundColor = [UIColor clearColor];
	lastContentHeight = chatInput.contentSize.height;
	chatInputHadText = NO;
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
	sendButton.backgroundColor = [UIColor clearColor];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(sendMSG:) forControlEvents:UIControlEventTouchUpInside];
//	sendButton.layer.cornerRadius = 13; // not necessary now that we'are using background image
//	sendButton.clipsToBounds = YES; // not necessary now that we'are using background image
	DISABLE_SEND_BUTTON; // initially
	[chatBar addSubview:sendButton];
	[sendButton release];

	[self.view addSubview:chatBar];
	[self.view sendSubviewToBack:chatBar];
	[chatBar release];

//	self.view = contentView;
//	[contentView release];

	// Listen for keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


// - (void)viewDidLoad {
// [super viewDidLoad];
// 
// // Uncomment the following line to preserve selection between presentations.
// // self.clearsSelectionOnViewWillAppear = NO;
// 
// // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// // self.navigationItem.rightBarButtonItem = self.editButtonItem;
// }


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

//// This causes exception if there are no cells.
//// Also, I want it to work like iPhone Messages.
//- (void)viewDidAppear:(BOOL)animated {
//	[super viewDidAppear:animated];
//	[self scrollToBottomAnimated:YES]; 
//}

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

- (void)sendMSG:(id)sender {
	// This is not really necessary since we disable the
	// "Send" button unless the chatInput has text.
	if (![chatInput hasText]) {
		NSLog(@"Cannot send message, no text");
		return;
	}
	
	NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	Message *msg = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:managedObjectContext];
	[msg setText:chatInput.text];
	[msg setSender:@"me"];
	[msg setChannel:channel];
	time_t now; time(&now);
	latestTimestamp = now;
	[msg setTimestamp:[NSNumber numberWithLong:now]];

	ZTWebSocket *webSocket = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket];
	if (![webSocket connected]) {
		NSLog(@"Cannot send message, not connected");
		return;
	} 

//	[activityIndicator startAnimating];
	
	NSString *escapedMsg = [[[[msg text] // escape chars: \ " \n
							  stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
							 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
							stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	NSLog(@"escapedMSG: %@", escapedMsg);
	
	NSString *msgJson = [NSString stringWithFormat:
						 @"{\"timestamp\":%@,\"channel\":\"%@\",\"sender\":\"%@\",\"text\":\"%@\",\"to_uid_public\":\"bob\"}",
						 [msg timestamp], [msg channel], [msg sender], escapedMsg];
	[webSocket send:msgJson];

	chatInput.text = @"";
	if (lastContentHeight > 22.0f) {
		RESET_CHAT_BAR_HEIGHT;
		chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
		chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk			
	}		

	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	[messages addObject:msg];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0];
	[chatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
	[self scrollToBottomAnimated:YES]; 
}

- (void)scrollToBottomAnimated:(BOOL)animated {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0];
	[chatContent scrollToRowAtIndexPath:indexPath
					   atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)slideFrameUp {
	[self slideFrame:YES];
}

- (void)slideFrameDown {
	[self slideFrame:NO];
}

// Shorten height of UIView when keyboard pops up
- (void)slideFrame:(BOOL)up {
	const int movementDistance = 216; // set to keyboard variable	
	int movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	CGRect viewFrame = self.view.frame;
	viewFrame.size.height += movement;
	self.view.frame = viewFrame;
	[UIView commitAnimations];
	
	if ([messages count] > 0) {
		NSUInteger index = [messages count] - 1;
		[chatContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
	chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}


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
	Message *msg = (Message *)[messages objectAtIndex:indexPath.row];

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
		msgTimestamp.backgroundColor = CHAT_BACKGROUND_COLOR; // clearColor slows performance
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
		msgBackground = (UIImageView *)[[cell.contentView viewWithTag:MESSAGE_TAG] viewWithTag:BACKGROUND_TAG];
		msgText = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}

//	time_t now; time(&now);
//	if (now < latestTimestamp+780) // show timestamp every 15 mins
//		msg.timestamp = 0;
			
	if (true) { // latestTimestamp > ([[msg timestamp] longValue]+780)) {
		msgTimestampHeight = 20.0f;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Jan 1, 2010
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];  // 1:43 PM
		
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[msg timestamp] doubleValue]];
		
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]; // TODO: get locale from iPhone system prefs
		[dateFormatter setLocale:usLocale];
		[usLocale release];
		
		msgTimestamp.text = [dateFormatter stringFromDate:date];
		[dateFormatter release];
	} else {
		msgTimestampHeight = 0.0f;
		msgTimestamp.text = @"";
	}	

	CGSize size = [[msg text] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;

	if ([[msg sender] isEqualToString:@"me"]) {
		msgBackground.frame = CGRectMake(320.0f - (size.width + 35.0f), msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGreen.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
		msgText.frame = CGRectMake(298.0f - size.width, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
	} else {
		msgBackground.frame = CGRectMake(0.0f, msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGray.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
		msgText.frame = CGRectMake(22.0f, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
	}

	msgBackground.image = balloon;
	msgText.text = [msg text];
	
	// Let's instead do this (asynchronously) from loadView and iterate over all messages
	if ([msg unread]) { // then save as read
		[msg setUnread:[NSNumber numberWithBool:NO]];
		NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Error saving message as read! %@", error);
		}		
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	Message *msg = (Message *)[messages objectAtIndex:indexPath.row];
	msgTimestampHeight = 20.0f; // [msg timestamp] ? 20.0f : 0.0f;
	CGSize size = [[msg text] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
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
	[super viewDidUnload];
	self.channel = nil;
	self.messages = nil;

	self.msgTimestamp = nil;
	self.msgBackground = nil;
	self.msgText = nil;
	self.chatContent = nil;

	self.sendButton = nil;
	self.chatInput = nil;
	self.chatBar = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {

// This crashes for some reason...
//	[channel release];
//	[messages release];
//
//	[msgTimestamp release];
//	[msgBackground release];
//	[msgText release];
//	[chatContent release];
//
//	[sendButton release];
//	[chatInput release];
//	[chatBar release];

	[super dealloc];
}

@end
