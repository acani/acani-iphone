#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

#define MAINLABEL ((UILabel *)self.navigationItem.titleView)

#define ABOUT_ROW 0
#define SEX_ROW 1
#define LIKES_ROW 2
#define BIRTHDAY_ROW 3
#define HEIGHT_ROW 4
#define WEIGHT_ROW 5
#define ETHNICITY_ROW 6
#define FB_USERNAME_ROW 7

#define NAME_TAG 120
#define HEADLINE_TAG 121
#define ABOUT_TAG 122
#define FB_USERNAME_TAG 123


@implementation ProfileViewController

@synthesize myUser;

@synthesize saveButton;
@synthesize doneButton;
@synthesize textDone;

@synthesize avatarImg;
@synthesize profileName;
@synthesize headlineInput;

@synthesize aboutInput;
@synthesize valueInput;

@synthesize profileFields;
@synthesize pickerOptions;
@synthesize components;
@synthesize valueSelect;
@synthesize editIndexPath;
@synthesize editTextTag;


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)cancel:(id)sender {
	if (valueSelect.superview != nil) {
		[self donePickingValue:self];
	} else { // TODO: add condition here. Interesting link:
// http://stackoverflow.com/questions/1490573/how-to-programatically-check-whether-a-keyboard-is-present-in-iphone-app
		[self doneEditingText:self];
	}
	
	NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[managedObjectContext refreshObject:myUser mergeChanges:NO]; // get rid of changes
	[self dismissModalViewControllerAnimated:YES];
}

- (void)saveProfile:(id)sender {
	NSDictionary *changes = [myUser changedValues];
	if ([changes count] == 0) {
		// TODO: notify me that no changes were made
		[[self parentViewController] dismissModalViewControllerAnimated:YES];
		return;
	}

//	// Might be better to have the server response be the updated time,
//	// and then we could store that on the iPhone.
//	NSDate *now = [[NSDate alloc] init];
//	[myUser setUpdated:now];
//	[now release];

	NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error. What's the best way to handle this?
		NSLog(@"Error saving profile to iPhone: %@", error);
	}

	// Send a PUT request to: /{oid}
	// See sample in sample-profile-put-request.txt
	HTTPOperation *operation = [[[HTTPOperation alloc] init] autorelease];
	operation.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	operation.oid = myUser.oid;
	operation.params = [User encodeKeysInDictionary:changes];
	
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:operation];
	
	// TODO: dismiss before we get response back from server w/o crashing
	[[self parentViewController] dismissModalViewControllerAnimated:YES];	
}


#pragma mark -
#pragma mark Initialization

- (id)initWithMe:(User *)user {
	if (!(self = [super init])) return self;
	self.myUser = user;
	self.title = @"Edit Profile";
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	// I'm not sure how to initialize the default tableView as grouped, so create our own:
	UITableView *groupedTable = [[UITableView alloc] initWithFrame:
								 [UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
	groupedTable.delegate = self;
	groupedTable.dataSource = self;
	self.view = groupedTable;
	[groupedTable release];

	self.navigationController.navigationBar.tintColor = ACANI_RED;

	// Create UIBarButtonItems
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Cancel"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];

	UIBarButtonItem *localSaveButton = [[UIBarButtonItem alloc] 
					   initWithTitle:@"Save"
					   style:UIBarButtonItemStyleBordered
					   target:self 
					   action:@selector(saveProfile:)];
	self.saveButton = localSaveButton;
	[localSaveButton release];

	self.navigationItem.rightBarButtonItem = saveButton;

	UIBarButtonItem *localDoneButton = [[UIBarButtonItem alloc] 
					   initWithTitle:@"Done"
					   style:UIBarButtonItemStyleBordered
					   target:self 
					   action:@selector(donePickingValue:)];
	self.doneButton = localDoneButton;
	[localDoneButton release];
	
	UIBarButtonItem *localTextDone = [[UIBarButtonItem alloc] 
					  initWithTitle:@"Done"
					  style:UIBarButtonItemStyleBordered
					  target:self 
					  action:@selector(doneEditingText:)];
	self.textDone = localTextDone;
	[localTextDone release];

	// Create the tableHeaderView.	
	UIView *profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 86.0f)];
	profileHeader.clearsContextBeforeDrawing = NO;
	profileHeader.backgroundColor = [UIColor clearColor];

	self.avatarImg = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarImg.clearsContextBeforeDrawing = NO;
	[avatarImg addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[avatarImg setBackgroundImage:[UIImage imageNamed:@"BlankAvatar.png"] forState:UIControlStateNormal];
	[avatarImg setTitle:@"Tap to edit" forState:UIControlStateNormal];
	avatarImg.frame = CGRectMake(10.0f, 18.0f, 75.0f, 75.0f);
	avatarImg.titleLabel.clearsContextBeforeDrawing = NO;
	avatarImg.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
	avatarImg.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 8.0f, 0.0f);
	avatarImg.titleLabel.text = @"Tap to edit";
	avatarImg.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
	avatarImg.titleLabel.shadowColor = [UIColor blackColor];
	avatarImg.titleLabel.textColor = [UIColor whiteColor];	
	avatarImg.titleLabel.font = [UIFont systemFontOfSize:11.0f];
	[profileHeader addSubview:avatarImg];

	UITextField *localProfileName = [[UITextField alloc] initWithFrame:CGRectMake(96.0f, 28.0f, 212.0f, 21.0f)];
	self.profileName = localProfileName;
	[localProfileName release];
	profileName.clearsContextBeforeDrawing = NO;
	profileName.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
	profileName.adjustsFontSizeToFitWidth = YES;
	profileName.minimumFontSize = 10.0f;
//	profileName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	profileName.delegate = self;
	profileName.backgroundColor = [UIColor clearColor];
	profileName.placeholder = @"Name Here";
	profileName.tag = NAME_TAG;
	[profileHeader addSubview:profileName];
	[profileName release];

	UITextField *localheadlineInput = [[UITextField alloc] initWithFrame:CGRectMake(96.0f, 58.0f, 212.0f, 21.0f)];
	self.headlineInput = localheadlineInput;
	[localheadlineInput release];
	headlineInput.clearsContextBeforeDrawing = NO;
	headlineInput.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
	headlineInput.adjustsFontSizeToFitWidth = YES;
	headlineInput.minimumFontSize = 10.0f;
	headlineInput.delegate = self;
	headlineInput.backgroundColor = [UIColor clearColor];
	headlineInput.placeholder = @"Headline";
	headlineInput.tag = HEADLINE_TAG;
	[profileHeader addSubview:headlineInput];
	[headlineInput release];
	
	self.tableView.tableHeaderView = profileHeader;	// note this overrides UITableView's 'sectionHeaderHeight' property
	[profileHeader release];

	// set up the table's header view
	UIView *profileFooter = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 60.0f)];
	profileFooter.clearsContextBeforeDrawing = NO;
	profileFooter.backgroundColor = [UIColor clearColor];
	
	UIButton *clearChatsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	clearChatsButton.frame = CGRectMake(9.0f, 0.0f, 302.0f, 48.0f);
	clearChatsButton.clearsContextBeforeDrawing = NO;
	clearChatsButton.backgroundColor = [UIColor clearColor];
	[clearChatsButton setTitle:@"Clear All Chats" forState:UIControlStateNormal];
	[clearChatsButton addTarget:self action:@selector(clearChats:) forControlEvents:UIControlEventTouchUpInside];
	[profileFooter addSubview:clearChatsButton];

	self.tableView.tableFooterView = profileFooter;
	[profileFooter release];

	UIPickerView *localValueSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200.0f, 320.0f, 0.0f)]; // should height be 220.0f?
	self.valueSelect = localValueSelect;
	[localValueSelect release];
	valueSelect.clearsContextBeforeDrawing = NO;
	valueSelect.showsSelectionIndicator = YES;
	valueSelect.delegate = self;

	// This should be sqlite or something persistent. Maybe plist?
	NSArray *localProfileFields = [[NSArray alloc] initWithObjects:
					 [NSArray arrayWithObjects:@"About", @"Sex", @"Likes", @"Age", @"Height", @"Weight", @"Ethnicity", @"Facebook", nil],
					 [NSArray arrayWithObjects:@"Show Distance", @"Sex Filter", @"Age Filter", nil], nil];
	self.profileFields = localProfileFields;
	[localProfileFields release];

	NSArray *localPickerOptions = [[NSArray alloc] initWithObjects:
					 [NSArray arrayWithObjects: // section: 0
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show", @"Female", @"Male", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show", @"Women", @"Men", @"Both", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show",
						// Instead of making these long arrays, we can just put in a switch statement
						// for age & weight (perhaps even height) that translates the current row to an
						// age or weight string. We could even give an age/weight offset, so that
						// instead of starting them at 1, we could start them at a higher number.
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
						@"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
						@"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
						@"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
						@"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
						@"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59",
						@"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69",
						@"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79",
						@"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89",
						@"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99",
						@"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109",
						@"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119",
						@"120", @"121", @"122", @"123", @"124", @"125", @"126", @"127", @"128", @"129",
						@"130", @"131", @"132", @"123", @"124", @"125", @"126", @"127", @"128", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show", @"5 feet", @"6 feet", @"7 feet", nil],
					   [NSArray arrayWithObjects:@"0 inches", @"1 inches", @"2 inches", @"3 inches", @"4 inches", @"5 inches", @"6 inches", @"7 inches", @"8 inches", @"9 inches", @"10 inches", @"11 inches", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show",
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
						@"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
						@"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
						@"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
						@"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
						@"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59",
						@"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69",
						@"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79",
						@"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89",
						@"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99",						
						@"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109",
						@"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119",
						@"120", @"121", @"122", @"123", @"124", @"125", @"126", @"127", @"128", @"129",
						@"130", @"131", @"132", @"133", @"134", @"135", @"136", @"137", @"138", @"139",
						@"140", @"141", @"142", @"143", @"144", @"145", @"146", @"147", @"148", @"149",
						@"150", @"151", @"152", @"153", @"154", @"155", @"156", @"157", @"158", @"159",
						@"160", @"161", @"162", @"163", @"164", @"165", @"166", @"167", @"168", @"169",
						@"170", @"171", @"172", @"173", @"174", @"175", @"176", @"177", @"178", @"179",
						@"180", @"181", @"182", @"183", @"184", @"185", @"186", @"187", @"188", @"189",
						@"190", @"191", @"192", @"193", @"194", @"195", @"196", @"197", @"198", @"199",
						@"200", @"201", @"202", @"203", @"204", @"205", @"206", @"207", @"208", @"209",
						@"210", @"211", @"212", @"213", @"214", @"215", @"216", @"217", @"218", @"219",
						@"220", @"221", @"222", @"223", @"224", @"225", @"226", @"227", @"228", @"229",
						@"230", @"231", @"232", @"233", @"234", @"235", @"236", @"237", @"238", @"239",
						@"240", @"241", @"242", @"243", @"244", @"245", @"246", @"247", @"248", @"249",
						@"250", @"251", @"252", @"253", @"254", @"255", @"256", @"257", @"258", @"259",
						@"260", @"261", @"262", @"263", @"264", @"265", @"266", @"267", @"268", @"269",
						@"270", @"271", @"272", @"273", @"274", @"275", @"276", @"277", @"278", @"279",
						@"280", @"281", @"282", @"283", @"284", @"285", @"286", @"287", @"288", @"289",
						@"290", @"291", @"292", @"293", @"294", @"295", @"296", @"297", @"298", @"299",
						@"300", @"301", @"302", @"303", @"304", @"305", @"306", @"307", @"308", @"309",
						@"310", @"311", @"312", @"313", @"314", @"315", @"316", @"317", @"318", @"319",
						@"320", @"321", @"322", @"323", @"324", @"325", @"326", @"327", @"328", @"329",
						@"330", @"331", @"332", @"333", @"334", @"335", @"336", @"337", @"338", @"339",
						@"340", @"341", @"342", @"343", @"344", @"345", @"346", @"347", @"348", @"349",
						@"350", @"351", @"352", @"353", @"354", @"355", @"356", @"357", @"358", @"359",
						@"360", @"361", @"362", @"363", @"364", @"365", @"366", @"367", @"368", @"369",
						@"370", @"371", @"372", @"373", @"374", @"375", @"376", @"377", @"378", @"379",
						@"380", @"381", @"382", @"383", @"384", @"385", @"386", @"387", @"388", @"389",
						@"390", @"391", @"392", @"393", @"394", @"395", @"396", @"397", @"398", @"399",
						@"400", nil], nil],					  
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Do Not Show", @"Asian", @"Black", @"Latino", @"Middle Eastern", @"Mixed", @"Native American", @"White", @"Other", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"", nil], nil], nil],
					 [NSArray arrayWithObjects:  // section: 1
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"Both", @"Women only", @"Men only", nil], nil],
					  [NSArray arrayWithObjects:
					   [NSArray arrayWithObjects:@"No min", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", @"120", @"121", @"122", nil],
					   [NSArray arrayWithObjects:@"No max", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", @"120", @"121", @"122", nil], nil], nil], nil];
	self.pickerOptions = localPickerOptions;
	[localPickerOptions release];

//	NSLog(@"pickerOptions: %@", pickerOptions);
//	NSLog(@"pickerOptions obj: %@", [[[pickerOptions objectAtIndex:0] objectAtIndex:1] objectAtIndex:0]);
//	NSLog(@"self.view.window.subviews: %@", self.view.window.subviews);	
//	NSLog(@"self.view.subviews: %@", self.view.subviews);	
//	NSLog(@"self.view.window: %@", self.view.window);

//	// More views than you could dream of! 
//	printf("\nAll window subviews:\n");
//	NSLog(@"self.view.window: %@", allApplicationViews());

	// Listen for keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
//	NSString *myName = ; // change to fullName
//	NSString *myHeadline = [myUser headline];
//	
//	if ([myName length] == 0) {
//		myName = @"Name Here";
//	}
//	if ([myHeadline length] == 0) {
//		myHeadline = @"Headline";
//		headlineInput.color = [
//	}
	
	profileName.text = [myUser name];
	headlineInput.text = [myUser headline];

	// Uncomment the following line to preserve selection between presentations.
//	self.clearsSelectionOnViewWillAppear = NO;

	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//	 self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

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
-(void)imageButtonClicked:(id)sender {
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
	[action showInView:self.view];
}


#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		NSLog(@"Take Photo");
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:picker animated:YES];
	} else if (buttonIndex == 0) {
		NSLog(@"Choose Photo");
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:picker animated:YES];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	[picker dismissModalViewControllerAnimated:YES];
	[avatarImg setBackgroundImage:image forState:UIControlStateNormal];
	//userImageView.contentMode = UIViewContentModeScaleAspectFit;
}

// Fix with show UIPicker first. Then, uncomment.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// // Return YES for supported orientations
// return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

- (void)switchAction:(id)sender {
	[myUser setShowDistance:[NSNumber numberWithBool:[sender isOn]]];
}

#pragma mark -
#pragma mark Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Basic Information:";
	} else {
		return @"Filter Option:";
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [profileFields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[profileFields objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *fieldText = [[profileFields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	NSString *valueText;
	static NSString *CellID;
	UITableViewCell *cell;

	if (indexPath.section == 0 && indexPath.row == ABOUT_ROW) {
		CellID = @"TextView";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if (aboutInput == nil) {
				UITextView *localAboutInput = [[UITextView alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 50.0f)];
				self.aboutInput = localAboutInput;
				[localAboutInput release];
				//	self.aboutInput.scrollEnabled = NO;
				aboutInput.clearsContextBeforeDrawing = NO;
				aboutInput.font = [UIFont systemFontOfSize:14.0];
				//	aboutInput.dataDetectorTypes = UIDataDetectorTypeAll;
				aboutInput.backgroundColor = [UIColor grayColor];
				aboutInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
				aboutInput.delegate = self;			
				aboutInput.tag = ABOUT_TAG;
			}
			[cell.contentView addSubview:aboutInput];
		}
		aboutInput.text = [myUser about];
	} else if (indexPath.section == 0 && indexPath.row == FB_USERNAME_ROW) {
		CellID = @"TextField";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			if (valueInput == nil) {
				UITextField *localValueInput = [[UITextField alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 30.0f)];
				self.valueInput = localValueInput;
				[localValueInput release];
				valueInput.clearsContextBeforeDrawing = NO;
				valueInput.font = [UIFont systemFontOfSize:14.0];
				valueInput.backgroundColor = [UIColor lightGrayColor];
				valueInput.delegate = self;			
				valueInput.tag = FB_USERNAME_TAG;
			}
			[cell.contentView addSubview:valueInput];
		}
		valueInput.text = [myUser fbUsername];
	} else if (indexPath.section == 1 && indexPath.row == 0) { // Distance Filter Cell
		CellID = @"Switch";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UISwitch *filter = [[UISwitch alloc] initWithFrame:CGRectMake(194, 8, 94, 27)];
			[filter addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
			filter.on = [[myUser showDistance] boolValue];
			[cell.contentView addSubview:filter];
			[filter release]; // is this okay to release here since we set an action for it above?
		}
	} else if (indexPath.section == 0) { // Section 0 cells
		CellID = @"Default2";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}

		NSArray *Sexes = [(AppDelegate *)[[UIApplication sharedApplication] delegate] Sexes];
		NSArray *Ethnicities = [(AppDelegate *)[[UIApplication sharedApplication] delegate] Ethnicities];
		NSArray *Likes = [(AppDelegate *)[[UIApplication sharedApplication] delegate] Likes];

		NSNumber *valueNum;
		switch (indexPath.row) {
			case SEX_ROW:
				// If I try to set cell.detailTextLabel directly here, I get readonly error.
				valueNum = [myUser sex];
				valueText = [Sexes objectAtIndex:[valueNum intValue]];
				break;
			case LIKES_ROW:
				valueNum = [myUser likes];
				valueText = [Likes objectAtIndex:[valueNum intValue]];
				break;
			case BIRTHDAY_ROW:
				valueText = [valueNum stringValue];
				break;
			case HEIGHT_ROW: // TODO: convert height to inches & feet if in USA
				valueNum = [myUser height];
				valueText = [NSString stringWithFormat:@"%@ cm", [myUser height]];
				break;
			case WEIGHT_ROW: // TODO: convert weight to kilos if not in USA
				valueNum = [myUser weight];
				valueText = [NSString stringWithFormat:@"%@ lbs", [myUser weight]];
				break;
			case ETHNICITY_ROW:
				valueNum = [myUser ethnicity];
				valueText = [Ethnicities objectAtIndex:[[myUser ethnicity] intValue]];
				break;
			default:
				break;
		}
		
		if ([valueNum intValue] == 0) { // indexPath.row != BIRTHDAY_ROW &&
			valueText = @"Optional";
		}

		cell.detailTextLabel.text = valueText;
	} else { // Section 1 cells
		CellID = @"Default1";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		cell.detailTextLabel.text = @"Optional"; // TODO: store in NSUserDefaults
	}
//	else {
//		value = (UILabel *)[cell.contentView viewWithTag:FB_USERNAME_TAG];
//		aboutInput = (UITextView *)[cell.contentView viewWithTag:ABOUT_TAG];		
//	}
	cell.textLabel.text = fieldText;

//	NSLog(@"cell.textLabel: %@", cell.textLabel);
//	NSLog(@"cell.detailTextLabel: %@", cell.detailTextLabel);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	if (indexPath.section == 0 && indexPath.row == 0) {
		return 60.0f;
	} else {
		return tableView.rowHeight;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
	if (valueSelect.superview != nil) {
		[self donePickingValue:self];
	}
	self.navigationItem.rightBarButtonItem = textDone;
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification {
	self.navigationItem.rightBarButtonItem = saveButton;
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
	// Don't do anything for text or switch cells
	if ((indexPath.section == 0 && indexPath.row == ABOUT_ROW) ||
		(indexPath.section == 0 && indexPath.row == FB_USERNAME_ROW) ||
		(indexPath.section == 1 && indexPath.row == 0)) {
		return;
	}

	// check if our date picker is already on screen
	if (valueSelect.superview == nil) {
		[self doneEditingText:self];

		[[[UIApplication sharedApplication] keyWindow] addSubview:valueSelect];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [valueSelect sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		valueSelect.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		
		valueSelect.frame = pickerRect;
		
		// shrink the table vertical size to make room for the date picker
		CGRect newFrame = self.tableView.frame;
		newFrame.size.height -= valueSelect.frame.size.height;
		self.tableView.frame = newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = doneButton;
	}
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
	self.editIndexPath = indexPath;
	
	// TODO: make components a pointer
	self.components = [[pickerOptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[valueSelect reloadAllComponents];

	switch (editIndexPath.row) {
		case SEX_ROW:
			[valueSelect selectRow:[[myUser sex] intValue] inComponent:0 animated:NO];
			break;
		case LIKES_ROW:
			[valueSelect selectRow:[[myUser likes] intValue] inComponent:0 animated:NO];
			break;
		case BIRTHDAY_ROW:
			[valueSelect selectRow:0 inComponent:0 animated:NO]; // TODO: fix
			break;
		case HEIGHT_ROW: // TODO: display metric system unless user local is USA
			if (TRUE) { // detect if we're in USA. how?
				[valueSelect selectRow:[[myUser height] intValue] inComponent:0 animated:NO]; // feet
				[valueSelect selectRow:[[myUser height] intValue] inComponent:1 animated:NO]; // inches
			} else {
				[valueSelect selectRow:[[myUser height] intValue] inComponent:0 animated:NO]; // cm
			}
			break;
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			[valueSelect selectRow:[[myUser weight] intValue] inComponent:0 animated:NO];
			break;
		case ETHNICITY_ROW:
			[valueSelect selectRow:[[myUser ethnicity] intValue] inComponent:0 animated:NO];
			break;
		default:
//			[valueSelect selectRow:0 inComponent:0 animated:NO];
			break;
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSString *valueText;

	if (row == 0) {
		valueText = @"Optional";
	} else {
		valueText = [[components objectAtIndex:component] objectAtIndex:row];
	}

	switch (editIndexPath.row) {
		case SEX_ROW:
			[myUser setSex:[NSNumber numberWithInteger:row]];
			break;
		case LIKES_ROW:
			[myUser setLikes:[NSNumber numberWithInteger:row]];
			break;
		case BIRTHDAY_ROW:
//			[myUser setBirthday:[NSNumber numberWithInteger:row]]; // parse values from picker into NSDate
			break;
		case HEIGHT_ROW: // TODO: display metric system unless user local is USA
			// we should create a global mutable array: heightPicked = [int feet, int inches]
			// actually, do we need mutable? can we use nsarray since we are not adding objects?
			// just changing them in place...
			// something like this..
//			NSMutableArray *heightPicked = [[NSMutableArray alloc] initWithObjects:[self feetFromHeight([myUser height])],
//											[self inchesFromHeight([myUser height])]];
			
			// calculate total inches and convert to cm and save to height
//			int heightInCm = 67; // calculate...
//			[myUser setHeight:[NSNumber numberWithInteger:heightInCm]];
			[myUser setHeight:[NSNumber numberWithInteger:row]];
			break;
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			[myUser setWeight:[NSNumber numberWithInteger:row]];
			if (TRUE) {
				valueText = [NSString stringWithFormat:@"%@ lbs", valueText];
			} else {
				valueText = [NSString stringWithFormat:@"%@ kg", valueText];
			}
			break;
		case ETHNICITY_ROW:
			[myUser setEthnicity:[NSNumber numberWithInteger:row]];
			break;
		default:
			break;
	}

	[self.tableView cellForRowAtIndexPath:editIndexPath].detailTextLabel.text = valueText; // set text for UILabel
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [components count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[components objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {	
	NSString *valueTitle = [[components objectAtIndex:component] objectAtIndex:row];
	switch (editIndexPath.row) {
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			if (TRUE) {
				return [NSString stringWithFormat:@"%@ lbs", valueTitle];
			} else {
				return [NSString stringWithFormat:@"%@ kg", valueTitle];
			}
			break;
		default:
			return valueTitle;
			break;
	}
}

// This is to get the keyboard/picker to hide when touching
// the tableView. This should be in chatView.
// Add to TableView (I think by subclassing UITableView, i.e.,
// @interface TouchableTableView : UITableView
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	
//	// pass touches up to viewController
//	[self.nextResponder touchesBegan:touches withEvent:event];
//}
//
// Then, put this in this file (UIViewController)
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([valueInput isFirstResponder] && [touch view] != valueInput) {
//        [valueInput resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

- (void)slideDownDidStop {
	[valueSelect removeFromSuperview];
}

- (void)donePickingValue:(id)sender {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = valueSelect.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	valueSelect.frame = endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += valueSelect.frame.size.height;
	self.tableView.frame = newFrame;
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = saveButton;
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Text field/view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
	self.editTextTag = textView.tag;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.editTextTag = textField.tag;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	switch (textView.tag) {
		case ABOUT_TAG:
			[myUser setAbout:aboutInput.text];
			break;
		default:
			break;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	switch (textField.tag) {
		case NAME_TAG:
			[myUser setName:profileName.text];
			break;
		case HEADLINE_TAG:
			[myUser setHeadline:headlineInput.text];
			break;
		case FB_USERNAME_TAG:
			[myUser setFbUsername:valueInput.text];
			break;
		default:
			break;
	}
}

- (void)doneEditingText:(id)sender {
	switch (editTextTag) {
		case NAME_TAG:
			[profileName resignFirstResponder];	
			break;
		case HEADLINE_TAG:
			[headlineInput resignFirstResponder];	
			break;
		case ABOUT_TAG:
			[aboutInput resignFirstResponder];	
			break;
		case FB_USERNAME_TAG:
			[valueInput resignFirstResponder];	
			break;
		default:
			break;
	}
}

// TODO: Refactor out to work with other objects, like Interest.
- (void)clearChats:(id)sender {
	NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
	
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted", @"Message");
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error: %@", @"Message", error);
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// myUser is set in init, so I don't think we should set it to nil here.

	self.saveButton = nil;
	self.doneButton = nil;
	self.textDone = nil;

	self.avatarImg = nil;
	self.profileName = nil;
	self.headlineInput = nil;
	
	self.aboutInput = nil;
	self.valueInput = nil;

	self.profileFields = nil;
	self.pickerOptions = nil;
	self.components = nil;
	self.valueSelect = nil;
	self.editIndexPath = nil;
	// editTexTag shouldn't be set to nil because it's an NSInteger, right?

	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}

- (void)dealloc {
	[myUser release];

	[saveButton release];
	[doneButton release];
	[textDone release];

	// avatarImg, profileName, and headlineInput are released in loadView.

	[aboutInput release];
	[valueInput release];

	[profileFields release];
	[pickerOptions release];
	[components release];
	[valueSelect release];
	[editIndexPath release];
	// editTexTag mustn't be released because it's an NSInteger.

    [super dealloc];
}

@end
