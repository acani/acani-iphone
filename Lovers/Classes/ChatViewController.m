#import "ChatViewController.h"
#import "LoversAppDelegate.h"
#import "Message.h"
#import "User.h"
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
#define	SET_CHAT_BAR_HEIGHT(HEIGHT)\
	CGRect chatContentFrame = chatContent.frame;\
	chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT;\
	[UIView beginAnimations:nil context:NULL];\
	[UIView setAnimationDuration:0.1f];\
	chatContent.frame = chatContentFrame;\
	chatBar.frame = CGRectMake(chatBar.frame.origin.x, chatContentFrame.size.height, VIEW_WIDTH, HEIGHT);\
	[UIView commitAnimations]

#define ENABLE_SEND_BUTTON	SET_SEND_BUTTON(YES, 1.0f)
#define DISABLE_SEND_BUTTON	SET_SEND_BUTTON(NO, 0.5f)
#define SET_SEND_BUTTON(ENABLED, ALPHA)\
	sendButton.enabled = ENABLED;\
	sendButton.titleLabel.alpha = ALPHA

@implementation ChatViewController

@synthesize channel;

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize latestTimestamp;

@synthesize chatContent;

@synthesize chatBar;
@synthesize chatInput;
@synthesize lastContentHeight;
@synthesize chatInputHadText;
@synthesize sendButton;


#pragma mark -
#pragma mark Text view delegate

- (void)done:(id)sender {
	[chatInput resignFirstResponder]; // temporary
	RESET_CHAT_BAR_HEIGHT;
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

// This fixes a scrolling quirk
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
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.navigationBar.tintColor = ACANI_RED;

	// Create contentView.
	CGRect navFrame = [[UIScreen mainScreen] applicationFrame];
	navFrame.size.height -= self.navigationController.navigationBar.frame.size.height;
	UIView *contentView = [[UIView alloc] initWithFrame:navFrame];
	contentView.backgroundColor = CHAT_BACKGROUND_COLOR; // shown during rotation

	// Create chatContent.
	UITableView *tempChatContent = [[UITableView alloc] initWithFrame:
					   CGRectMake(0.0f, 0.0f, contentView.frame.size.width,
								  contentView.frame.size.height - CHAT_BAR_HEIGHT_1)];
	self.chatContent = tempChatContent;
	[tempChatContent release];
	chatContent.clearsContextBeforeDrawing = NO;
	chatContent.delegate = self;
	chatContent.dataSource = self;
	chatContent.backgroundColor = CHAT_BACKGROUND_COLOR;
	chatContent.separatorStyle = UITableViewCellSeparatorStyleNone;
	chatContent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[contentView addSubview:chatContent];

	// Create chatBar.
	UIImageView *tempChatBar = [[UIImageView alloc] initWithFrame:
				   CGRectMake(0.0f, contentView.frame.size.height - CHAT_BAR_HEIGHT_1,
							  contentView.frame.size.width, CHAT_BAR_HEIGHT_1)];
	self.chatBar = tempChatBar;
	[tempChatBar release];
	chatBar.clearsContextBeforeDrawing = NO;
	chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	chatBar.image = [[UIImage imageNamed:@"ChatBar.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:20];
	chatBar.userInteractionEnabled = YES;

	// Create chatInput.
	UITextView *tempChatInput = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 234.0f, 22.0f)];
	self.chatInput = tempChatInput;
	[tempChatInput release];
	chatInput.contentSize = CGSizeMake(234.0f, 22.0f);
	chatInput.delegate = self;
	chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	chatInput.scrollEnabled = NO; // not initially
	chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 4.0f, -2.0f);
	chatInput.clearsContextBeforeDrawing = NO;
	chatInput.font = [UIFont systemFontOfSize:14.0];
	chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
	chatInput.backgroundColor = [UIColor clearColor];
	lastContentHeight = chatInput.contentSize.height;
	chatInputHadText = NO;
	[chatBar addSubview:chatInput];

	// Create sendButton.
	self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.clearsContextBeforeDrawing = NO;
	sendButton.frame = CGRectMake(chatBar.frame.size.width - 70.0f, 8.0f, 64.0f, 26.0f);  // multi-line input & landscape (below)
	sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	UIImage *sendButtonBackground = [UIImage imageNamed:@"SendButton.png"];
	[sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
	[sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateDisabled];	
	sendButton.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
	sendButton.backgroundColor = [UIColor clearColor];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchUpInside];
//	sendButton.layer.cornerRadius = 13; // not necessary now that we'are using background image
//	sendButton.clipsToBounds = YES; // not necessary now that we'are using background image
	DISABLE_SEND_BUTTON; // initially
	[chatBar addSubview:sendButton];

	[contentView addSubview:chatBar];
	[contentView sendSubviewToBack:chatBar];

	self.view = contentView;
	[contentView release];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.channel = @"myid_4c9c179714672857ed00001f"; // for testing
	NSLog(@"channel: %@", channel);

	// Create and configure a fetch request.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	// Set the predicate to only fetch messages from this channel.
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel == %@", channel];
	[fetchRequest setPredicate:predicate];
	
	// Create the sort descriptors array.
	NSSortDescriptor *timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:timestampDescriptor, nil];
	[timestampDescriptor release];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptors release];

	// Create and initialize the fetchedResultsController.
	NSFetchedResultsController *aFetchedResultsController = \
		[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
											managedObjectContext:managedObjectContext
											  sectionNameKeyPath:nil // only generate one section
													   cacheName:@"Message"];
	[fetchRequest release];
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	fetchedResultsController.delegate = self;

	NSError *error;
	if (![fetchedResultsController performFetch:&error]) {
		// TODO: Handle the error appropriately.
		NSLog(@"fetchMessages error %@, %@", error, [error userInfo]);
	}

	// Listen for keyboard.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

//  // TODO: Implement edit mode like iPhone Messages does. (Icebox)
//	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


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


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	self.navigationController.navigationBar.tintColor = nil;
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)sendMsg {
	//	// TODO: Show progress indicator like iPhone Message app does. (Icebox)
	//	[activityIndicator startAnimating];

	ZTWebSocket *webSocket = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket];
	if (![webSocket connected]) {
		NSLog(@"Cannot send message, not connected");
		return;
	} 

	// Create new message and save to Core Data.
	Message *msg = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message"
															inManagedObjectContext:managedObjectContext];
	[msg setText:chatInput.text];
	[msg setSender:(Profile *)[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] user]];
	[msg setChannel:channel];
	time_t now; time(&now);
	latestTimestamp = now;
	[msg setTimestamp:[NSNumber numberWithLong:now]];

	NSError *error;
	if (![managedObjectContext save:&error]) {
		// TODO: Handle the error appropriately.
		NSLog(@"SendMsg error %@, %@", error, [error userInfo]);
	}

	// Escape message and send via WebSocket connection.
	NSString *escapedMsg = [[[[msg text] // escape chars: \ " \n, respectively
							  stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
							 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
							stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	NSLog(@"escapedMSG: %@", escapedMsg);
	NSString *msgJson = [NSString stringWithFormat:
						 @"{\"type\":\"txt\",\"timestamp\":%@,\"channel\":\"%@\",\"sender\":\"%@\",\"text\":\"%@\",\"to_oid_public\":\"bob\"}",
						 [msg timestamp], [msg channel], [(User *)[msg sender] oid], escapedMsg];
	[webSocket send:msgJson];

	// Clear chatInput.
	chatInput.text = @"";
	if (lastContentHeight > 22.0f) {
		RESET_CHAT_BAR_HEIGHT;
		chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
		chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk			
	}		
	
	[self scrollToBottomAnimated:YES]; 
}

- (void)scrollToBottomAnimated:(BOOL)animated {
	NSUInteger bottomRow = [[fetchedResultsController fetchedObjects] count] - 1;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
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
// TODO: Test on different SDK versions; make more flexible if desired.
- (void)slideFrame:(BOOL)up {
	CGFloat movementDistance;

	UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
		movementDistance = 216.0f;
    } else {
		movementDistance = 162.0f;
    }
	CGFloat movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	CGRect viewFrame = self.view.frame;
	viewFrame.size.height += movement;
	self.view.frame = viewFrame;
	[UIView commitAnimations];

	
	if ([[fetchedResultsController fetchedObjects] count] > 0) {
		[self scrollToBottomAnimated:YES];
	}
	chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[fetchedResultsController fetchedObjects] count];
}


#define TIMESTAMP_TAG 1
#define TEXT_TAG 2
#define BACKGROUND_TAG 3

CGFloat msgTimestampHeight;

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *msgTimestamp;
	UIImageView *msgBackground;
	UILabel *msgText;

    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Create message timestamp lable if appropriate
		msgTimestamp = [[[UILabel alloc] initWithFrame:
						 CGRectMake(0.0f, 0.0f, chatContent.frame.size.width, 12.0f)] autorelease];
		msgTimestamp.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		msgTimestamp.clearsContextBeforeDrawing = NO;
		msgTimestamp.tag = TIMESTAMP_TAG;
		msgTimestamp.font = [UIFont boldSystemFontOfSize:11.0f];
		msgTimestamp.lineBreakMode = UILineBreakModeTailTruncation;
		msgTimestamp.textAlignment = UITextAlignmentCenter;
		msgTimestamp.backgroundColor = CHAT_BACKGROUND_COLOR; // clearColor slows performance
		msgTimestamp.textColor = [UIColor darkGrayColor];			
		[cell.contentView addSubview:msgTimestamp];

		// Create message background image view
		msgBackground = [[[UIImageView alloc] init] autorelease];
		msgBackground.clearsContextBeforeDrawing = NO;
		msgBackground.tag = BACKGROUND_TAG;
		[cell.contentView addSubview:msgBackground];

		// Create message text label
		msgText = [[[UILabel alloc] init] autorelease];
		msgText.clearsContextBeforeDrawing = NO;
		msgText.tag = TEXT_TAG;
		msgText.backgroundColor = [UIColor clearColor];
		msgText.numberOfLines = 0;
		msgText.lineBreakMode = UILineBreakModeWordWrap;
		msgText.font = [UIFont systemFontOfSize:14.0];
		[cell.contentView addSubview:msgText];
	} else {
		msgTimestamp = (UILabel *)[cell.contentView viewWithTag:TIMESTAMP_TAG];
		msgBackground = (UIImageView *)[cell.contentView viewWithTag:BACKGROUND_TAG];
		msgText = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}

	// Configure the cell to show the message in a bubble.
	Message *msg = [fetchedResultsController objectAtIndexPath:indexPath];
		
// TODO: Only show timestamps every 15 mins
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

	// Layout message cell & its subviews.
	CGSize size = [[msg text] sizeWithFont:[UIFont systemFontOfSize:14.0]
						 constrainedToSize:CGSizeMake(240.0f, CGFLOAT_MAX)
							 lineBreakMode:UILineBreakModeWordWrap];
	UIImage *balloon;
	if ([[(User *)[msg sender] oid] isEqualToString:
		 [(User *)[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] user] oid]]) {
		msgBackground.frame = CGRectMake(chatContent.frame.size.width - (size.width + 35.0f), msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGreen.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:13];
		msgText.frame = CGRectMake(chatContent.frame.size.width - 22.0f - size.width,
								   5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
		msgBackground.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		msgText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	} else {
		msgBackground.frame = CGRectMake(0.0f, msgTimestampHeight, size.width + 35.0f, size.height + 13.0f);
		balloon = [[UIImage imageNamed:@"ChatBubbleGray.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
		msgText.frame = CGRectMake(22.0f, 5.0f + msgTimestampHeight, size.width + 5.0f, size.height);
	}
	msgBackground.image = balloon;
	msgText.text = [msg text];

	// Mark message as read.
	// Let's instead do this (asynchronously) from loadView and iterate over all messages
	if ([msg unread]) { // then save as read
		[msg setUnread:[NSNumber numberWithBool:NO]];
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// TODO: Handle the error appropriately.
			NSLog(@"Save msg as read error %@, %@", error, [error userInfo]);
		}		
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
 	Message *msg = [fetchedResultsController objectAtIndexPath:indexPath];
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
#pragma mark Fetched results controller

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {

	switch(type) {
		case NSFetchedResultsChangeInsert:
			[chatContent insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
			
		case NSFetchedResultsChangeDelete:
			[chatContent deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
	}
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

	self.fetchedResultsController = nil;

	self.chatContent = nil;

	self.sendButton = nil;
	self.chatInput = nil;
	self.chatBar = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[channel release];

	[fetchedResultsController release];
	[managedObjectContext release];

	[chatContent release];

	[sendButton release];
	[chatInput release];
	[chatBar release];

	[super dealloc];
}

@end
