#import "BubblesViewController.h"
#import "Message.h"
#include <time.h>

@implementation BubblesViewController

@synthesize tbl, messages, choosePhotoBtn, textfield, imageView, toolBar,timestampLabel;

CGPoint offset;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// release the msg1 later
	Message * msg1 = [[Message alloc] init];
	msg1.text = @"text 1";
//	msg1.timestamp = 399999;
	
	messages = [[NSMutableArray alloc] initWithObjects: msg1, nil];
	[msg1 release];

	tbl.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [messages count];
}

-(IBAction) getPhoto:(id) sender {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
}

-(IBAction) push:(id)sender {
	if (textfield.text.length != 0) {
		NSLog(@"push function");
		Message *mesg2 = [[Message alloc] init];
		mesg2.text = textfield.text;
		//mesg2.timestamp = time(NULL);
		mesg2.timestamp = timestampLabel.text;
		[messages addObject: mesg2];
		[mesg2 release];
		[tbl reloadData]; 
		textfield.text = @""; // clear textfield after send

		// Scroll up tableView
		NSInteger nSections = [tbl numberOfSections];
		NSInteger nRows = [tbl numberOfRowsInSection:nSections - 1];
		NSIndexPath * indexPath = [NSIndexPath indexPathForRow:nRows - 1 inSection:nSections - 1];
		[tbl scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

-(IBAction) slideFrameUp {
	[self slideFrame:YES];
}

-(IBAction) slideFrameDown {
	[self slideFrame:NO];
}

// Shrink tableView when keyboard pops up
-(void) slideFrame:(BOOL) up
{
	const int movementDistance = 210; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed
	
	int movement = (up ? -movementDistance : movementDistance);
	
	[UIView beginAnimations: @"anim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	offset = tbl.contentOffset;
	CGRect viewFrame = tbl.frame;
	viewFrame.size.height += movement;
	tbl.frame = viewFrame;
	toolBar.frame = CGRectOffset(toolBar.frame, 0, movement);
	NSInteger nSections = [tbl numberOfSections];
	NSInteger nRows = [tbl numberOfRowsInSection:nSections - 1];
	NSIndexPath * indexPath = [NSIndexPath indexPathForRow:nRows - 1 inSection:nSections - 1];
	[tbl scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	[UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#define TIMESTAMP_TAG 1
#define TEXT_TAG 2
#define BACKGROUND_TAG 3
#define MESSAGE_TAG 4

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"MessageCell";
	
	UILabel *text;
    UIImageView *background;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

		Message *msg = [messages objectAtIndex:indexPath.row];

		// Create timestampLabel
		timestampLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, 16.0)] autorelease];
		timestampLabel.backgroundColor = [UIColor clearColor];
		timestampLabel.tag = TIMESTAMP_TAG;
        timestampLabel.font = [UIFont boldSystemFontOfSize:12.0];
		timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
        timestampLabel.textAlignment = UITextAlignmentCenter;
        timestampLabel.textColor = [UIColor darkGrayColor];
		time_t t;
		time(&t);
		timestampLabel.text = [[NSString alloc] initWithFormat:@"%s", ctime(&t)];
	


		// Create text		
		text = [[UILabel alloc] init];
		text.tag = TEXT_TAG;
		text.backgroundColor = [UIColor clearColor];
		text.numberOfLines = 0;
		text.lineBreakMode = UILineBreakModeWordWrap;
		text.font = [UIFont systemFontOfSize:14.0];
		text.text = msg.text;
		//time(NULL)

		// Create background
		background = [[UIImageView alloc] init];
		background.tag = BACKGROUND_TAG;
						   

		// Create messageView and add to cell
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, cell.frame.size.height)];
	    messageView.tag = MESSAGE_TAG;
		[messageView addSubview:timestampLabel];
		[messageView addSubview:background];
		[messageView addSubview:text];
		messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[cell.contentView addSubview:messageView];

		
		[background release];
		[text release];
		[messageView release];
	} else {
		timestampLabel = (UILabel *)[cell.contentView viewWithTag:TIMESTAMP_TAG];
		background = (UIImageView *)[[cell.contentView viewWithTag:MESSAGE_TAG] viewWithTag: BACKGROUND_TAG];
		text = (UILabel *)[cell.contentView viewWithTag:TEXT_TAG];
	}

	CGSize size = [text.text sizeWithFont: [UIFont systemFontOfSize:14.0]constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];
	UIImage *balloon;
	if (indexPath.row%2 == 0) {
		background.frame = CGRectMake(320.0f - (size.width + 28.0f), 22.0f, size.width +28.0f, size.height + 15.0f);
	    background.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		balloon = [[UIImage imageNamed:@"green.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:13];
	
		text.frame = CGRectMake(307.0f - (size.width + 5.0f), 28.0f, size.width + 5.0f, size.height);
	    text.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	} else {
		background.frame = CGRectMake(0.0, 22.0f, size.width +28.0f, size.height + 15.0f);
	    background.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		balloon = [[UIImage imageNamed:@"grey.png"]stretchableImageWithLeftCapWidth:23 topCapHeight:15];
		
		text.frame = CGRectMake(16.0f, 28.0f, size.width + 5.0f, size.height);
	    text.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	}

	background.image = balloon;
	
	return cell;
}

-(CGFloat)tableView: (UITableView*) tableView hightForRowAtIndexPath :(NSIndexPath *)indexPath{
	
	Message *msg = [messages objectAtIndex:indexPath.row];
	NSString *text = msg.text;
	
	CGSize size = [text sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: CGSizeMake(240.0f, 480.0f)lineBreakMode: UILineBreakModeWordWrap];

	return size.height + 15;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.tbl  = nil;
	self.messages = nil;
}

- (void)dealloc {
	//[msg1 release];
	[timestampLabel release];
	[tbl release];
	[messages release];
    [super dealloc];
}

@end
